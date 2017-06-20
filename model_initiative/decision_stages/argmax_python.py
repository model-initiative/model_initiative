import numpy as np
import scipy.io as sio
import csv
import os


def argmax_python(pathway_out):
	
	response= np.argmax(pathway_out['pathway_out'])+1
	return response
if __name__ == '__main__':
	
	argmax_python(pathway_out)
	

	
