#!../.venv/bin/python
from typing import List, Any
from pythonosc.udp_client import SimpleUDPClient
import sys
import time
import Library

# Read in any command line variables
playPhrase, playVolume, numPhrase, maskArray, delayPhrase, stopNum, freqRatio, playInstr, probPlay, probGlitch, probSlice, shufflePercent, strMsg, waitTime = Library.decodeInstrArg(sys.argv)

# Set up server and client for testing
client = SimpleUDPClient(Library.SENDIP, Library.SENDPORT)

#  Intro
phraseNumDivs = 128

# posVal =   [[ 12],  [ 12],  [12],  [ 12],  [ 12],  [ 12],  [ 12],  [ 12]]  
loclVal = 8
posVal =   [[loclVal ],  [ loclVal],  [loclVal],  [ loclVal],  [ loclVal],  [ loclVal],  [ loclVal],  [ loclVal]]  
midiVal =  [[57],  [56],  [57],  [56],  [57],  [55],  [57],  [57]]     
sliceVal = [[ 0],  [ 0],  [ 0],  [ 1],  [ 0],  [ 0],  [ 0],  [ 1]]  
dur =      [[16],  [16],  [16],  [16],  [16],  [16],  [16],  [16]]
# Additional arrays to influence instrument behaviour
effectArray1 = Library.fillWith(posVal, 1.0)
effectArray2 = Library.fillWith(posVal, 1.0)

stop = len(posVal)
if stop > 0 :
    posEmphasis = Library.fillWith(posVal, 1.0)

    events, count = Library.combineBars(16, posVal, midiVal, dur, posEmphasis, sliceVal, effectArray1, effectArray2, maskArray)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 

oscStrAddr = "/song/sounds/frogs_bass"

# close the chuck instance of that instrument
if playInstr == 0:
    client.send_message(oscStrAddr + "/kill", [playInstr])
else:    
    if stopNum == 0:

        # Sort out the duration so that plays as one instrument
        # eventsMod = Library.checkDuration(events, count, phraseNumDivs)

        #  Build the OSC Message
        oscMessage = [0.75*0.1*playVolume, numPhrase, delayPhrase, probPlay, probGlitch, probSlice, shufflePercent, strMsg]
        oscMessage.append(count)
        oscMessage.extend(events)
        # oscMessage.extend(eventsMod)

        client.send_message(oscStrAddr, oscMessage)
    else:
        client.send_message(oscStrAddr, [stopNum])


