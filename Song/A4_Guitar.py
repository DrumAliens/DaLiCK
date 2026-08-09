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

# maskArray = [0, 0, 0, 1]
# posVal1 = Library.pos2Dec([0])   
# posVal2 = Library.pos2Dec([0])   
# posVal3 = Library.pos2Dec([0])   
# posVal4 = Library.pos2Dec([0])   

    # ORIGINAL CHORDS
    # client.send_message("/song/guitar/guitar", [0.05*playVolume, 44, maskArray[3]*posVal1, 41, maskArray[2]*posVal2, 43, maskArray[1]*posVal3, 48, maskArray[0]*posVal4, numPhrase, delayPhrase])
    # FEEL DANGEROUS UNRESOLVED
    # client.send_message("/song/guitar/guitar", [0.05*playVolume, 41, maskArray[3]*posVal1, 51, maskArray[2]*posVal2, 50, maskArray[1]*posVal3, 49, maskArray[0]*posVal4, numPhrase, delayPhrase])
    # FEELS NICE
    # client.send_message("/song/guitar/guitar", [0.05*playVolume, 41, maskArray[3]*posVal1, 51, maskArray[2]*posVal2, 50, maskArray[1]*posVal3, 51, maskArray[0]*posVal4, numPhrase, delayPhrase])
    # GOES WITH FUNKY BASS LINE
    # client.send_message("/song/guitar/guitar", [0.05*playVolume, 41, numPhrase, delayPhrase, maskArray[3]*posVal1, 51, maskArray[2]*posVal2, 50, maskArray[1]*posVal3, 50, maskArray[0]*posVal4, ])
    # client.send_message("/song/guitar/guitar", [0.05*playVolume, 41, maskArray[3]*posVal1, 48, maskArray[2]*posVal2, 50, maskArray[1]*posVal3, 51, maskArray[0]*posVal4, numPhrase, delayPhrase])


posVal1 = [0, 3, 6, 12, 14]   
posVal2 = [0, 3, 6, 12]   
posVal3 = [0, 3, 6, 12, 14]   
posVal4 = [0, 3, 6, 12]   
notes1 = 41
notes2 = 51
notes3 = 51
notes4 = 50
dur1 = [2, 2, 3, 2, 2]
dur2 = [2, 2, 3, 2]
dur3 = [2, 2, 3, 2, 2]
dur4 = [2, 2, 3, 2]

# 2 chords F and D#
posVal1 = [0]   
posVal2 = []   
posVal3 = [0]   
posVal4 = []   
# notes1 = 41
# notes2 = 51
# notes3 = 51
# notes4 = 50
dur1 = [32]
dur2 = [16]
dur3 = [32]
dur4 = [16]


# Original Dustin chords 
# notes1 = 44
# notes2 = 41
# notes3 = 43
# notes4 = 48

# notes1 = [41]
# notes2 = [43]
# notes3 = [44]
# notes4 = [43]    

# notes1 = [41]
# notes2 = [51]
# notes3 = [50]
# notes4 = [49]
# notes4 = [48]
# notes4 = [51]

# if (playPhrase == 1):
#     posVal1 = [0]   
#     posVal2 = [0]   
#     posVal3 = [0]   
#     posVal4 = [0,12]   
#     dur1 = [16]
#     dur2 = [16]
#     dur3 = [16]
#     dur4 = [11,4]
#     # notes4 = [49, 51]
# elif (playPhrase == 2):
#     posVal1 = [0, 3, 6, 12, 14]   
#     posVal2 = [0, 3, 6, 12]   
#     posVal3 = [0, 3, 6, 12, 14]   
#     posVal4 = [0, 3, 6, 12]   
#     dur1 = [2, 2, 3, 2, 2]
#     dur2 = [2, 2, 3, 2]
#     dur3 = [2, 2, 3, 2, 2]
#     dur4 = [2, 2, 3, 2]    
# elif (playPhrase == 3):
#     posVal1 = [0, 8]   
#     notes1 = [41, 43]
#     posVal2 = [0, 8]
#     notes2 =[51, 48]   
#     posVal3 = [0, 4, 8, 12]
#     notes3 =[46, 48, 41, 41]   
#     posVal4 = []   
#     dur1 = [8, 8]
#     dur2 = [8, 8]
#     dur3 = [4, 4, 4, 4]
#     dur4 = [4, 4, 4, 4]
# elif (playPhrase == 4):
#     posVal1 = [0,   3,  6, 12, 14]   
#     notes1 =  [41, 41, 41, 41, 41]
#     dur1 =    [ 2,  2,  3,  2,  2]
#     posVal2 = [ 0,  3,  6, 12]   
#     notes2 =  [51, 51, 51, 51]
#     dur2 =    [ 2,  2,  3,  2]
#     posVal3 = [ 0,  3, 6, 12, 14]   
#     notes3 =  [49, 49, 51, 51,51]
#     dur3 =    [2, 2, 3, 2, 2]
#     posVal4 = []   
#     notes4 = [50]
#     dur4 =   [2]
# elif (playPhrase == 5):
#     posVal1 = [0,   3,  6, 12, 14]   
#     notes1 =  [41, 41, 41, 41, 41]
#     dur1 =    [ 2,  2,  3,  2,  18]
#     posVal2 = []   
#     posVal3 = [ 0,  3,  6, 12]   
#     notes3 =  [51, 51, 51, 51]
#     dur3 =    [ 2,  2,  3,  20]
#     posVal4 = []   
# elif (playPhrase == 6):
#     posVal1 = [0,   3,  6, 12, 14]   
#     notes1 =  [41, 41, 41, 41, 41]
#     dur1 =    [ 2,  2,  3,  2,  2]
#     posVal2 = [ 0,  3,  6, 12]   
#     notes2 =  [51, 51, 51, 51]
#     dur2 =    [ 2,  2,  3,  2]
#     posVal3 = [0]
#     notes3 = [51]   
#     dur3 = [32]
#     posVal4 = []   
# elif (playPhrase == 7):
#     posVal1 = [0]   
#     notes1 = [41]
#     posVal2 = [0]
#     notes2 =[51]   
#     posVal3 = [0]
#     notes3 = [49]   
#     posVal4 = [0]
#     notes4 =[48]   
#     dur1 = [16]
#     dur2 = [16]
#     dur3 = [16]
#     dur4 = [16]   
# elif (playPhrase == 8):
#     posVal1 = [0,4,8,12]   
#     dur1 = [2,2,2,2]
#     notes1 = [41, 41, 41,41]
#     posVal2 = [0]
#     notes2 =[40]   
#     posVal3 = [0]
#     notes3 = [50]   
#     posVal4 = [0]
#     notes4 =[50]   
#     dur2 = [16]
#     dur3 = [16]
#     dur4 = [16]      
# else:
#     posVal1 = [0]   
#     notes1 = [41]
#     posVal2 = []   
#     posVal3 = [0]
#     notes3 = [46]   
#     posVal4 = []   
#     dur1 = [32]
#     dur2 = [16]
#     dur3 = [32]
#     dur4 = [16]

# # Automatically work out the emphasis across the bar
# posEmphasis1 = Library.fillOnes(posVal1)
# posEmphasis2 = Library.fillOnes(posVal2)
# posEmphasis3 = Library.fillOnes(posVal3)
# posEmphasis4 = Library.fillOnes(posVal4)

# events = []
# count = 0
# phraseNumDivs = 4 * 16    
# if maskArray[3] > 0:
#     for i in range(len(posVal1)):
#         events.extend([posVal1[i], notes1[i], dur1[i], posEmphasis1[i], 0])
#         count += 1
# if maskArray[2] > 0:
#     for i in range(len(posVal2)):
#         events.extend([posVal2[i] + 16, notes2[i], dur2[i], posEmphasis2[i], 0])
#         count += 1
# if maskArray[1] > 0:
#     for i in range(len(posVal3)):
#         events.extend([posVal3[i] + 32, notes3[i], dur3[i], posEmphasis3[i], 0])
#         count += 1
# if maskArray[0] > 0:
#     for i in range(len(posVal4)):
#         events.extend([posVal4[i] + 48, notes4[i], dur4[i], posEmphasis4[i], 0])
#         count += 1

# # Sort out the duration so that plays as one instrument
# eventsMod = Library.checkDuration(events, count, phraseNumDivs)

# #  Build the OSC Message
# oscMessage = [0.0325*playVolume, numPhrase, delayPhrase, probVal, shufflePercent]
# oscMessage.append(count)
# oscMessage.extend(eventsMod)


# ==== Send out 


posVal = [[0], [], [], []]
dur = [[64], [], [], []]
slice = [[0], [], [], []] 
notes = [[58], [], [], []]

if playPhrase == 2:
    posVal = [[0], [], [0], []]
    dur = [[32], [], [32], []]
    slice = [[0], [], [0], []] 
    notes = [[58], [], [60], []]

# # Instrumentation
# if playPhrase <= 2:
#     posVal = [[0], [], [], []]
#     dur = [[64], [], [], []]
#     slice = [[0], [], [], []] 
#     if playPhrase <= 1:
#        notes = [[54], [], [], []]
#     else:   
#        notes = [[58], [], [], []]
# if playPhrase == 3:
#     posVal = [[0], [], [0], []]
#     dur = [[32], [], [32], []]
#     slice = [[0], [], [0], []] 
#     notes = [[58], [], [56], []]
#     notes = [[58], [], [60], []]

# if playPhrase == 33:
#     posVal = [[], [0], [], [0]]
#     dur = [[], [32], [], [32]]
#     slice = [[], [0], [], [0]] 
#     notes = [[], [53], [], [58]]

# if playPhrase == 4:
#     posVal = [[0], [], [], [], [0], [], [], []]
#     dur = [[64], [], [], [], [64], [], [], []]
#     slice = [[0], [], [], [], [0], [], [], []]
#     notes = [[56], [], [], [], [58], [], [], []]


# if playPhrase == 12:
#     posVal = [[0], [], [], [], [0], [], [], []]
#     dur = [[64], [], [], [], [64], [], [], []]
#     slice = [[0], [], [], [], [0], [], [], []]
#     notes = [[58], [], [], [], [60], [], [], []]

# if playPhrase == 5:
#     posVal = [[0], [0], [0], [0]]
#     dur = [[16], [16], [16], [16]]
#     slice = [[0], [0], [0], [0]] 
#     notes = [[54], [51], [56], [58]]

numBars = len(posVal)
phraseNumDivs = 16 * numBars

# Don't want and emphasis but need the elements
posEmphasis = Library.fillWith(posVal, 1.0)

# Combine the bars of information
events, count = Library.combineBars(posVal, notes, dur, posEmphasis, slice, maskArray)

# Sort out the duration so that plays as one instrument
# eventsMod = Library.checkDuration(events, count, phraseNumDivs)

#  Build the OSC Message
oscMessage = [0.04*playVolume, numPhrase, delayPhrase, probVal, shufflePercent, phraseNumDivs]
oscMessage.append(count)
oscMessage.extend(events)
# oscMessage.extend(eventsMod)

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

if stopNum == 0:
    client.send_message("/song/guitar/guitar2", oscMessage)
    # client.send_message("/song/guitar/guitar", [0.05*playVolume, 41, maskArray[3]*posVal1, 48, maskArray[2]*posVal2, 50, maskArray[1]*posVal3, 51, maskArray[0]*posVal4, numPhrase, delayPhrase])
else:
    client.send_message("/song/guitar/guitar2", [stopNum])
