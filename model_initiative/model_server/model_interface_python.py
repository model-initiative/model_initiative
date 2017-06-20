import scipy.io as sio
import os
from model_server_python import *
# This function is called by the python_model_server_call matlab/octave function when the chosen model_language is python as argument in the model_server matlab function
# its role is to launch the python interface with the rights arguments


def model_interface_python():

    # Reads the set of arguments communicated by the matlab model_server
    # function through the python_model_server_call matlab/octave function
    path = os.path.join('..', 'fileexchange')
    if  os.path.exists(os.path.join(path, 'params.mat')):
        model_server_args = sio.loadmat(
            os.path.join(path, 'params.mat'))
    	os.remove(os.path.join(path, 'params.mat'))

    # Runs the model_server_python function with the right arguments
    model_server_python(model_server_args['no_intervals'][0, 0], str(model_server_args['model_name_and_args'][0]),
                        str(model_server_args['detector_name_and_args'][0]), str(model_server_args['model_language'][0]), str(model_server_args['detector_language'][0]))


if __name__ == "__main__":
    model_interface_python()
