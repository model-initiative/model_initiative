import numpy as np
import scipy.io as sio
import csv
import os

def argmin_python(pathway_out):
	response= np.argmin(pathway_out['pathway_out'])+1
	return response
		
if __name__ == '__main__':

	argmin(pathway_out)	

