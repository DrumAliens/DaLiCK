#!../.venv/bin/python
from typing import List, Any
from pythonosc.udp_client import SimpleUDPClient
import sys
import time
import Library

# Read in any command line variables
playPhrase, playVolume, numPhrase, maskArray, delayPhrase, stopNum, freqRatio, playInstr, probVal, shufflePercent, waitTime = Library.decodeInstrArg(sys.argv)

# ==== Send out
client = SimpleUDPClient(Library.SENDIP, Library.SENDPORT)

# ==== Send out 
phraseNumDivs = 4 * 16

# Instrumentation
posVal = [[0], [0], [0], [0]]
dur = Library.fillWith(posVal, 3)
slice = Library.fillWith(posVal, 0)
notes = Library.fillWith(posVal, Library.MIDIROOTNOTE)
# Don't want and emphasis but need the elements
posEmphasis = Library.fillWith(posVal, 1.0)

# Combine the bars together
events, count = Library.combineBars(posVal, notes, dur, posEmphasis, slice, maskArray)

# Ensures that the durations don't clash with each other
eventsMod = Library.checkDuration(events, count, phraseNumDivs)

#  Build the OSC Message
oscMessage = [0.05*playVolume, numPhrase, delayPhrase, probVal, shufflePercent]
oscMessage.append(count)
oscMessage.extend(eventsMod)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

if stopNum == 0:
    client.send_message("/song/vocals/chop1", oscMessage)
else:
    client.send_message("/song/vocals/chop1", [stopNum])
