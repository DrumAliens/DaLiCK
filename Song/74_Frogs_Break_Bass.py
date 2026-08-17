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

#  Intro
phraseNumDivs = 128
# if playPhrase <= 1:
#     posVal =  [  0,   16,  32,  48,  64,  80,  96, 112, 120]  
#     midiVal = [ 58,   57,  58,  57,  58,  56,  58,  57,  57]     
#     sliceVal = [ 6,    6,   6,   6,   6,   6,   6,   6,   6]  
#     dur =      [16,   16,  16,  16,  16,  16,  16,  16,  16]
# if playPhrase == 2:
#     posVal =  [  0,   16,  32,  48,  64,  80,  96, 112, 120]  
#     midiVal = [ 57,   56,  57,  56,  57,  55,  57,  56,  56]     
#     sliceVal = [ 0,    0,   0,   0,   0,   0,   0,   0,   0]  
#     dur =      [16,   16,  16,  16,  16,  16,  16,  16,  16]

# if playPhrase == 3:
# posVal =  [  0,   16,  32,  48,  64,  80,  96, 112]  
# midiVal = [ 57,   56,  57,  56,  57,  55,  57,  56]     
# sliceVal = [ 0,    0,   0,   6,   0,   0,   0,   6]  
# dur =      [16,   16,  16,  16,  16,  16,  16,  16]

        
# events = []
# count = 0
# for i in range(len(posVal)):
#     events.extend([posVal[i], midiVal[i] + 4, dur[i], 1.0, sliceVal[i]])
#     count += 1


posVal =   [[ 0],  [ 0],  [ 0],  [ 0],  [ 0],  [ 0],  [ 0],  [ 0]]  
midiVal =  [[57],  [56],  [57],  [56],  [57],  [55],  [57],  [57]]     
sliceVal = [[ 0],  [ 0],  [ 0],  [ 1],  [ 0],  [ 0],  [ 0],  [ 1]]  
dur =      [[16],  [16],  [16],  [16],  [16],  [16],  [16],  [16]]

stop = len(posVal)
if stop > 0 :
    posEmphasis = Library.fillWith(posVal, 1.0)
    # posEmphasis = []
    # for i in range(len(posVal)):
    #     posEmphasis.append(Library.calcEmphasis(posVal[i], 4, 0.5, 0.25))
    events, count = Library.combineBars(posVal, midiVal, dur, posEmphasis, sliceVal, maskArray)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 
if stopNum == 0:

    # Sort out the duration so that plays as one instrument
    # eventsMod = Library.checkDuration(events, count, phraseNumDivs)

    #  Build the OSC Message
    oscMessage = [0.75*0.1*playVolume, numPhrase, delayPhrase, probVal, shufflePercent]
    oscMessage.append(count)
    oscMessage.extend(events)
    # oscMessage.extend(eventsMod)

    client.send_message("/song/sounds/frogs_bass", oscMessage)
else:
    client.send_message("/song/sounds/frogs_bass", [stopNum])

# close the chuck instance of that instrument
if playInstr != 1:
    client.send_message("/song/sounds/frogs_bass/kill", [playInstr])
