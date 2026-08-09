#!../.venv/bin/python
import socket, errno
import copy
from typing import List, Any

# ======================================
# User defined the network ip addresses
# ======================================
LISTENIP = '127.0.0.1'
LISTENPORT = 49163
SENDIP   = '127.0.0.1'
SENDPORT = 49162
REPLAYPORT = LISTENPORT + 1
REPLAYPORTNUM = 9
MIDIROOTNOTE = 72

def pos2Dec(array):
    decVal = 0
    for val in array:
        decVal += 2**val

    return decVal     

def dec2Bin(val):
    array = 4*[0]
    if (val > 0):
        for i in range(len(array)):
            array[i] = int(val % 2)
            val = val / 2

    return array        

def set_filter(address: str, *args: List[Any]) -> None:
    # Check input length and type
    if not len(args) == 1 or type(args[0]) is not int:
        return

    # Check that address 
    if not address == "/song/internal/phrase":  # Cut off the last character
        return

# Decode the command line data for the instrument functions
def decodeInstrArg(argv):
    # Read in any command line variables
    playPhrase = 0
    playVolume = 1.0
    numPhrase = 99999999
    maskArray = dec2Bin(15)
    delayPhrase = 0
    stopNum = 0
    freqRatio = 1.0
    playInstr = 1
    probVal = 1.0
    shufflePrecent = 50.0
    waitTime = 0.0
    # revMix = 'a'
    for indx in range(len(argv)):
        string = str(argv[indx])
        # Instrument commands
        if 'p' in string[0].lower():
            playPhrase = int(string[1:])
        if 'v' in string[0].lower():
            playVolume = float(string[1:])
        if 'r' in string[0].lower():
            numPhrase = int(string[1:])
        if 'm' in string[0].lower():
            maskArray = dec2Bin(int(string[1:]))
        if 'd' in string[0].lower():
            delayPhrase = int(string[1:])
        if 's' in string[0].lower():
            stopNum = int(string[1:])
        if 'f' in string[0].lower():
            freqRatio = float(string[1:])
        if 'c' in string[0].lower():
            # Limit probability to be between 0.0 and 1.0
            probVal = min(max(float(string[1:]), 0.0), 1.0)
        if 'h' in string[0].lower():
            # Limit shuffle to be between 50% and 75%
            shufflePrecent = min(max(float(string[1:]), 50.0), 75.0)
        if 'w' in string[0].lower():
            waitTime = float(string[1:])

        if 'kill' in string[0:4].lower():
            playInstr = 0    

    return playPhrase, playVolume, numPhrase, maskArray, delayPhrase, stopNum, freqRatio, playInstr, probVal, shufflePrecent, waitTime

# Decode the command line data for the song structure
def decodeSongStructArg(argv):
    # Read in any command line variables
    numBeats = 16
    beatDivision = 4
    # Original Dustin Speed
    songTempo = 60 / (4 * 0.155)

    for indx in range(len(argv)):
        string = str(argv[indx])
        # Instrument commands
        if 'n' in string[0].lower():
            numBeats = int(string[1:])
        if 'd' in string[0].lower():
            beatDivision = int(string[1:])
        if 't' in string[0].lower():
            songTempo = float(string[1:])

    return numBeats, beatDivision, songTempo

# Decode the command line data for the fading function
def decodeFadeArg(argv):
    # Read in any command line variables
    fadeDur = 0
    maskDec = 0
    waitTime = 0
    for indx in range(len(argv)):
        string = str(argv[indx])
        if 'd' in string[0].lower():
            fadeDur = float(string[1:])
        if 'm' in string[0].lower():
            maskDec = int(string[1:])
        if 'w' in string[0].lower():
            waitTime = float(string[1:])
 
    return fadeDur, maskDec, waitTime

# Check the duration so that it doesn't overlap and plays as one instrument
def checkDuration(events, count, numBeats):

    pos = []
    notes = []
    durRaw = []
    ampRaw = []
    slice = []
    indx = 5
    # Extract all of the data back out into new rows
    for i in range(count):
        pos.append(events[0 + i * indx])
        notes.append(events[1 + i * indx])
        durRaw.append(events[2 + i * indx])
        ampRaw.append(events[3 + i * indx])
        slice.append(events[4 + i * indx])

    # Work out the duration
    durNew = []
    for i in range(count-1):
        durNew.append(min(durRaw[i], pos[i+1] - pos[i]))
    durNew.append(min(durRaw[-1], numBeats - pos[-1] + pos[0]))
    
    # The calculated value of sum should be equal or less than numBeats
    # sum = 0
    # for i in durNew:
    #     sum = sum + i
    # print(sum)    

    # Push the duration back into the data set
    for i in range(count):
        events[2 + i * indx] = durNew[i]
    
    return events

# Sorts of the relative emphasis across a bar
# allows more emphasis one the first beat and then different levels 
# on and off the beat
def calcEmphasis(posVal, numBeats, minorBeat, otherBeat):
    res = []
    for i in range(len(posVal)):
        # Maximum emphasis to first beat in the bar
        if posVal[i] == 0:
            res.append(1.0)
        # the other on beats 
        elif posVal[i] % numBeats == 0:
            res.append(minorBeat)
        # everything else
        else:
            res.append(otherBeat)        
    
    return res

    
# Fill a siilar sized array/list with 1.0's
def fillOnes(posVal):
    res = []
    for i in range(len(posVal)):
        res.append(1.0)
    
    return res    

# Fill a siilar sized array/list with loclVal
def fillWith(posVal, loclVal):
    res = copy.deepcopy(posVal)
    for i in range(len(posVal)):
        for j in range(len(posVal[i])):
            res[i][j] = loclVal
    return res

# Combine 4 bars of instrumentation to create a complete set of information
def combine4Bars(posVal, notes, dur, posEmphasis, slice, maskArray):
    events = []
    count = 0
    indx = 0
    if maskArray[3] > 0:
        for i in range(len(posVal[indx])):
            events.extend([posVal[indx][i], notes[indx][i], dur[indx][i], posEmphasis[indx][i], slice[indx][i]])
            count += 1
    indx += 1
    if maskArray[2] > 0:
        for i in range(len(posVal[indx])):
            events.extend([posVal[indx][i] + 16, notes[indx][i], dur[indx][i], posEmphasis[indx][i], slice[indx][i]])
            count += 1
    indx += 1
    if maskArray[1] > 0:
        for i in range(len(posVal[indx])):
            events.extend([posVal[indx][i] + 32, notes[indx][i], dur[indx][i], posEmphasis[indx][i], slice[indx][i]])
            count += 1
    indx += 1
    if maskArray[0] > 0:
        for i in range(len(posVal[indx])):
            events.extend([posVal[indx][i] + 48, notes[indx][i], dur[indx][i], posEmphasis[indx][i], slice[indx][i]])
            count += 1

    return events, count


# Combine bars of instrumentation to create a complete set of information
def combineBars(posVal, notes, dur, posEmphasis, slice, maskArray):
    events = []
    count = 0
    div = 0
    arrayIndx = 3
    for indx in range(len(posVal)):
        if maskArray[arrayIndx] > 0:
            for i in range(len(posVal[indx])):
                events.extend([posVal[indx][i] + div, notes[indx][i], dur[indx][i], posEmphasis[indx][i], slice[indx][i]])
                count += 1
        div += 16
        arrayIndx -= 1
        # Reset the indx counter
        if arrayIndx < 0:
            arrayIndx = 3

    return events, count




