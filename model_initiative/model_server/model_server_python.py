import numpy as np
import os
import sys
import importlib
import csv
import scipy.io as sio
import scipy.io.wavfile
from detector_interface_python import detector_interface_python
from matlab_model_server_call import matlab_model_server_call
# This function handles the launch of the model and detector chosen by the user
# The number of intervals refers to the number of .wav files that the
# experiment side output


def model_server_python(no_intervals, model_name_and_args, detector_name_and_args, model_language, detector_language):
    # set the path of the folder where files are exchanged between the
    # experiment side and the model side
    path = os.path.join('..', 'fileexchange')

    if model_language == 'python':

        # import the chosen python model module
        sys.path.insert(0, os.path.join('..', 'pathway_models'))
        model_name = model_name_and_args.split('(')[0]
        if os.path.exists(os.path.join('..', 'pathway_models', model_name + '.pyc')):
            os.remove(os.path.join('..', 'pathway_models', model_name + '.pyc'))
        mod = importlib.import_module(model_name)
        model_name_and_args = 'mod.' + model_name_and_args

        if os.path.exists(os.path.join(path, 'finished.txt')):
            os.remove(os.path.join(path, 'finished.txt'))
        if os.path.exists(os.path.join(path, 'feedback.csv')):
            os.remove(os.path.join(path, 'feedback.csv'))

        n = 0
        # this loops here keep looking for the intervals produced on the
        # experiment side until the experiment side stops and output a
        # finished.txt file
        while not os.path.exists(os.path.join(path, 'finished.txt')):

            if os.path.exists(os.path.join(path, 'feedback.csv')):
                f = open(os.path.join(path, 'feedback.csv'), 'rb')
                reader = csv.reader(f)
                for row in reader:
                    feedback = row

            else:
                feedback = []

            pathway_out = []
            # checks if all intervals are created
            b = True
            for i in xrange(no_intervals):
                b = b * os.path.exists(os.path.join(path,
                                                    'interval_' + str(i + 1) + '.wav'))

            if b:
                n = n + 1
                print 'Model started! No. ' + str(n)
                # load intervals and run the model
                for i in xrange(no_intervals):
                    wave = []
                    fs = 0
                    fs, wve = scipy.io.wavfile.read(os.path.join(
                        path, 'interval_' + str(i + 1) + '.wav'))
                    wve = np.array(wve, dtype=float)
                    wve = np.reshape(wve, (wve.size / 2, 2))
                    wave.append(wve[:, 0])
                    wave.append(wve[:, 1])
                    pathway_out.append(eval(model_name_and_args))
                    os.remove(os.path.join(
                        path, 'interval_' + str(i + 1) + '.wav'))

                # save the model_output in a .mat file
                sio.savemat(os.path.join(path, 'pathway_out.mat'),
                            {'pathway_out': pathway_out})


                detector_interface_python(detector_name_and_args,detector_language)

    if model_language == 'matlab' or model_language == 'octave':
        matlab_model_server_call(no_intervals, model_name_and_args,
                                 detector_name_and_args, model_language, detector_language)


if __name__ == '__main__':
    model_server_python(2, 'klein_hennig_2011_python(wave,0,None)',
                        'python', 'argmin_python(pathway_out)', 'python')
