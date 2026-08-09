#!../.venv/bin/python
from typing import List, Any
from pythonosc.udp_client import SimpleUDPClient
import sys
import time
import Library

sleepTime = 0.1

# Read in any command line variables
playPhrase, playVolume, numPhrase, maskArray, delayPhrase, stopNum, freqRatio, playInstr, probVal, shufflePercent, waitTime = Library.decodeInstrArg(sys.argv)

# Set up server and client for testing
client = SimpleUDPClient(Library.SENDIP, Library.SENDPORT)

#  Intro
phraseNumDivs = 128
if playPhrase <= 1:
    posValL =  [ 0, 76, 96]  
    midiValL = [67, 67, 67]     
    sliceValL = [0,  0,  0]  
    durL =      [4,  4,  4]

    posValR =  [28, 52, 80]  
    midiValR = [68, 68, 68]     
    sliceValR = [0,  0, 0]  
    durR =      [4,  4, 4]

# Intro plus 0-127
if playPhrase == 2:
    posValL =  [32, 64]  
    midiValL = [67, 60]     
    sliceValL = [0,  6]  
    durL =      [4,  4]

    posValR =  [ 0, 36, 40, 100, 116]  
    midiValR = [68, 68, 68,  68,  68]     
    sliceValR = [0,  0,  6,   6,   1]  
    durR =      [4,  4,  4,   4,   4]

# Intro plus 128 - 255
if playPhrase == 3:
    posValL =  [16,	  32,  48,  56,  64,  72,  80,  88,  96, 104, 112, 120]  
    midiValL = [67,   67,  60,  67,  67,  60,  67,  67,  67,  67,  67,  67]     
    sliceValL = [0,    0,   0,   1,   0,   6,   0,   1,   0,   6,   0,   1]  
    durL =      [4,    4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4]

    posValR =  [  4,   8,  20,  24,  36,  40,  52,  60,  68,  84, 100, 116, 124]  
    midiValR = [ 68,  68,  68,  68,  68,  68,  68,  68,  68,  68,  61,  68,  68]     
    sliceValR = [ 0,   6,   0,   1,   0,   6,   0,   2,   0,   0,   0,   0,   2]  
    durR =      [ 4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4]

# playPhrase 3 swapped left and right
if playPhrase == 33:
    posValL =  [  4,   8,  20,  24,  36,  40,  52,  60,  68,  84, 100, 116, 124]  
    midiValL = [ 67,  67,  67,  67,  67,  67,  67,  67,  67,  67,  60,  67,  67]     
    sliceValL = [ 0,   6,   0,   1,   0,   6,   0,   2,   0,   0,   0,   0,   2]  
    durL =      [ 4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4]    

    posValR =  [16,	  32,  48,  56,  64,  72,  80,  88,  96, 104, 112, 120]  
    midiValR = [68,   68,  61,  68,  68,  61,  68,  68,  68,  68,  68,  68]     
    sliceValR = [0,    0,   0,   1,   0,   6,   0,   1,   0,   6,   0,   1]  
    durR =      [4,    4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4]

# # Intro plus 256 - 383
if playPhrase == 4:
    posValL =  [  0,   8,  16,  24,  32,  40,  48,  56,  64,  72,  80,  88,  96, 104, 112]  
    midiValL = [ 67,  67,  67,  67,  67,  60,  67,  67,  67,  67,  67,  67,  67,  67,  60]     
    sliceValL = [ 0,   6,   0,   1,   0,   6,   0,   1,   0,   6,   0,   1,   0,   6,   0]  
    durL =      [ 4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4]

    posValR =  [  4,  20,  36,  52,  60,  68,  84, 100]  
    midiValR = [ 68,  61,  68,  68,  68,  68,  60,  68]     
    sliceValR = [ 0,   0,   0,   0,   2,   0,   0,   0]  
    durR =      [ 4,   4,   4,   4,   4,   4,   4,   4]

# # Drum Idea 0 - 127
if playPhrase == 5:
    posValL =  [  0,   8,  16,  24,  32,  40,  48,  56,  64,  72,  80,  88,  96, 104, 112, 120]  
    midiValL = [ 67,  67,  67,  67,  67,  60,  67,  67,  67,  67,  67,  67,  60,  67,  67,  67]     
    sliceValL = [ 0,   6,   0,   0,   0,   0,   1,   0,   0,   6,   0,   1,   0,   6,   0,   1]  
    durL =      [ 4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4]

    posValR =  [  4,  20,  28,  36,  44,  60,  68,  84, 100, 116]  
    midiValR = [ 68,  68,  68,  68,  68,  61,  68,  68,  68,  61]     
    sliceValR = [ 0,   0,   0,   0,   0,   0,   0,   0,   0,   0]  
    durR =      [ 4,   4,   4,   4,   4,   4,   4,   4,   4,   4]

# # Test sequence
# if playPhrase == 100:
#     posValL =  [  0,   8,  16,  24,  32,  40,  48,  56,  64,  72,  80,  88,  96, 104, 112, 120]  
#     midiValL = [ 67,  67,  67,  67,  67,  60,  67,  67,  67,  67,  67,  67,  60,  67,  67,  67]     
#     sliceValL = [ 0,   6,   0,   0,   0,   0,   1,   0,   0,   6,   0,   1,   0,   6,   0,   1]  
#     durL =      [ 4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4]

#     posValR =  [  0,   8,  16,  24,  32,  40,  48,  56,  64,  72,  80,  88,  96, 104, 112, 120]  
#     midiValR = [ 67,  67,  67,  67,  67,  60,  67,  67,  67,  67,  67,  67,  60,  67,  67,  67]   
#     sliceValR = [ 0,   6,   0,   0,   0,   0,   1,   0,   0,   6,   0,   1,   0,   6,   0,   1]   
#     durR =      [ 4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4]

# BACKWARDS VERSIONS
# Intro
if playPhrase == 11:
    posValL =  [28, 48, 124]  
    midiValL = [67, 67, 67]     
    sliceValL = [0,  0,  0]  
    durL =      [4,  4,  4]

    posValR =  [44, 72, 96]  
    midiValR = [68, 68, 68]     
    sliceValR = [0,  0, 0]  
    durR =      [4,  4, 4]

# Intro plus 0-127
if playPhrase == 12:
    posValL =  [60, 92]  
    midiValL = [60, 67]     
    sliceValL = [6,  0]  
    durL =      [4,  4]

    posValR =  [ 8, 24, 84,  88, 124]  
    midiValR = [68, 68, 68,  68,  68]     
    sliceValR = [1,  6,  6,   0,   0]  
    durR =      [4,  4,  4,   4,   4]

eventsL = []
countL = 0
for i in range(len(posValL)):
    eventsL.extend([posValL[i], midiValL[i] + 4, durL[i], 1.0, sliceValL[i]])
    countL += 1

eventsR = []
countR = 0
for i in range(len(posValR)):
    eventsR.extend([posValR[i], midiValR[i] + 4, durR[i], 1.0, sliceValR[i]])
    countR += 1

#  Wait to send out the OSC message
if waitTime > 0.0:
    time.sleep(waitTime)

# ==== Send out 
if stopNum == 0:

    #  Build the OSC Message Left
    oscMessage = [0.75*0.15*playVolume, numPhrase, delayPhrase, probVal, shufflePercent]
    oscMessage.append(countL)
    oscMessage.extend(eventsL)
    client.send_message("/song/sounds/frogs_left", oscMessage)

    time.sleep(sleepTime)
    #  Build the OSC Message Right
    oscMessage = [0.15*playVolume, numPhrase, delayPhrase, probVal, shufflePercent]
    oscMessage.append(countR)
    oscMessage.extend(eventsR)

    client.send_message("/song/sounds/frogs_right", oscMessage)
else:
    client.send_message("/song/sounds/frogs_left", [stopNum])

    time.sleep(sleepTime)
    client.send_message("/song/sounds/frogs_right", [stopNum])

# close the chuck instance of that instrument
if playInstr != 1:
    client.send_message("/song/sounds/frogs_left/kill", [playInstr])

    time.sleep(sleepTime)
    client.send_message("/song/sounds/frogs_right/kill", [playInstr])
