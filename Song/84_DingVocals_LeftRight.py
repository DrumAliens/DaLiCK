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

noteLen = 3
#  Intro
# 72		Ding		
# 73		Dong		
# 74		Ding	3rd	Up
# 75		Dong	3rd	Up
# 76		Ding	5th	Up
# 77		Dong	5th	Up

noteLen = 3
rootNote = Library.MIDIROOTNOTE
# rootNote = Library.rateToMidiNote(0.97)

notesL = [[72], [73], [72], [73], [72], [73]]
notesR = [[72], [73], [72], [73], [72], [73]]

if playPhrase == 1:
    notesL = [[74], [77], [74], [77], [74], [77]]
    notesR = [[76], [75], [76], [75], [76], [75]]

posValL =   [[1], [1], [1], [1], [1], [1]]  
posValR =   [[2], [2], [2], [2], [2], [2]]  

if playPhrase == 99:
    notesL = [[72], [73], [72], [73], [72], []]
    notesR = [[72], [73], [72], [73], [72], []]
    posValL =   [[1], [1], [1], [1], [1], []]  
    posValR =   [[2], [2], [2], [2], [2], []]  

dur = Library.fillWith(posValL, noteLen)
sliceVal = Library.fillWith(posValL, 0)
# Additional arrays to influence instrument behaviour
effectArray1L = [[74], [77], [74], [77], [74], [77]]
effectArray1R = [[76], [75], [76], [75], [76], [75]]
effectArray2L = Library.fillWith(posValL, -1.0)
effectArray2R = Library.fillWith(posValL, 1.0)

stop = len(posValL)
if stop > 0 :
    posEmphasis = Library.fillWith(posValL, 1.0)

    eventsL, countL = Library.combineBars(barNumDivs, posValL, notesL, dur, posEmphasis, sliceVal, effectArray1L, effectArray2L, maskArray)

    eventsR, countR = Library.combineBars(barNumDivs, posValR, notesR, dur, posEmphasis, sliceVal, effectArray1R, effectArray2R, maskArray)

# Sort the order to make one instrument
events, count = Library.sortBars(eventsL, countL, eventsR, countR)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 

oscStrAddr = "/song/sounds/dingvocals_leftright"

# close the chuck instance of that instrument
if playInstr == 0:
    client.send_message(oscStrAddr + "/kill", [playInstr])
else:    
    if stopNum == 0:

        # Sort out the duration so that plays as one instrument
        # eventsMod = Library.checkDuration(events, count, phraseNumDivs)

        #  Build the OSC Message
        oscMessage = [0.75*0.1*playVolume, numPhrase, delayPhrase, probPlay, probGlitch, probSlice, shufflePercent, strMsg]
        oscMessage.append(count)
        oscMessage.extend(events)
        client.send_message(oscStrAddr, oscMessage)

    else:
        client.send_message(oscStrAddr, [stopNum])
