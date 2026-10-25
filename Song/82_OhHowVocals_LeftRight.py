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

sleepTime = 0.1
barNumDivs = 3

#  Intro
rootNote = Library.MIDIROOTNOTE
rootNote = Library.rateToMidiNote(0.97)
emphasisL = 1.0
emphasisR = 1.0

posValL =   [[], [], [], [], [], [], [0], [], [2], [], [0, 2], [], [0], [], [0], [], [0], []]  
sliceValL = [[], [], [], [], [], [], [0], [], [1], [], [2, 3], [], [4], [], [5], [], [6], []]  
durL =      [[], [], [], [], [], [], [8], [], [4], [], [2, 4], [], [6], [], [6], [], [6], []]

posValR =   [[0], [], [0], [], [0], [], [], [], [], [], [], [], [0], [], [2], [], [0, 2], []]  
sliceValR = [[4], [], [5], [], [5], [], [], [], [], [], [], [], [0], [], [1], [], [2, 3], []]  
durR =      [[6], [], [6], [], [6], [], [], [], [], [], [], [], [8], [], [4], [], [2, 4], []]

if playPhrase == 1:
    posValR =   [[], [], [], [], [], [], [], [], [], [], [], [], [0], [], [2], [], [0, 2], []]  
    sliceValR = [[], [], [], [], [], [], [], [], [], [], [], [], [0], [], [1], [], [2, 3], []]  
    durR =      [[], [], [], [], [], [], [], [], [], [], [], [], [8], [], [4], [], [2, 4], []]

if playPhrase == 2:
    # Stop the left hand playing 
    # Done it this way so don't split the two channels into separate python scripts
    emphasisL = 0.0

    posValR =   [[0], [], [0], [], [0], [], [], [], [], [], [], [], [], [], [], [], [], []]  
    sliceValR = [[4], [], [5], [], [6], [], [], [], [], [], [], [], [], [], [], [], [], []]  
    durR =      [[6], [], [6], [], [6], [], [], [], [], [], [], [], [], [], [], [], [], []]

notesL = Library.fillWith(posValL, rootNote)
notesR = Library.fillWith(posValR, rootNote)

# Additional arrays to influence instrument behaviour
effectArray1L = Library.fillWith(posValL, 1.0)
effectArray2L = Library.fillWith(posValL, 0.0)
effectArray1R = Library.fillWith(posValR, 1.0)
effectArray2R = Library.fillWith(posValR, 1.0)

posEmphasisL = Library.fillWith(posValL, emphasisL)
posEmphasisR = Library.fillWith(posValR, emphasisR)

stop = len(posValL)
if stop > 0 :
    eventsL, countL = Library.combineBars(barNumDivs, posValL, notesL, durL, posEmphasisL, sliceValL, effectArray1L, effectArray2L, maskArray)
    eventsR, countR = Library.combineBars(barNumDivs, posValR, notesR, durR, posEmphasisR, sliceValR, effectArray1R, effectArray2R, maskArray)

# Sort the order to make one instrument
events, count = Library.sortBars(eventsL, countL, eventsR, countR)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 

oscStrAddr = "/song/sounds/ohhowvocals_leftright"

# close the chuck instance of that instrument
if playInstr == 0:
    client.send_message(oscStrAddr + "/kill", [playInstr])
else:    
    if stopNum == 0:

        # Sort out the duration so that plays as one instrument
        # eventsMod = Library.checkDuration(events, count, phraseNumDivs)

        #  Build the OSC Message
        oscMessage = [0.75*0.175*playVolume, numPhrase, delayPhrase, probPlay, probGlitch, probSlice, shufflePercent, strMsg]
        oscMessage.append(count)
        oscMessage.extend(events)
        client.send_message(oscStrAddr, oscMessage)
    else:
        client.send_message(oscStrAddr, [stopNum])
