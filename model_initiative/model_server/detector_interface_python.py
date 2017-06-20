import platform
import subprocess
import os
from detector_server_python import detector_server_python

# This function is called by the model_server_python function
# It spawns a new thread (aka subprocess) in which the chosen detector
# will be launched


def detector_interface_python(detector_name_and_args,detector_language):
    # writes detector parameters in a file for the detector side to

    path = os.path.join('..', 'fileexchange')
    det_params = str(detector_name_and_args)
    f = open(os.path.join(path,'det_params.txt'), 'a')
    f.write(det_params)
    f.close()

    # Launch the new thread in the detector language chosen by the user
    if detector_language == 'matlab' or detector_language == 'octave':

        if platform.system() == 'Windows':
            if detector_language == 'matlab':
                p = subprocess.Popen(["matlab", "-nodisplay", "-nosplash", "-nodesktop",
                                      "-r", "detector_server_matlab()"], shell=False, stdout=subprocess.PIPE)

            elif detector_language == 'octave':
                p = subprocess.Popen(["octave-gui.exe", "--no-gui", "--eval",
                                      "pkg load control io signal statistics nan;detector_server_matlab()"], shell=False, stdout=subprocess.PIPE)

        elif platform.system() == 'Darwin':
            if detector_language == 'octave':
                p = subprocess.Popen(["octave-cli", "--no-gui", "--eval",
                                      "pkg load control io signal statistics nan ;detector_server_matlab()"], shell=False, stdout=subprocess.PIPE)

            elif detector_language == 'matlab':
                p = subprocess.Popen(["matlab", "-nodisplay", "-nosplash",
                                      "-nodesktop", "-r", "detector_server_matlab()"], shell=False, stdout=subprocess.PIPE)

        else:
            if detector_language == 'octave':
                p = subprocess.Popen(
                    ["octave", "--no-gui", "--eval", "pkg load control io signal statistics nan ;detector_server_matlab()"], shell=False, stdout=subprocess.PIPE)
            elif detector_language == 'matlab':
                p = subprocess.Popen(["matlab", "-nodisplay", "-nosplash", "-nodesktop",
                                      "-r", "detector_server_matlab()"], shell=False, stdout=subprocess.PIPE)

    # If the chosen detector language is python, the detector is run in the
    # same thread.
    elif detector_language == 'python':
        detector_server_python()
