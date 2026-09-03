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

phraseNumDivs = 128

midiNote = Library.rateToMidiNote(1.29)
posVal = [[0, 2, 4, 6, 8, 10, 12, 14], [0, 2,  4,  6,  8, 10, 12, 14], [0, 2, 4, 6, 8, 10, 12, 14], [0, 2,  4,  6,  8, 10, 12, 14], [0, 2, 4, 6, 8, 10, 12, 14], [0, 2,  4,  6,  8, 10, 12, 14], [0, 2, 4, 6, 8, 10, 12, 14], [0, 2,  4,  6,  8, 10, 12, 14]]  
slice =  [[0, 1, 2, 3, 4,  5,  6,  7], [8, 9, 10, 11, 12, 13, 14, 15], [0, 1, 2, 3, 4,  5,  6,  7], [8, 9, 10, 11, 12, 13, 14, 15], [0, 1, 2, 3, 4,  5,  6,  7], [8, 9, 10, 11, 12, 13, 14, 15], [0, 1, 2, 3, 4,  5,  6,  7], [8, 9, 10, 11, 12, 13, 14, 15]]
dur = Library.fillWith(posVal, 2)
notes = Library.fillWith(posVal, midiNote)
posEmphasis = Library.fillWith(posVal, 1.0)

# Additional arrays to influence instrument behaviour
effectArray1 = Library.fillWith(posVal, 1.0)
effectArray2 = Library.fillWith(posVal, 1.0)

stop = len(posVal)
if stop > 0 :
    posEmphasis = Library.fillWith(posVal, 1.0)
    events, count = Library.combineBars(posVal, notes, dur, posEmphasis, slice, effectArray1, effectArray2, maskArray)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 
if stopNum == 0:

    # Sort out the duration so that plays as one instrument
    eventsMod = Library.checkDuration(events, count, phraseNumDivs)

    #  Build the OSC Message
    oscMessage = [0.75*0.08*playVolume, numPhrase, delayPhrase, probPlay, probGlitch, probSlice, shufflePercent]
    oscMessage.append(count)
    oscMessage.extend(events)
    client.send_message("/song/sounds/frogs_glitch", oscMessage)
else:
    client.send_message("/song/sounds/frogs_glitch", [stopNum])

# close the chuck instance of that instrument
if playInstr != 1:
    client.send_message("/song/sounds/frogs_glitch/kill", [playInstr])
