#!../.venv/bin/python
from typing import List, Any
from pythonosc.udp_client import SimpleUDPClient
import sys
import time
import Library

# Read in any command line variables
playPhrase, playVolume, numPhrase, maskArray, delayPhrase, stopNum, freqRatio, playInstr, probPlay, probGlitch, probSlice, shufflePercent, strMsg, waitTime = Library.decodeInstrArg(sys.argv)

# Set up server and client for testing
client = SimpleUDPClient(Library.SENDIP, Library.SENDPORT)

barNumDivs = 16
phraseNumDivs = barNumDivs * 4

rootNote = Library.MIDIROOTNOTE
if playPhrase < 1:

    posVal = [[0, 3, 6, 11, 14], [0, 3, 6, 11, 14], [0, 3, 6, 11, 14], [0, 3, 6, 11, 14]]
    dur = Library.fillWith(posVal, 99)
    slice = Library.fillWith(posVal, 0)
    notes = Library.fillWith(posVal, rootNote)
    posEmphasis = Library.calcEmphasis(posVal, 4, 0.5, 0.25)

    # Additional arrays to influence instrument behaviour
    effectArray1 = Library.fillWith(posVal, 1.0)
    effectArray2 = Library.fillWith(posVal, 1.0)

    events, count = Library.combineBars(barNumDivs, posVal, notes, dur, posEmphasis, slice, effectArray1, effectArray2, maskArray)

    # Sort out the duration so that plays as one instrument
    eventsMod = Library.checkDuration(events, count, phraseNumDivs)

else:
    posVal = [[0, 3, 6], [0, 3, 6], [0, 3, 6], [0, 3, 6]]
    dur = Library.fillWith(posVal, 99)
    slice = Library.fillWith(posVal, 0)
    notes = Library.fillWith(posVal, rootNote)
    posEmphasis = Library.calcEmphasis(posVal, 4, 0.5, 0.25)

    # Additional arrays to influence instrument behaviour
    effectArray1 = Library.fillWith(posVal, 1.0)
    effectArray2 = Library.fillWith(posVal, 1.0)

    events, count = Library.combineBars(barNumDivs, posVal, notes, dur, posEmphasis, slice, effectArray1, effectArray2, maskArray)

    # Sort out the duration so that plays as one instrument
    eventsMod = Library.checkDuration(events, count, phraseNumDivs)

#  Build the OSC Message
oscMessage = [0.1*playVolume, numPhrase, delayPhrase, probPlay, probGlitch, probSlice, shufflePercent, strMsg]
oscMessage.append(count)
oscMessage.extend(eventsMod)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 
oscStrAddr = "/song/drums/kick"

# Close the chuck instance of that instrument
if playInstr == 0:
    client.send_message(oscStrAddr+"/kill", [playInstr])
else:
    if stopNum == 0:
        client.send_message(oscStrAddr,  oscMessage)
    else:
        client.send_message(oscStrAddr, [stopNum])

