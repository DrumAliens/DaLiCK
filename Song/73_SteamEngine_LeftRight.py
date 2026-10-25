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

barNumDivs = 3

rootNote = Library.MIDIROOTNOTE

# Left Steam Engine
posValL = [[1], [1], [1], [1], [1], [1], [1], [1], [1], [1], [1], [1], [1], [1], [1], [1], [1], [1]]  
sliceL =  [[0], [1], [2], [3], [4], [5], [6], [7], [8], [0], [1], [2], [3], [4], [5], [6], [7], [8]]
notes = Library.fillWith(posValL, rootNote)
dur = Library.fillWith(posValL, barNumDivs)
posEmphasis = Library.fillWith(posValL, 1.0)
# Additional arrays to influence instrument behaviour
effectArray1 = Library.fillWith(posValL, 1.0)
effectArray2L = Library.fillWith(posValL, 0.0)
effectArray2R = Library.fillWith(posValL, 1.0)

# Right Steam Engine
posValR = [[2], [2], [2], [2], [2], [2], [2], [2], [2], [2], [2], [2], [2], [2], [2], [2], [2], [2]]  
sliceR =  [[0], [1], [2], [3], [4], [5], [6], [7], [8], [0], [1], [2], [3], [4], [5], [6], [7], [8]]

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 
stop = len(posValL)
if stop > 0 :
    
    eventsL, countL = Library.combineBars(barNumDivs, posValL, notes, dur, posEmphasis, sliceL, effectArray1, effectArray2L, maskArray)
    eventsR, countR = Library.combineBars(barNumDivs, posValR, notes, dur, posEmphasis, sliceR, effectArray1, effectArray2R, maskArray)

# Sort the order to make one instrument
events, count = Library.sortBars(eventsL, countL, eventsR, countR)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 

oscStrAddr = "/song/sounds/steamengine_leftright"

# close the chuck instance of that instrument
if playInstr == 0:
    client.send_message(oscStrAddr + "/kill", [playInstr])
else:    
    if stopNum == 0:

        # Sort out the duration so that plays as one instrument
        # eventsMod = Library.checkDuration(events, count, phraseNumDivs)

        #  Build the OSC Message
        oscMessage = [0.03*playVolume, numPhrase, delayPhrase, probPlay, probGlitch, probSlice, shufflePercent, strMsg]
        oscMessage.append(count)
        oscMessage.extend(events)
        client.send_message(oscStrAddr, oscMessage)

    else:
        client.send_message(oscStrAddr, [stopNum])

