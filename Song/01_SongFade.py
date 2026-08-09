#!../.venv/bin/python
from pythonosc.udp_client import SimpleUDPClient
from typing import List, Any
import sys
import time
import Library

# =================================
# Send out the OSC port to Chuck
# =================================

# Set up server and client for testing
client = SimpleUDPClient(Library.SENDIP, Library.SENDPORT)

# ==== Send out ramp message
# rampRate, maskDec  = Library.decodeFadeArg(sys.argv)
# client.send_message("/song/master/fade", [rampRate, maskDec, lowerLimit, upperLimit])
    
fadeDur, maskDec, waitTime  = Library.decodeFadeArg(sys.argv)

if waitTime > 0.0:
    time.sleep(waitTime)

# print(fadeDur, maskDec)
client.send_message("/song/master/fade", [fadeDur, maskDec])

