#!../.venv/bin/python
from typing import List, Any
from pythonosc.udp_client import SimpleUDPClient
import sys
import Library

# Read in any command line variables
playPhrase, playVolume, numPhrase, maskArray, timeArray, delayPhrase, stopNum, freqRatio, playInstr, revMix  = Library.decodeInstrArg(sys.argv)

# Set up server and client for testing
client = SimpleUDPClient(Library.sendIp, Library.sendPort)

# ==== Send out 
if stopNum == 0:
    client.send_message("/song/sounds/planetakeoff", [0.5 * playVolume, freqRatio, delayPhrase])
else:
    client.send_message("/song/sounds/planetakeoff", [stopNum])


