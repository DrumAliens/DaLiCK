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
# 72		Ding		
# 73		Dong		
# 74		Ding	3rd	Up
# 75		Dong	3rd	Up
# 76		Ding	5th	Up
# 77		Dong	5th	Up

noteLen = 3
rootNote = Library.MIDIROOTNOTE
# rootNote = Library.rateToMidiNote(0.97)
notes = [[72], [73], [72], [73], [72], [73]]

# if playPhrase == 1:
#     notes = [[72], [74], [76], [74], [72], [74]]
# if playPhrase == 2:
#     notes = [[76], [74], [72], [74], [76], [74]]

dur = Library.fillWith(notes, 3)
posVal = Library.fillWith(notes, 0)
sliceVal = Library.fillWith(notes, 0)
# notes = Library.fillWith(posVal, rootNote+1)
# Additional arrays to influence instrument behaviour
effectArray1 = Library.fillWith(notes, 1.0)
effectArray2 = Library.fillWith(notes, 1.0)
posEmphasis = Library.fillWith(notes, 1.0)

stop = len(posVal)
if stop > 0 :
    events, count = Library.combineBars(3, posVal, notes, dur, posEmphasis, sliceVal, effectArray1, effectArray2, maskArray)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 

oscStrAddr = "/song/sounds/dingvocals_mid"

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


