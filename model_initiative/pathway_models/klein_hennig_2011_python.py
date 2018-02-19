# The function "NCC" below handles the processing of the intervals by a cross
# correlation model with or without adaptation loops###
from brian import *
from brian.hears import *


###Preprocessing filtering ###
def pre_processing(soundtest,fs):
    bw = 10**(0.037 + 0.785 * log10(4000))
    gfb_l = ApproximateGammatone(soundtest.channel(
        0), cf=4 * kHz, bandwidth=bw, order=4)
    hvr_l = FunctionFilterbank(gfb_l, lambda x: clip(x, 0, Inf)**(0.46))
    hvrlp_l = Butterworth(hvr_l, 1, 4, 425 * Hz, btype='low')
    hvrlp2_l = LowPass(hvrlp_l, 150 * Hz)
    persig_l = hvrlp2_l.process()

    gfb_r = ApproximateGammatone(soundtest.channel(
        1), cf=4 * kHz, bandwidth=bw, order=4)
    hvr_r = FunctionFilterbank(gfb_r, lambda x: clip(x, 0, Inf)**(0.46))
    hvrlp_r = Butterworth(hvr_r, 1, 4, 425 * Hz, btype='low')
    hvrlp2_r = LowPass(hvrlp_r, 150 * Hz)
    persig_r = hvrlp2_r.process()

    sl = np.array(persig_l)
    sr = np.array(persig_r)
    s = Sound((sl, sr),samplerate=fs*Hz)

    return s


def adaptation_loop(nbrLoops,fs, source, tau):

    b0 = np.zeros((nbrLoops))
    a1 = np.zeros((nbrLoops))
    tmp2 = np.zeros((nbrLoops))
    minLev = 0.00001
    for i in xrange(nbrLoops):
        b0[i] = 1.0 / (tau[i] * fs)
        a1[i] = exp(-b0[i])
        b0[i] = 1 - a1[i]
        tmp2[i] = minLev**(0.5**(i + 1))
    minl = tmp2
    arr = np.array(source)
    arrout = np.array(source)
    limit = 10

    for i in xrange(source.nsamples):

        tmp1 = arr[i, 0]
        if tmp1 < minLev:
            tmp1 = minLev
        for j in xrange(nbrLoops):
            tmp1 = tmp1 / tmp2[j]
            maxvalue = (1 - minl[j]**2) * limit - 1
            factor = maxvalue * 2
            expfac = -2.0 / maxvalue
            offset = maxvalue - 1
            if tmp1 > 1:
                tmp1 = factor / (1.0 + exp(expfac * (tmp1 - 1))) - offset

            tmp2[j] = a1[j] * tmp2[j] + b0[j] * tmp1
            arrout[i, 0] = tmp1

    return arrout


def klein_hennig_2011_python(soundtest,fs, noise, tau=None):
    sound = Sound((soundtest[0], soundtest[1]),samplerate=fs*Hz)
    # print sound
    s = pre_processing(sound,fs)
    if tau is not None:
        scl = adaptation_loop(len(tau),fs, s.channel(0), tau)
        scr = adaptation_loop(len(tau),fs, s.channel(1), tau)

    else:
        scl = np.array(s.channel(0))
        scr = np.array(s.channel(1))

    scl = scl.reshape((s.channel(0).nsamples))
    scr = scr.reshape((s.channel(0).nsamples))
    
    scl=scl/sqrt(np.mean(scl**2))
    scr=scr/sqrt(np.mean(scr**2))
    
    scl = scl + noise * randn(s.channel(1).nsamples)
    scr = scr + noise * randn(s.channel(1).nsamples)

    crossc = np.corrcoef(scl, scr)

    crossco = crossc[0, 1]
    print 'cross_co: ' + str(crossco)

    return crossco
