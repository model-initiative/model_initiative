from brian import *
from brian.hears import *
#This function implements a model similar to the one described
#in Goodman and Brette,2010
#a good choice for the detector is the argmax_python.py detector

def goodman_brette_2010_python(soundtest,fs,number_neurons=20, noise=0.05):
    set_default_samplerate(fs*Hz)	
    sound = Sound((soundtest[0], soundtest[1]),samplerate=fs*Hz)
    ## Create an hrtfset of number_neurons itds ##
    hset = HeadlessDatabase(itd=np.linspace(
	0, 0.002, number_neurons), fractional_itds=False).load_subject()
    num_indices = hset.num_indices
    swapped_channels = RestructureFilterbank(sound, indexmapping=[1, 0]) 
    hset_fb = hset.filterbank(Repeat(swapped_channels, num_indices))

    ### Gammatone filtering ##
    gfb = Gammatone(hset_fb, tile(4 * kHz, hset_fb.nchannels))

    ###half wave rectification + compression ###
    cochlea = FunctionFilterbank(
        gfb, lambda x: 5 * clip(x, 0, Inf)**(1.0 / 3.0))

    ### Leaky integrate and fire with noise ###
    eqs = '''
		dV/dt = (I-V)/(1*ms)+noise*xi/(0.5*ms)**.5 : 1
		I : 1
	    '''

    G = FilterbankGroup(cochlea, 'I', eqs, threshold=1,
                        reset=0,refractory=3*ms)

    ###Coincidence detector neurons ###
    cd = NeuronGroup(num_indices, eqs, threshold='V>1',
                     reset='V=0', clock=G.clock)
    
    C = Connection(G, cd, 'V')
    for i in xrange(num_indices):
    	C[i, i] = 0.5                 # from right ear
    	C[i+num_indices, i] = 0.5

    # countercd=SpikeCounter(cd)
    spm = SpikeCounter(cd)
    run(sound.duration)

    count = spm.count
    print count
    max_count = argmax(count)

    ###Return the indice of the coincidence detector that fired maximally ###
    return max_count
