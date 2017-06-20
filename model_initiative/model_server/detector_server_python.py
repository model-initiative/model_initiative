import scipy.io as sio
import os
import sys
import importlib
import csv
# This function is called by the detector_interface_matlab/python functions
# it runs the chosen python detector


def detector_server_python():

    # reads parameters related to the python detectors
    path = os.path.join('..', 'fileexchange')
    with open(os.path.join(path,'det_params.txt'), 'r') as fdetector:
        detector_name_and_args = fdetector.read()
    os.remove(os.path.join(path,'det_params.txt'))

    # import the chosen detectors
    sys.path.insert(0, os.path.join('..', 'decision_stages'))
    det_name = detector_name_and_args.split('(')[0]

    if os.path.exists(os.path.join('..', 'decision_stages', det_name + '.pyc')):
        os.remove(os.path.join('..', 'decision_stages', det_name + '.pyc'))
    d = importlib.import_module(det_name)
    detector_name_and_args = 'd.' + detector_name_and_args

    # loads pathway_out variable and run the detector and writes the decision
    # in the detector_out.csv file
    if os.path.exists(os.path.join(path, 'pathway_out.mat')):
        pathway_out = sio.loadmat(os.path.join(path, 'pathway_out.mat'))
        os.remove(os.path.join(path, 'pathway_out.mat'))

        response = eval(detector_name_and_args)

        with open(os.path.join(path, 'detector_out.csv'), "wb") as f:
            writer = csv.writer(f)
            writer.writerows(str(response))


if __name__ == '__main__':

    detector_server_python()
