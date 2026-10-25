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
phraseNumDivs = barNumDivs * 9  

rootNote = Library.MIDIROOTNOTE

# posVal = [[2, 8, 14], [2, 8, 14], [2, 8, 14], [2, 8, 14], [2, 8, 14], [2, 8, 14], [2, 8, 14], [2, 8, 14]]  
# slice =  [[0, 1,  2], [3, 4,  5], [6, 7,  0], [1, 2,  3], [4, 5,  6], [7, 0,  1], [2, 3,  4], [5, 6,  7]]

posVal = [[], [], [], [], [], [], [], [], [0]]  
slice =  [[], [], [], [], [], [], [], [], [0]]

notes = Library.fillWith(posVal, rootNote)
dur = Library.fillWith(posVal, 99)
posEmphasis = Library.fillWith(posVal, 1.0)
# Additional arrays to influence instrument behaviour
effectArray1 = Library.fillWith(posVal, 1.0)
effectArray2 = Library.fillWith(posVal, 1.0)

eventsMod, count = Library.combineBars(barNumDivs, posVal, notes, dur, posEmphasis, slice, effectArray1, effectArray2, maskArray)

# Sort out the duration so that plays as one instrument
# eventsMod = Library.checkDuration(events, count, phraseNumDivs)

#  Build the OSC Message
oscMessage = [0.035*playVolume, numPhrase, delayPhrase, probPlay, probGlitch, probSlice, shufflePercent, strMsg]
oscMessage.append(count)
oscMessage.extend(eventsMod)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 

oscStrAddr = "/song/sounds/steamengine_steam"

# Close the chuck instance of that instrument
if playInstr == 0:
    client.send_message(oscStrAddr+"/kill", [playInstr])
else:
    if stopNum == 0:
        client.send_message(oscStrAddr,  oscMessage)
    else:
        client.send_message(oscStrAddr, [stopNum])
