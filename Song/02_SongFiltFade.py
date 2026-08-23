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

# Decode the command line entry  
fadeDur, waitTime, oscMsgStrList  = Library.decodeFadeArg(sys.argv)

if waitTime > 0.0:
    time.sleep(waitTime)

# Send out specific OSR message
for msgStr in oscMsgStrList:
    client.send_message("/song/master/filt/" + msgStr, [fadeDur])

