#!../.venv/bin/python
from typing import List, Any
from pythonosc.udp_client import SimpleUDPClient
import sys
import Library

# Read in any command line variables
playPhrase, playVolume, numPhrase, maskArray, delayPhrase, stopNum, freqRatio, playInstr, probVal, shufflePercent, waitTime = Library.decodeInstrArg(sys.argv)


# Set up server and client for testing
client = SimpleUDPClient(Library.SENDIP, Library.SENDPORT)

# ==== Send out 
# if stopNum == 0:
#     client.send_message("/song/sounds/thunderstorm", [0.05 * playVolume, freqRatio, delayPhrase, playTime])
# else:
#     client.send_message("/song/sounds/thunderstorm", [stopNum])


posVal =  [  0]  
midiVal = [ Library.MIDIROOTNOTE]     
sliceVal = [ 0]  
dur =      [ 30.0]

if playPhrase > 0:
    posVal =  [ 110]  
    midiVal = [ Library.MIDIROOTNOTE]     
    sliceVal = [ 0]  
    dur =      [ 60.0]

events = []
count = 0
for i in range(len(posVal)):
    events.extend([posVal[i], midiVal[i], dur[i], 1.0, sliceVal[i]])
    count += 1

if stopNum == 0:

    # Sort out the duration so that plays as one instrument
    # eventsMod = Library.checkDuration(events, count, phraseNumDivs)

    #  Build the OSC Message
    oscMessage = [playVolume, numPhrase, delayPhrase, probVal, shufflePercent]
    oscMessage.append(count)
    oscMessage.extend(events)
    client.send_message("/song/sounds/thunder", oscMessage)
else:
    client.send_message("/song/sounds/thunder", [stopNum])


# if stopNum == 0:
#     client.send_message("/song/sounds/thunder", [0.05 * playVolume, numPhrase, probVal, delayPhrase, waitTime])
# else:
#     client.send_message("/song/sounds/thunder", [stopNum])


