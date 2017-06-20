import os
# This functions prints and returns the available detectors


def check_available_detectors():
    path = os.path.join('..', 'decision_stages')
    detector_list = []
    # print 'Below are the following available detectors: \n'
    for name in os.listdir(path):
        print name
        detector_list.append(name)
    return detector_list


if __name__ == '__main__':
    check_available_detectors()
