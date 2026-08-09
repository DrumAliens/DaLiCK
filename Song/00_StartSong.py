#!../.venv/bin/python
from pythonosc.udp_client import SimpleUDPClient
import sys
import Library

numBeats, beatDivision, songTempo = Library.decodeSongStructArg(sys.argv)

# =================================
# Send out the OSC port to Chuck
# =================================
# Set up server and client for testing
client = SimpleUDPClient(Library.SENDIP, Library.SENDPORT)

# ==== Send out master message
# Original Dustin Speed
# tempo = 60 / (4 * 0.155)

#  Rain speed
# tempo = 146.0
client.send_message("/song/master/setup", [numBeats, beatDivision, songTempo])

