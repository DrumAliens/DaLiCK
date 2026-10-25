#!../.venv/bin/python
from typing import List, Any
from pythonosc.udp_client import SimpleUDPClient
import sys
import time
import Library

# Read in any command line variables
playPhrase, playVolume, numPhrase, maskArray, delayPhrase, stopNum, freqRatio, playInstr, probPlay, probGlitch, probSlice, shufflePercent, strMsg, waitTime = Library.decodeInstrArg(sys.argv)

# ==== Send out
client = SimpleUDPClient(Library.SENDIP, Library.SENDPORT)

# ==== Send out 
barNumDivs = 16
phraseNumDivs = barNumDivs * 4

# Instrumentation
posVal = [[0], [0], [0], [0]]
dur = Library.fillWith(posVal, 3)
slice = Library.fillWith(posVal, 0)
notes = Library.fillWith(posVal, Library.MIDIROOTNOTE)
# Don't want and emphasis but need the elements
posEmphasis = Library.fillWith(posVal, 1.0)

# Additional arrays to influence instrument behaviour
effectArray1 = Library.fillWith(posVal, 1.0)
effectArray2 = Library.fillWith(posVal, 1.0)

# Combine the bars together
events, count = Library.combineBars(barNumDivs, posVal, notes, dur, posEmphasis, slice, effectArray1, effectArray2, maskArray)

# Ensures that the durations don't clash with each other
eventsMod = Library.checkDuration(events, count, phraseNumDivs)

#  Build the OSC Message
oscMessage = [0.05*playVolume, numPhrase, delayPhrase, probPlay, probGlitch, probSlice, shufflePercent, strMsg]
oscMessage.append(count)
oscMessage.extend(eventsMod)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out

oscStrAddr = "/song/vocals/chop1"

# Close the chuck instance of that instrument
if playInstr == 0:
    client.send_message(oscStrAddr+"/kill", [playInstr])
else:
    if stopNum == 0:
        client.send_message(oscStrAddr,  oscMessage)
    else:
        client.send_message(oscStrAddr, [stopNum])