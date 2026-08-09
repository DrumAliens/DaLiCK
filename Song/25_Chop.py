#!../.venv/bin/python
from typing import List, Any
from pythonosc.udp_client import SimpleUDPClient
from pythonosc.dispatcher import Dispatcher
from pythonosc.osc_server import ThreadingOSCUDPServer
import sys
import time
import Library

# Read in any command line variables
playPhrase, playVolume, numPhrase, maskArray, delayPhrase, stopNum, freqRatio, playInstr, probVal, shufflePercent, waitTime = Library.decodeInstrArg(sys.argv)

# Set up server and client for testing
client = SimpleUDPClient(Library.SENDIP, Library.SENDPORT)

# ==== Send out 
phraseNumDivs = 4 * 16  

# Instrumentation
posVal = [[3], [3], [3], [3]]
dur = [[1], [1], [1], [1]]
slice = [[0], [0], [0], [0]]
notes = [[Library.MIDIROOTNOTE], [Library.MIDIROOTNOTE], [Library.MIDIROOTNOTE], [Library.MIDIROOTNOTE]]
 
# Don't want and emphasis but need the elements
posEmphasis = Library.fillWith(posVal, 1.0)

# Combine the 4 bars
events, count = Library.combineBars(posVal, notes, dur, posEmphasis, slice, maskArray)

# Sort out the duration so that plays as one instrument
eventsMod = Library.checkDuration(events, count, phraseNumDivs)

#  Build the OSC Message
oscMessage = [0.11*playVolume, numPhrase, delayPhrase, probVal, shufflePercent]
oscMessage.append(count)
oscMessage.extend(eventsMod)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

if stopNum == 0:
    client.send_message("/song/vocals/chop5", oscMessage) 
else:
    client.send_message("/song/vocals/chop5", [stopNum])
