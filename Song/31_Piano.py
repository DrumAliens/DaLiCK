#!../.venv/bin/python
from typing import List, Any
from pythonosc.udp_client import SimpleUDPClient
from pythonosc.dispatcher import Dispatcher
from pythonosc.osc_server import ThreadingOSCUDPServer
import sys
import time
import Library

# Read in any command line variables
playPhrase, playVolume, numPhrase, maskArray, delayPhrase, stopNum, freqRatio, playInstr, probVal, shufflePercent, waitTime = Library.decodeInstrArg(sys.argv)

# Set up server and client for testing
client = SimpleUDPClient(Library.SENDIP, Library.SENDPORT)

# ==== Send out 

# Instrumentation

posVal = [[0], [0], [0], [0]]
dur = [[16], [16], [16], [16]]
slice = [[0], [0], [0], [0]]
notes = [[41], [41], [41], [41]]

if playPhrase == 2:
    posVal = [[0], [0], [0], [0]]
    dur = [[16], [16], [16], [16]]
    slice = [[0], [0], [0], [0]]
    notes = [[40], [41], [42], [43]]

if playPhrase == 3:
    posVal = [[0], [0], [0], [0]]
    dur = [[16], [16], [16], [64]]
    slice = [[0], [0], [0], [0]]
    notes = [[40], [41], [42], [43]]

# if playPhrase == 2:
#     posVal = [[0], [], [], []]
#     dur = [[64], [], [], []]
#     slice = [[0], [], [], []]
#     notes = [[40], [], [], []]
#     # notes = [[48], [49], [50], [51]]




# if playPhrase >= 11:
#     posVal = [[0], [0], [0], [0]]
#     dur = [[16], [16], [16], [16]]
#     slice = [[0], [0], [0], [0]]
#     notes = [[44], [45], [46], [47]]
# else:
#     posVal = [[0], [0], [0], [0]]
#     dur = [[16], [16], [16], [64]]
#     slice = [[0], [0], [0], [0]]
#     notes = [[44], [45], [46], [47]]

# if playPhrase == 2:    
#     posVal = [[0], [0], [0], [0]]
#     dur = [[16], [16], [16], [16]]
#     slice = [[0], [0], [0], [0]]
#     notes = [[40], [41], [42], [43]]


# Chopped version
# if playPhrase == 10:    
#     posVal = [[0, 3, 6, 12], [0, 3, 6, 12, 14], [0, 3, 6, 12], [0, 3, 6, 12, 14]]
#     dur = [[2, 2, 3, 2], [2, 2, 3, 2, 2], [2, 2, 3, 2], [2, 2, 3, 2, 2]]
#     slice = [[0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0, 0]]
#     notes = [[40, 40, 40, 40], [41, 41, 41, 41, 41], [42, 42, 42, 42], [43, 43, 43, 43, 43]]

numBars = len(posVal)
phraseNumDivs = 16 * numBars

# Don't want and emphasis but need the elements
posEmphasis = Library.fillWith(posVal,1.0)

# Combine the 4 bars
events, count = Library.combineBars(posVal, notes, dur, posEmphasis, slice, maskArray)

# Sort out the duration so that plays as one instrument
# eventsMod = Library.checkDuration(events, count, phraseNumDivs)

#  Build the OSC Message
oscMessage = [0.08*playVolume, numPhrase, delayPhrase, probVal, shufflePercent]
oscMessage.append(count)
oscMessage.extend(events)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

if stopNum == 0:
    client.send_message("/song/piano/pianoChord", oscMessage)
    # client.send_message("/song/guitar/guitar", [0.05*playVolume, 41, maskArray[3]*posVal1, 48, maskArray[2]*posVal2, 50, maskArray[1]*posVal3, 51, maskArray[0]*posVal4, numPhrase, delayPhrase])
else:
    client.send_message("/song/piano/pianoChord", [stopNum])
