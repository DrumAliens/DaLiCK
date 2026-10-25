#!../.venv/bin/python
from typing import List, Any
from pythonosc.udp_client import SimpleUDPClient
from pythonosc.dispatcher import Dispatcher
from pythonosc.osc_server import ThreadingOSCUDPServer
import sys
import time
import Library

# Read in any command line variables
playPhrase, playVolume, numPhrase, maskArray, delayPhrase, stopNum, freqRatio, playInstr, probPlay, probGlitch, probSlice, shufflePercent, strMsg, waitTime = Library.decodeInstrArg(sys.argv)

# Set up server and client for testing
client = SimpleUDPClient(Library.SENDIP, Library.SENDPORT)

# ==== Send out 

# Instrumentation
posVal = [[0], [], [], []]
dur = [[64], [], [], []]
slice = [[0], [], [], []] 
notes = [[51], [], [], []]

if playPhrase == 2:
    posVal = [[0], [], [0], []]
    dur = [[32], [], [32], []]
    slice = [[0], [], [0], []] 
    notes = [[54], [], [56], []]


# Additional arrays to influence instrument behaviour
effectArray1 = Library.fillWith(posVal, 1.0)
effectArray2 = Library.fillWith(posVal, 1.0)

numBars = len(posVal)
barNumDivs = 16
phraseNumDivs = barNumDivs * numBars

# Don't want and emphasis but need the elements
posEmphasis = Library.fillWith(posVal, 1.0)

# Combine the bars of information
events, count = Library.combineBars(barNumDivs, posVal, notes, dur, posEmphasis, slice, effectArray1, effectArray2, maskArray)

# Sort out the duration so that plays as one instrument
# eventsMod = Library.checkDuration(events, count, phraseNumDivs)

#  Build the OSC Message
oscMessage = [0.03*playVolume, numPhrase, delayPhrase, probPlay, probGlitch, probSlice, shufflePercent, strMsg] #, phraseNumDivs]
oscMessage.append(count)
oscMessage.extend(events)
# oscMessage.extend(eventsMod)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out

oscStrAddr = "/song/guitar/guitar1"

# Close the chuck instance of that instrument
if playInstr == 0:
    client.send_message(oscStrAddr+"/kill", [playInstr])
else:
    if stopNum == 0:
        client.send_message(oscStrAddr,  oscMessage)
    else:
        client.send_message(oscStrAddr, [stopNum])