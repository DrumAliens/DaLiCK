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

posVal1 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]  
sliceVal1 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]  
posVal2 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]  
sliceVal2 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]  
posVal3 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]  
sliceVal3 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]  
posVal4 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]  
sliceVal4 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]  
dur = 32

# Automatically work out the emphasis across the bar
# Don't need to do this for the cymbals as they are from a loop
posEmphasis1 = Library.fillOnes(posVal1)
posEmphasis2 = Library.fillOnes(posVal2)
posEmphasis3 = Library.fillOnes(posVal3)
posEmphasis4 = Library.fillOnes(posVal4)

phraseNumDivs = 4 * 16   
events = []
count = 0

rootNote = Library.MIDIROOTNOTE
if playPhrase < 1:
    if maskArray[3] > 0:
        for i in range(len(posVal1)):
            events.extend([posVal1[i], Library.MIDIROOTNOTE, dur, posEmphasis1[i], sliceVal1[i]])
            count += 1
    if maskArray[2] > 0:
        for i in range(len(posVal2)):
            events.extend([posVal2[i] + 16, Library.MIDIROOTNOTE, dur, posEmphasis2[i], sliceVal2[i]])
            count += 1
    if maskArray[1] > 0:
        for i in range(len(posVal3)):
            events.extend([posVal3[i] + 32, Library.MIDIROOTNOTE, dur, posEmphasis3[i], sliceVal3[i]])
            count += 1
    if maskArray[0] > 0:
        for i in range(len(posVal4)):
            events.extend([posVal4[i] + 48, Library.MIDIROOTNOTE, dur, posEmphasis4[i], sliceVal4[i]])
            count += 1

    # Sort out the duration so that plays as one instrument
    eventsMod = Library.checkDuration(events, count, phraseNumDivs)
else:
    posVal = [[], [], [], [0, 4, 8, 12]]
    durVal = [[], [], [], [4, 4, 4,  4]]
    midiVal = [[], [], [], [rootNote, rootNote, rootNote, rootNote]]
    posEmphasis = [[], [], [], [1.0, 0.5, 0.5, 0.5]]
    sliceVal = [[], [], [], [0, 0, 0, 0]]  

    eventsMod, count = Library.combineBars(posVal, midiVal, durVal, posEmphasis, sliceVal, maskArray)


#  Build the OSC Message
oscMessage = [0.06*playVolume, numPhrase, delayPhrase, probVal, shufflePercent]
oscMessage.append(count)
oscMessage.extend(eventsMod)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 
if stopNum == 0:
    client.send_message("/song/drums/cymbals", oscMessage)
 
else:
    client.send_message("/song/drums/cymbals", [stopNum])

# close the chuck instance of that instrument
if playInstr != 1:
    client.send_message("/song/drums/cymbals/kill", [playInstr])
