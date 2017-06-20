import os
# This function prints and return the available models


def check_available_models():
    path = os.path.join('..', 'pathway_models')
    # print 'Below are the following available models: \n'
    model_list = []
    # print 'Below are the following available detectors: \n'
    for name in os.listdir(path):
        print name
        model_list.append(name)
    return model_list


if __name__ == '__main__':
    check_available_models()
