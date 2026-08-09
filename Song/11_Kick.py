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

# Apply different drum patterns
# if (playPhrase > 0) or (maskArray[0]*maskArray[1]*maskArray[2]*maskArray[3] == 0):
#     posVal = [0, 3, 6]
# else:
#     posVal = [0, 3, 6, 11, 14]

posVal = [0, 3, 6, 11, 14]
dur = 99999
phraseNumDivs = 16 * 4

# Automatically work out the emphasis across the bar
posEmphasis = Library.calcEmphasis(posVal, 4, 0.5, 0.25)

events = []
count = 0
rootNote = Library.MIDIROOTNOTE
if playPhrase < 1:
    if maskArray[3] > 0:
        for i in range(len(posVal)):
            events.extend([posVal[i], rootNote, dur, posEmphasis[i], 0])
            count += 1
    if maskArray[2] > 0:
        for i in range(len(posVal)):
            events.extend([posVal[i] + 16, rootNote, dur, posEmphasis[i], 0])
            count += 1
    if maskArray[1] > 0:
        for i in range(len(posVal)):
            events.extend([posVal[i] + 32, rootNote, dur, posEmphasis[i], 0])
            count += 1
    if maskArray[0] > 0:
        for i in range(len(posVal)):
            events.extend([posVal[i] + 48, rootNote, dur, posEmphasis[i], 0])
            count += 1
    # Sort out the duration so that plays as one instrument
    eventsMod = Library.checkDuration(events, count, phraseNumDivs)

else:
    posVal = [[0, 3, 6], [0, 3, 6], [0, 3, 6], [0, 3, 6]]
    durVal = [[3,3,10], [3,3,10], [3,3,10], [3,3,10]]
    midiVal = [[rootNote,rootNote, rootNote], [rootNote, rootNote, rootNote], [rootNote,rootNote, rootNote], [rootNote,rootNote, rootNote]]
    posEmphasis = [[1.0, 0.25, 0.5], [1.0, 0.25, 0.5], [1.0, 0.25, 0.5], [1.0, 0.25, 0.5]]
    sliceVal = [[0,0,0], [0,0,0], [0,0,0], [0,0,0]]  

    # posVal = [[], [], [], [10]]
    # durVal = [[], [], [], [10]]
    # midiVal = [[], [], [], [rootNote]]
    # posEmphasis = [[], [], [], [1]]
    # sliceVal = [[], [], [], [0]] 
    eventsMod, count = Library.combineBars(posVal, midiVal, durVal, posEmphasis, sliceVal, maskArray)

#  Build the OSC Message
oscMessage = [0.1*playVolume, numPhrase, delayPhrase, probVal, shufflePercent]
oscMessage.append(count)
oscMessage.extend(eventsMod)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 
if stopNum == 0:
    client.send_message("/song/drums/kick",  oscMessage)
else:
    client.send_message("/song/drums/kick", [stopNum])

# close the chuck instance of that instrument
if playInstr != 1:
    client.send_message("/song/drums/kick/kill", [playInstr])
