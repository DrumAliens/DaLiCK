#!../.venv/bin/python
from typing import List, Any
from pythonosc.udp_client import SimpleUDPClient
import sys
import time
import Library

# Read in any command line variables
playPhrase, playVolume, numPhrase, maskArray, delayPhrase, stopNum, freqRatio, playInstr, probVal, shufflePercent, waitTime = Library.decodeInstrArg(sys.argv)

# Set up server and client for testing
client = SimpleUDPClient(Library.SENDIP, Library.SENDPORT)

phraseNumDivs = 128
# events = []
# count = 0
# if playPhrase < 5:
#     posVal =  []  
#     midiVal = []     
#     sliceVal = []  
#     dur =      []
#     for i in range(len(posVal)):
#         events.extend([posVal[i], midiVal[i], dur[i], 1.0, sliceVal[i]])
#         count += 1

# Short Short Long Long
if playPhrase <= 1:
    posVal =   [[ 0,   4,   8,  12], [0,   4,  8], [ 0,   4,   8,  12], [0,   4,  8], [ 0,  4,  8, 12], [ 0,  4,  8, 12], [ 0,  4,  8, 12], [0,   4,  8, 12]]
    midiVal =  [[77,  76,  77,  76], [77, 76, 77], [77,  76,  77,  76], [77, 76, 77], [77, 76, 77, 76], [77, 76, 77, 76], [77, 76, 77, 76], [77, 76, 77, 76]]     
    sliceVal = [[ 0,   1,   2,   3], [4,   5,  6], [ 0,   1,   2,   3], [4,   5,  6], [ 6,  6,  6,  6], [ 5,  5,  5,  5], [ 6,  6,  6,  6], [ 5,  5,  5,  5]]  
    dur =      [[ 4,   4,   4,   4], [4,   4,  4], [ 4,   4,   4,   4], [4,   4,  4], [ 4,  4,  4,  4], [ 4,  4,  4,  4], [ 4,  4,  4,  4], [ 4,  4,  4,  4]]

# Short Long Long Short
if playPhrase == 2:
    posVal =   [[ 0,   4,   8,  12], [0,   4,  8], [ 0,  4,  8, 12], [ 0,  4,  8, 12], [ 0,  4,  8, 12], [ 0,  4,  8, 12], [ 0,  4,  8,  12], [ 0,  4,  8]]
    midiVal =  [[77,  76,  77,  76], [77, 76, 77], [77, 76, 77, 76], [77, 76, 77, 76], [77, 76, 77, 76], [77, 76, 77, 76], [77, 76,  77, 76], [77, 76, 77]]     
    sliceVal = [[ 0,   1,   2,   3], [4,   5,  6], [ 6,  6,  6,  6], [ 5,  5,  5,  5], [ 6,  6,  6,  6], [ 5,  5,  5,  5], [ 0,  1,  2,   3], [ 4,  5,  6]]  
    dur =      [[ 4,   4,   4,   4], [4,   4,  4], [ 4,  4,  4,  4], [ 4,  4,  4,  4], [ 4,  4,  4,  4], [ 4,  4,  4,  4], [ 4,  4,  4,   4], [ 4,  4,  4]]

# Long Long Short Short
if playPhrase == 3:
    posVal =   [[ 0,  4,  8, 12], [ 0,  4,  8, 12], [ 0,  4,  8, 12], [0,   4,  8, 12], [ 0,   4,   8,  12], [0,   4,  8], [ 0,   4,   8,  12], [0,   4,  8]]
    midiVal =  [[77, 76, 77, 76], [77, 76, 77, 76], [77, 76, 77, 76], [77, 76, 77, 76], [77,  76,  77,  76], [77, 76, 76], [77,  76,  77,  76], [77, 76, 77]]     
    sliceVal = [[ 6,  6,  6,  6], [ 5,  5,  5,  5], [ 6,  6,  6,  6], [ 5,  5,  5,  5], [ 0,   1,   2,   3], [4,   5,  6], [ 0,   1,   2,   3], [4,   5,  6]]  
    dur =      [[ 4,  4,  4,  4], [ 4,  4,  4,  4], [ 4,  4,  4,  4], [ 4,  4,  4,  4], [ 4,   4,   4,   4], [4,   4,  4], [ 4,   4,   4,   4], [4,   4,  4]]

# Frogs reprise
if playPhrase >= 10:
    posVal =   [[ ], [ ], [0 ], [ ], [ ], [ ], [0 ], [0]]
    midiVal =  [[ ], [ ], [67 ], [ ], [ ], [ ], [67 ], [67]]     
    sliceVal = [[ ], [ ], [0 ], [ ], [ ], [ ], [0 ], [ 0]]  
    dur =      [[ ], [ ], [4 ], [ ], [ ], [ ], [4 ], [ 4]]


stop = len(posVal)
if stop > 0 :
    # posEmphasis = Library.fillWith(posVal, 1.0)
    posEmphasis = []
    for i in range(len(posVal)):
        posEmphasis.append(Library.calcEmphasis(posVal[i], 4, 0.5, 0.25))
    events, count = Library.combineBars(posVal, midiVal, dur, posEmphasis, sliceVal, maskArray)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 
if stopNum == 0:

    # Sort out the duration so that plays as one instrument
    # eventsMod = Library.checkDuration(events, count, phraseNumDivs)

    #  Build the OSC Message
    oscMessage = [0.75*0.08*playVolume, numPhrase, delayPhrase, probVal, shufflePercent]
    oscMessage.append(count)
    oscMessage.extend(events)
    client.send_message("/song/sounds/frogs_mid", oscMessage)
else:
    client.send_message("/song/sounds/frogs_mid", [stopNum])

# close the chuck instance of that instrument
if playInstr != 1:
    client.send_message("/song/sounds/frogs_mid/kill", [playInstr])
