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

dur = 999999
phraseNumDivs = 16 * 4  

events = []
count = 0

rootNote = Library.MIDIROOTNOTE
if playPhrase < 1:
    posVal1 = [4, 12]
    posVal2 = [4, 12, 14]
    posVal3 = [4, 12]
    posVal4 = [4, 12, 14]

    # Automatically work out the emphasis across the bar
    posEmphasis1 = Library.calcEmphasis(posVal1, 4, 0.5, 0.25)
    posEmphasis2 = Library.calcEmphasis(posVal2, 4, 0.5, 0.25)
    posEmphasis3 = Library.calcEmphasis(posVal3, 4, 0.5, 0.25)
    posEmphasis4 = Library.calcEmphasis(posVal4, 4, 0.5, 0.25)

    if maskArray[3] > 0:
        for i in range(len(posVal1)):
            events.extend([posVal1[i], rootNote, dur, posEmphasis1[i], 0])
            count += 1
    if maskArray[2] > 0:
        for i in range(len(posVal2)):
            events.extend([posVal2[i] + 16, rootNote, dur, posEmphasis2[i], 0])
            count += 1
    if maskArray[1] > 0:
        for i in range(len(posVal3)):
            events.extend([posVal3[i] + 32, rootNote, dur, posEmphasis3[i], 0])
            count += 1
    if maskArray[0] > 0:
        for i in range(len(posVal4)):
            events.extend([posVal4[i] + 48, rootNote, dur, posEmphasis4[i], 0])
            count += 1

    # Sort out the duration so that plays as one instrument
    eventsMod = Library.checkDuration(events, count, phraseNumDivs)

else:
    posVal = [[4], [4], [4], [0, 3, 4, 11, 12]]
    durVal = [[8], [8], [8], [2, 1, 4, 1, 4]]
    midiVal = [[rootNote], [rootNote], [rootNote], [rootNote, rootNote,rootNote, rootNote, rootNote]]
    posEmphasis = [[0.5], [0.5], [0.5], [1, 1, 1.0, 0.25, 1.0]]
    sliceVal = [[0], [0], [0], [0, 0, 0, 0, 0]]  

    posVal = [[], [], [], [11, 12]]
    durVal = [[], [], [], [4, 4]]
    midiVal = [[], [], [], [rootNote, rootNote]]
    posEmphasis = [[], [], [], [.25, 0.5]]
    sliceVal = [[], [], [], [0,0]]  

    eventsMod, count = Library.combineBars(posVal, midiVal, durVal, posEmphasis, sliceVal, maskArray)

#  Build the OSC Message
oscMessage = [0.35*playVolume, numPhrase, delayPhrase, probVal, shufflePercent]
oscMessage.append(count)
oscMessage.extend(eventsMod)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 
if stopNum == 0:
    client.send_message("/song/drums/snare",  oscMessage)
else:
    client.send_message("/song/drums/snare", [stopNum])

# close the chuck instance of that instrument
if playInstr != 1:
    client.send_message("/song/drums/snare/kill", [playInstr])