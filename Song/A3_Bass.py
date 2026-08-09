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

# Instrumentation
posVal = [[0], [], [], []]
dur = [[4*16], [], [], []]
slice = [[0], [], [], []] 
notes = [[Library.MIDIROOTNOTE], [], [], []]

numBars = len(posVal)
phraseNumDivs = 16 * numBars

# Don't want and emphasis but need the elements
posEmphasis = Library.fillWith(posVal, 1.0)

# Combine the bars of information
events, count = Library.combineBars(posVal, notes, dur, posEmphasis, slice, maskArray)

# Sort out the duration so that plays as one instrument
# eventsMod = Library.checkDuration(events, count, phraseNumDivs)

#  Build the OSC Message
oscMessage = [0.06*playVolume, numPhrase, delayPhrase, probVal, shufflePercent, phraseNumDivs]
oscMessage.append(count)
oscMessage.extend(events)
# oscMessage.extend(eventsMod)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

if stopNum == 0:
    client.send_message("/song/guitar/bass", oscMessage)
    # client.send_message("/song/guitar/guitar", [0.05*playVolume, 41, maskArray[3]*posVal1, 48, maskArray[2]*posVal2, 50, maskArray[1]*posVal3, 51, maskArray[0]*posVal4, numPhrase, delayPhrase])
else:
    client.send_message("/song/guitar/bass", [stopNum])
