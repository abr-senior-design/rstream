__author__ = 'pjuluri'

import config_dash
import random
import time


def bandwidth_dash(bitrates, dash_player, weighted_dwn_rate, curr_bitrate, next_segment_sizes):
    """
    Module to predict the next_bitrate using the weighted_dash algorithm
    :param bitrates: List of bitrates
    :param weighted_dwn_rate:
    :param curr_bitrate:
    :param next_segment_sizes: A dict mapping bitrate: size of next segment
    :return: next_bitrate, delay
    """

    bitrates = [int(i) for i in bitrates]
    bitrates.sort()

    past_switch_count = 0
    for i in config_dash.past_switches:
        if i:
            past_switch_count += 1

    # Waiting time before downloading the next segment
    delay = 0

    alph = 5

    next_bitrate = None
    available_video_segments = dash_player.buffer.qsize() - dash_player.initial_buffer
    # If the buffer is less that the Initial buffer, playback remains at th lowest bitrate
    # i.e dash_buffer.current_buffer < dash_buffer.initial_buffer

    available_video_duration = available_video_segments * dash_player.segment_duration
    config_dash.LOG.info(" !!!!!!!!!!!!!Buffer_length = {} Initial Buffer = {} Available video = {} seconds, alpha = {}. "
                          "Beta = {} WDR = {}, curr Rate = {}".format(dash_player.buffer.qsize(),
                                                                      dash_player.initial_buffer,
                                                                      available_video_duration, dash_player.alpha,
                                                                      dash_player.beta, weighted_dwn_rate,
                                                                      curr_bitrate))

    if weighted_dwn_rate == 0 or available_video_segments == 0:
        next_bitrate = bitrates[0]
    # If time to download the next segment with current bitrate is longer than current - initial,
    # switch to a lower suitable bitrate

    #FIND THE BITRATE THAT IS JUST BELOW THE DOWNLOAD RATE
    #next_bitrate = bitrates[0]
    for i in bitrates:
        if (i > weighted_dwn_rate):
            break;
        next_bitrate = i;


    if next_bitrate != curr_bitrate:

        curr_bitrate_score = (get_score_eff(next_bitrate, curr_bitrate, weighted_dwn_rate, alph)
            + get_score_stability(curr_bitrate, curr_bitrate, past_switch_count))
        next_bitrate_score = (get_score_eff(next_bitrate, next_bitrate, weighted_dwn_rate, alph)
            + get_score_stability(curr_bitrate, next_bitrate, past_switch_count))

        if (curr_bitrate_score < next_bitrate_score):
            next_bitrate = curr_bitrate

        config_dash.LOG.info(" !!!!!!Current bitrate score {} : {} Next bitrate score {} : {}".format(
                                                                curr_bitrate, curr_bitrate_score,
                                                                next_bitrate, next_bitrate_score))

    rand_buf = random.randint(config_dash.NETFLIX_INITIAL_BUFFER - 1,
                                config_dash.NETFLIX_INITIAL_BUFFER + 1)

    if available_video_segments < rand_buf:
        delay = 0
    else:
        delay = available_video_segments - rand_buf

    config_dash.LOG.debug("The next_bitrate is assigned as {}".format(next_bitrate))
    config_dash.LOG.info("Delay:{}".format(delay))

    if next_bitrate != curr_bitrate:
        temp_time = int(time.time())
        start = 0
        end = config_dash.BANDWIDTH_SAMPLE_COUNT - 1
        if temp_time - config_dash.last_switch < config_dash.BANDWIDTH_SAMPLE_COUNT:
            start = (config_dash.last_switch + 1) % config_dash.BANDWIDTH_SAMPLE_COUNT
            end = (temp_time - 1) % config_dash.BANDWIDTH_SAMPLE_COUNT

        if start < end:
                for i in range(start, end - 1):
                    config_dash.past_switches[i] = False
        else:
            for i in range(start, config_dash.BANDWIDTH_SAMPLE_COUNT - 1):
                config_dash.past_switches[i] = False
            for i in range(0, end - 1):
                config_dash.past_switches[i] = False

        config_dash.past_switches[temp_time % 20] = True
        config_dash.last_switch = temp_time

    return next_bitrate, delay

def get_score_eff(next_bitrate, bitrate, est_band, alph):
    return 5 * abs(float(bitrate) / min(est_band, next_bitrate) - 1)


#CHANGE PAS_REBUFFER TO PAST_QUALITY SWITCHES
def get_score_stability(curr_bitrate, bitrate, past_switch_count):
    if curr_bitrate == bitrate:
        return 2**past_switch_count
    return 2**past_switch_count + 1

