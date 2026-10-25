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
rootNote = Library.MIDIROOTNOTE
rootNote = Library.rateToMidiNote(0.97)
barNumDivs = 3

posVal =   [[0], [], [2], [], [0, 2], [], [0], [], [0], [], [0], [], [], [], [], [], [], []]  
sliceVal = [[0], [], [1], [], [2, 3], [], [4], [], [5], [], [6], [], [], [], [], [], [], []]  
dur =      [[8], [], [4], [], [2, 4], [], [6], [], [6], [], [6], [], [], [], [], [], [], []]

if playPhrase > 0:
    posVal =   [[0], [], [2], [], [0, 2], [], [0], [], [0], [], [0], [], [0], [0], [0],  [0],  [0], [0]]  
    sliceVal = [[0], [], [1], [], [2, 3], [], [4], [], [5], [], [6], [], [7], [8], [9], [10], [11], [12]]  
    dur =      [[8], [], [4], [], [2, 4], [], [6], [], [6], [], [6], [], [3], [3], [3],  [3],  [3], [3]]

notes = Library.fillWith(posVal, rootNote)
# Additional arrays to influence instrument behaviour
effectArray1 = Library.fillWith(posVal, 1.0)
effectArray2 = Library.fillWith(posVal, 1.0)

stop = len(posVal)
if stop > 0 :
    posEmphasis = Library.fillWith(posVal, 1.0)

    events, count = Library.combineBars(barNumDivs, posVal, notes, dur, posEmphasis, sliceVal, effectArray1, effectArray2, maskArray)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 

oscStrAddr = "/song/sounds/ohhowvocals_mid"

# close the chuck instance of that instrument
if playInstr == 0:
    client.send_message(oscStrAddr + "/kill", [playInstr])
else:    
    if stopNum == 0:

        # Sort out the duration so that plays as one instrument
        # eventsMod = Library.checkDuration(events, count, phraseNumDivs)

        #  Build the OSC Message
        oscMessage = [0.75*0.175*playVolume, numPhrase, delayPhrase, probPlay, probGlitch, probSlice, shufflePercent, strMsg]
        oscMessage.append(count)
        oscMessage.extend(events)
        # oscMessage.extend(eventsMod)

        client.send_message(oscStrAddr, oscMessage)
    else:
        client.send_message(oscStrAddr, [stopNum])


