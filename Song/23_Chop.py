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

# ==== Send out 
posVal1 = [4,10]
dur1 = 2
posVal2 = [4,10]
dur2 = 2
posVal3 = [4,10]
dur3 = 2
posVal4 = [4,10]
dur4 = 2

phraseNumDivs = 4 * 16     

# Instrumentation

posVal = [[4, 10], [4, 10], [4, 10], [4,10]]
# dur = [[2, 2], [2, 2], [2, 2], [2, 2]]
dur = [[99, 99], [99, 99], [99, 99], [99, 99]]
slice = [[0, 0], [0, 0], [0, 0], [0, 0]]
notes = [[Library.MIDIROOTNOTE, Library.MIDIROOTNOTE], [Library.MIDIROOTNOTE, Library.MIDIROOTNOTE], [Library.MIDIROOTNOTE, Library.MIDIROOTNOTE], [Library.MIDIROOTNOTE, Library.MIDIROOTNOTE]]

# Don't want and emphasis but need the elements
posEmphasis = Library.fillWith(posVal, 1.0)

# Combine the 4 bars
events, count = Library.combineBars(posVal, notes, dur, posEmphasis, slice, maskArray)

# Sort out the duration so that plays as one instrument
eventsMod = Library.checkDuration(events, count, phraseNumDivs)

#  Build the OSC Message
oscMessage = [0.1*playVolume, numPhrase, delayPhrase, probVal, shufflePercent]
oscMessage.append(count)
oscMessage.extend(eventsMod)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

if stopNum == 0:
    client.send_message("/song/vocals/chop3", oscMessage)
else:
    client.send_message("/song/vocals/chop3", [stopNum])

# if isinstance(revMix, float):
#     client.send_message("/song/vocals/chop3/reverb", [revMix])

