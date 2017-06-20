import sys
import os
import subprocess
import platform
import atexit
# The role of this function is to gather the arguments the user gave to
# the python model_server function and to assure a smooth transition to
# the matlab model_server


def matlab_model_server_call(no_intervals, model_name_and_args, detector_name_and_args, model_language, detector_language):

    # This part loads the argument from the params.txt file
    path = os.path.join('..', 'fileexchange')
    params = []
    params.append(str(no_intervals))
    params.append(model_name_and_args)
    params.append(detector_name_and_args)
    params.append(model_language)
    params.append(detector_language)
    f = open(os.path.join(path, 'params.txt'), 'a')
    for item in params:
        f.write("%s" % item + '  ')
    f.close()

    # Launching the model_interface function whch will then call the
    # model_server function
    if platform.system() == 'Windows':
        if model_language == 'octave':
            p = subprocess.Popen(["octave-gui.exe", "--no-gui", "--eval",
                                  "pkg load control io signal statistics nan;model_interface_matlab()"], shell=False, stdout=subprocess.PIPE)
        elif model_language == 'matlab':
            p = subprocess.Popen(["matlab",  "-nodisplay", "-nosplash", "-nodesktop",
                                  "-r", "model_interface_matlab()"], shell=False, stdout=subprocess.PIPE)

    elif platform.system() == 'Darwin':
        if model_language == 'octave':
            p = subprocess.Popen(["octave-cli", "--no-gui", "--eval",
                                  "pkg load control io signal statistics nan;model_interface_matlab()"], shell=False, stdout=subprocess.PIPE)
        elif model_language == 'matlab':
            p = subprocess.Popen(["matlab", "-nodisplay", "-nosplash",
                                  "-nodesktop", "-r", "model_interface_matlab()"], shell=False, stdout=subprocess.PIPE)

    else:
        if model_language == 'octave':
            p = subprocess.Popen(["octave", "--no-gui", "--eval",
                                  "pkg load control io signal statistics nan;model_interface_matlab()"], shell=False, stdout=subprocess.PIPE)
        elif model_language == 'matlab':
            p = subprocess.Popen(["matlab", "-nodisplay", "-nosplash", "-nodesktop",
                                  "-r", "model_interface_matlab()"], shell=False, stdout=subprocess.PIPE)

    while p.poll() is None:
        l = p.stdout.readline()
        print l
        atexit.register(exit_handler, p)
    print p.stdout.read()

#making sure the spawned thread is closed when exiting process
def exit_handler(p):
    p.kill()
    if platform.system() != 'Windows':
        os.system('stty sane')
