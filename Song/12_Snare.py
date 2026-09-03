#!../.venv/bin/python
from typing import List, Any
from pythonosc.udp_client import SimpleUDPClient
import sys
import time
import Library

# Read in any command line variables
playPhrase, playVolume, numPhrase, maskArray, delayPhrase, stopNum, freqRatio, playInstr, probPlay, probGlitch, probSlice, shufflePercent, waitTime = Library.decodeInstrArg(sys.argv)

# Set up server and client for testing
client = SimpleUDPClient(Library.SENDIP, Library.SENDPORT)

dur = 999999
phraseNumDivs = 16 * 4  

events = []
count = 0

rootNote = Library.MIDIROOTNOTE
if playPhrase < 1:
    posVal = [[4, 12], [4, 12, 14], [4, 12], [4, 12, 14]]
    dur = Library.fillWith(posVal, 99)
    slice = Library.fillWith(posVal, 0)
    notes = Library.fillWith(posVal, rootNote)
    posEmphasis = Library.calcEmphasis(posVal, 4, 0.5, 0.25)

    # Additional arrays to influence instrument behaviour
    effectArray1 = Library.fillWith(posVal, 1.0)
    effectArray2 = Library.fillWith(posVal, 1.0)

    events, count = Library.combineBars(posVal, notes, dur, posEmphasis, slice, effectArray1, effectArray2, maskArray)

    # Sort out the duration so that plays as one instrument
    eventsMod = Library.checkDuration(events, count, phraseNumDivs)

#  Build the OSC Message
oscMessage = [0.35*playVolume, numPhrase, delayPhrase, probPlay, probGlitch, probSlice, shufflePercent]
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