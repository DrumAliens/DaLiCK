#!.venv/bin/python
from pythonosc.dispatcher import Dispatcher
from typing import List, Any
from pythonosc.osc_server import ThreadingOSCUDPServer
from pythonosc.udp_client import SimpleUDPClient

def set_filter(address: str, *args: List[Any]) -> None:
    # Check input length and type
    if not len(args) == 1 or type(args[0]) is not int:
        return

    # Check that address 
    if not address == "/song/master/phrase":  # Cut off the last character
        return

    print(f"Phrase #{args[0]}")

def pos2Dec(array):
    decVal = 0
    for val in array:
        decVal += 2**val

    return decVal     

ip = '127.0.0.1'
sendPort = 49162
recPort = 49163

dispatcher = Dispatcher()
dispatcher.map("/song/master/phrase", set_filter)  # Map wildcard address to set_filter function

# Set up server and client for testing
server = ThreadingOSCUDPServer((ip, recPort), dispatcher)
client = SimpleUDPClient(ip, sendPort)

# Send out the master setup message to start the song
cycles = 4
measure = 4
division = 16
tempo = 110.0
client.send_message("/song/master/setup", [cycles, measure, division, tempo])

# General variables 
vocalRatio = 1.05
hatsRatio = 1.135716
maxNumPhrase = 99999999
kickVol = 0.125
snareVol = 0.35
openhatsVol = 0.15
splashVol = 0.05*1.5
chop1Vol = 0.2
chop3Vol = 0.155
chop4Vol = 0.125
chop5Vol = 0.2
chop7Vol = 0.11
bassVol = 0.05
synthVol = 0.01
posSynthVal1 = 65535 - pos2Dec([2,5,9,10,11,14,15]);
posSynthVal2 = 65535 - pos2Dec([2,5,9,10,11]);
posSynthVal3 = 65535 - pos2Dec([2,5,9,10,11,14,15]);
posSynthVal4 = 65535 - pos2Dec([2,5,9,10,11]);

## SONG START 
## ./12_Cymbals.py r3 & ./10_Kick.py d1 r2 & ./11_Snare.py d2 r1 & ./23_Chop.py d3
# ==== Cymbals
server.handle_request()
numPhrase = 3
posVal = pos2Dec([0,4,8,12])
client.send_message("/song/drums/openhats", [openhatsVol, hatsRatio, posVal, posVal, posVal, posVal, numPhrase, 0])
posVal = pos2Dec([14])
client.send_message("/song/drums/splash", [splashVol, hatsRatio, 0, posVal, 0, posVal, numPhrase, 0])

# ==== Kick
server.handle_request()
numPhrase = 2
posVal = pos2Dec([0,3,6,11,14])
client.send_message("/song/drums/kick", [kickVol, 1.0, posVal, posVal, posVal, posVal, numPhrase, 0])

# ==== Snare
server.handle_request()
numPhrase = 1
posVal1 = pos2Dec([4,12])
posVal2 = pos2Dec([4,12,14])
client.send_message("/song/drums/snare", [snareVol, 1.0, posVal1, posVal2, posVal1, posVal2, numPhrase, 0])

# ==== Chop 3
server.handle_request()
posVal = pos2Dec([4,12])
client.send_message("/song/vocals/chop3", [chop3Vol, vocalRatio, posVal, posVal, posVal, posVal, maxNumPhrase, 0])

# ==== Wait for 2 cycles
server.handle_request()
server.handle_request()

# ./21_Chop.py m11 & ./25_Chop.py m11
# ==== Chop 1
posVal = pos2Dec([0])
client.send_message("/song/vocals/chop1", [chop1Vol, vocalRatio, posVal, 0, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 5
posVal = pos2Dec([2])
client.send_message("/song/vocals/chop5", [chop5Vol, vocalRatio, posVal, 0, posVal, posVal, maxNumPhrase, 0])

# ==== Wait for 2 cycles
server.handle_request()
server.handle_request()

#. ./10_Kick.py m10 & ./50_BassRiff.py m10
# ==== Kick
posVal = pos2Dec([0,3,6])
client.send_message("/song/drums/kick", [kickVol, 1.0, posVal, 0, posVal, 0, maxNumPhrase, 0])
# ==== Bass
playPhrase = 1
client.send_message("/song/bass/bassriff", [bassVol, 1.0, playPhrase, 1, 0, 1, 0, maxNumPhrase, 0])

# ==== Wait for 2 cycles
server.handle_request()
server.handle_request()

# ./12_Cymbals.py
# ==== Cymbals
posVal = pos2Dec([0,4,8,12])
client.send_message("/song/drums/openhats", [openhatsVol, hatsRatio, posVal, posVal, posVal, posVal, maxNumPhrase, 0])
posVal = pos2Dec([14])
client.send_message("/song/drums/splash", [splashVol, hatsRatio, 0, posVal, 0, posVal, maxNumPhrase, 0])

# ==== Wait for 2 cycles
server.handle_request()
server.handle_request()

# ./10_Kick.py & ./11_Snare.py & ./50_BassRiff.py & ./31_SynthVerse.py t15 m10
# ==== Kick
posVal = pos2Dec([0,3,6,11,14])
client.send_message("/song/drums/kick", [kickVol, 1.0, posVal, posVal, posVal, posVal, maxNumPhrase, 0])
# ==== Snare
posVal1 = pos2Dec([4,12])
posVal2 = pos2Dec([4,12,14])
client.send_message("/song/drums/snare", [snareVol, 1.0, posVal1, posVal2, posVal1, posVal2, maxNumPhrase, 0])
# ==== Bass
playPhrase = 1
client.send_message("/song/bass/bassriff", [bassVol, 1.0, playPhrase, 1, 1, 1, 1, maxNumPhrase, 0])
# ==== Synth
client.send_message("/song/synth/saw0", [synthVol, 40, posSynthVal1, 40, 0, 40, posSynthVal3, 40, 0, maxNumPhrase, 0])
client.send_message("/song/synth/saw1", [synthVol, 52, posSynthVal1, 52, 0, 52, posSynthVal3, 52, 0, maxNumPhrase, 0])
client.send_message("/song/synth/saw2", [synthVol, 59, posSynthVal1, 59, 0, 59, posSynthVal3, 59, 0, maxNumPhrase, 0])
client.send_message("/song/synth/saw3", [synthVol, 64, posSynthVal1, 64, 0, 64, posSynthVal3, 64, 0, maxNumPhrase, 0])

# ==== Wait for 4 cycles
server.handle_request()
server.handle_request()
server.handle_request()
server.handle_request()

# ./31_SynthVerse.py p2 t15 & ./50_BassRiff.py p2 & ./21_Chop.py m11 & ./25_Chop.py m11 & ./24_Chop.py m12 & ./27_Chop.py m8 
# ==== Synth
client.send_message("/song/synth/saw0", [synthVol, 40, posSynthVal1, 40, posSynthVal2, 40, posSynthVal3, 40, posSynthVal4, maxNumPhrase, 0])
client.send_message("/song/synth/saw1", [synthVol, 55, posSynthVal1, 54, posSynthVal2, 52, posSynthVal3, 52, posSynthVal4, maxNumPhrase, 0])
client.send_message("/song/synth/saw2", [synthVol, 62, posSynthVal1, 61, posSynthVal2, 59, posSynthVal3, 59, posSynthVal4, maxNumPhrase, 0])
client.send_message("/song/synth/saw3", [synthVol, 67, posSynthVal1, 66, posSynthVal2, 64, posSynthVal3, 64, posSynthVal4, maxNumPhrase, 0])
# ==== Bass
playPhrase = 2
client.send_message("/song/bass/bassriff", [bassVol, 1.0, playPhrase, 1, 1, 1, 1, maxNumPhrase, 0])
# ==== Chop 1
posVal = pos2Dec([0])
client.send_message("/song/vocals/chop1", [chop1Vol, vocalRatio, posVal, 0, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 4
posVal = pos2Dec([10])
client.send_message("/song/vocals/chop4", [chop4Vol, vocalRatio, posVal, posVal, 0, 0, maxNumPhrase, 0])
# ==== Chop 5
posVal = pos2Dec([2])
client.send_message("/song/vocals/chop5", [chop5Vol, vocalRatio, posVal, 0, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 7
posVal = pos2Dec([14])
client.send_message("/song/vocals/chop7", [chop7Vol, vocalRatio, posVal, 0, 0, 0, maxNumPhrase, 0])

# ==== Wait for 5 cycles
server.handle_request()
server.handle_request()
server.handle_request()
server.handle_request()
server.handle_request()

# SILENCE VOCALS
# ./21_Chop.py s1 & ./25_Chop.py s1 & ./24_Chop.py s1 & ./27_Chop.py s1
# ==== Chop 1
client.send_message("/song/vocals/chop1", [1])
# ==== Chop 4
client.send_message("/song/vocals/chop4", [1])
# ==== Chop 5
client.send_message("/song/vocals/chop5", [1])
# ==== Chop 7
client.send_message("/song/vocals/chop7", [1])

# ==== Wait for 3 cycles
server.handle_request()
server.handle_request()
server.handle_request()

# REINSTATE VOCALS
# ./21_Chop.py m11 & ./25_Chop.py m11 & ./24_Chop.py m12 & ./27_Chop.py m8 
# ==== Chop 1
posVal = pos2Dec([0])
client.send_message("/song/vocals/chop1", [chop1Vol, vocalRatio, posVal, 0, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 4
posVal = pos2Dec([10])
client.send_message("/song/vocals/chop4", [chop4Vol, vocalRatio, posVal, posVal, 0, posVal, maxNumPhrase, 0])
# ==== Chop 5
posVal = pos2Dec([2])
client.send_message("/song/vocals/chop5", [chop5Vol, vocalRatio, posVal, 0, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 7
posVal = pos2Dec([14])
client.send_message("/song/vocals/chop7", [chop7Vol, vocalRatio, posVal, 0, 0, posVal, maxNumPhrase, 0])

# ==== Wait for 6 cycles
server.handle_request()
# ==== Chop 1
posVal = pos2Dec([0])
client.send_message("/song/vocals/chop1", [chop1Vol, vocalRatio, 0, posVal, posVal, 0, maxNumPhrase, 0])
# ==== Chop 4
posVal = pos2Dec([10])
client.send_message("/song/vocals/chop4", [chop4Vol, vocalRatio, posVal, 0, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 5
posVal = pos2Dec([2])
client.send_message("/song/vocals/chop5", [chop5Vol, vocalRatio, 0, posVal, posVal, 0, maxNumPhrase, 0])
# ==== Chop 7
posVal = pos2Dec([14])
client.send_message("/song/vocals/chop7", [chop7Vol, vocalRatio, 0, 0, posVal, 0, maxNumPhrase, 0])

server.handle_request()
# ==== Chop 1
posVal = pos2Dec([0])
client.send_message("/song/vocals/chop1", [chop1Vol, vocalRatio, posVal, posVal, 0, posVal, maxNumPhrase, 0])
# ==== Chop 4
posVal = pos2Dec([10])
client.send_message("/song/vocals/chop4", [chop4Vol, vocalRatio, 0, posVal, posVal, 0, maxNumPhrase, 0])
# ==== Chop 5
posVal = pos2Dec([2])
client.send_message("/song/vocals/chop5", [chop5Vol, vocalRatio, posVal, posVal, 0, posVal, maxNumPhrase, 0])
# ==== Chop 7
posVal = pos2Dec([14])
client.send_message("/song/vocals/chop7", [chop7Vol, vocalRatio, 0, posVal, 0, 0, maxNumPhrase, 0])

server.handle_request()
# ==== Chop 1
posVal = pos2Dec([0])
client.send_message("/song/vocals/chop1", [chop1Vol, vocalRatio, posVal, 0, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 4
posVal = pos2Dec([10])
client.send_message("/song/vocals/chop4", [chop4Vol, vocalRatio, posVal, posVal, 0, posVal, maxNumPhrase, 0])
# ==== Chop 5
posVal = pos2Dec([2])
client.send_message("/song/vocals/chop5", [chop5Vol, vocalRatio, posVal, 0, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 7
posVal = pos2Dec([14])
client.send_message("/song/vocals/chop7", [chop7Vol, vocalRatio, posVal, 0, 0, posVal, maxNumPhrase, 0])

server.handle_request()
# ==== Chop 1
posVal = pos2Dec([0])
client.send_message("/song/vocals/chop1", [chop1Vol, vocalRatio,  0, posVal, posVal, 0, maxNumPhrase, 0])
# ==== Chop 4
posVal = pos2Dec([10])
client.send_message("/song/vocals/chop4", [chop4Vol, vocalRatio, posVal, 0, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 5
posVal = pos2Dec([2])
client.send_message("/song/vocals/chop5", [chop5Vol, vocalRatio, 0, posVal, posVal, 0, maxNumPhrase, 0])
# ==== Chop 7
posVal = pos2Dec([14])
client.send_message("/song/vocals/chop7", [chop7Vol, vocalRatio, 0, 0, posVal, 0, maxNumPhrase, 0])

server.handle_request()
# ==== Chop 1
posVal = pos2Dec([0])
client.send_message("/song/vocals/chop1", [chop1Vol, vocalRatio, posVal, posVal, 0, posVal, maxNumPhrase, 0])
# ==== Chop 4
posVal = pos2Dec([10])
client.send_message("/song/vocals/chop4", [chop4Vol, vocalRatio, 0, posVal, posVal, 0, maxNumPhrase, 0])
# ==== Chop 5
posVal = pos2Dec([2])
client.send_message("/song/vocals/chop5", [chop5Vol, vocalRatio, posVal, posVal, 0, posVal, maxNumPhrase, 0])
server.handle_request()
# ==== Chop 7
posVal = pos2Dec([14])
client.send_message("/song/vocals/chop7", [chop7Vol, vocalRatio, 0, posVal, 0, 0, maxNumPhrase, 0])

# ./31_SynthVerse.py t15 m10 & ./50_BassRiff.py m10
# ==== Synth
client.send_message("/song/synth/saw0", [synthVol, 40, posSynthVal1, 40, 0, 40, posSynthVal3, 40, 0, maxNumPhrase, 0])
client.send_message("/song/synth/saw1", [synthVol, 52, posSynthVal1, 52, 0, 52, posSynthVal3, 52, 0, maxNumPhrase, 0])
client.send_message("/song/synth/saw2", [synthVol, 59, posSynthVal1, 59, 0, 59, posSynthVal3, 59, 0, maxNumPhrase, 0])
client.send_message("/song/synth/saw3", [synthVol, 64, posSynthVal1, 64, 0, 64, posSynthVal3, 64, 0, maxNumPhrase, 0])
# ==== Bass
playPhrase = 1
client.send_message("/song/bass/bassriff", [bassVol, 1.0, playPhrase, 1, 1, 1, 1, maxNumPhrase, 0])

# ==== Wait for 2 cycles
server.handle_request()
server.handle_request()

# CHORUS 1
# ./32_SynthChorus.py p1 t15 & ./50_BassRiff.py p3 & ./21_Chop.py & ./25_Chop.py & ./24_Chop.py & 
# ./32_SynthChorus.py p2 t15 d1 r1 & ./50_BassRiff.py p4 r1 d1 & ./21_Chop.py d1 m14 r1 & ./25_Chop.py d1 m14 r1 & ./27_Chop.py d1 m2 & 
# ./31_SynthVerse.py d2 t15 & ./50_BassRiff.py p1 m10 d2
for i in range(2):
    # ==== Synth
    client.send_message("/song/synth/saw0", [synthVol, 40, posSynthVal1, 40, posSynthVal2, 40, posSynthVal3, 40, posSynthVal4, numPhrase, 0])
    client.send_message("/song/synth/saw1", [synthVol, 55, posSynthVal1, 52, posSynthVal2, 50, posSynthVal3, 47, posSynthVal4, numPhrase, 0])
    client.send_message("/song/synth/saw2", [synthVol, 62, posSynthVal1, 59, posSynthVal2, 57, posSynthVal3, 54, posSynthVal4, numPhrase, 0])
    client.send_message("/song/synth/saw3", [synthVol, 67, posSynthVal1, 64, posSynthVal2, 62, posSynthVal3, 59, posSynthVal4, numPhrase, 0])
    # ==== Bass
    playPhrase = 3
    client.send_message("/song/bass/bassriff", [bassVol, 1.0, playPhrase, 1, 0, 0, 0, maxNumPhrase, 0])
    # ==== Chop 1
    posVal = pos2Dec([0])
    client.send_message("/song/vocals/chop1", [chop1Vol, vocalRatio, posVal, posVal, posVal, posVal, maxNumPhrase, 0])
    # ==== Chop 4
    posVal = pos2Dec([10])
    client.send_message("/song/vocals/chop4", [chop4Vol, vocalRatio, posVal, posVal, posVal, posVal, maxNumPhrase, 0])
    # ==== Chop 5
    posVal = pos2Dec([2])
    client.send_message("/song/vocals/chop5", [chop5Vol, vocalRatio, posVal, posVal, posVal, posVal, maxNumPhrase, 0])
    # ==== Chop 7
    posVal = pos2Dec([14])
    client.send_message("/song/vocals/chop7", [chop7Vol, vocalRatio, posVal, 0, 0, 0, maxNumPhrase, 0])

    # ==== Wait for 1 cycles
    server.handle_request()

    # ==== Synth
    client.send_message("/song/synth/saw0", [synthVol, 40, posSynthVal1, 40, posSynthVal2, 40, posSynthVal3, 40, posSynthVal4, numPhrase, 0])
    client.send_message("/song/synth/saw1", [synthVol, 48, posSynthVal1, 48, posSynthVal2, 52, posSynthVal3, 52, posSynthVal4, numPhrase, 0])
    client.send_message("/song/synth/saw2", [synthVol, 55, posSynthVal1, 55, posSynthVal2, 59, posSynthVal3, 59, posSynthVal4, numPhrase, 0])
    client.send_message("/song/synth/saw3", [synthVol, 60, posSynthVal1, 60, posSynthVal2, 64, posSynthVal3, 64, posSynthVal4, numPhrase, 0])
    # ==== Bass
    playPhrase = 4
    client.send_message("/song/bass/bassriff", [bassVol, 1.0, playPhrase, 1, 0, 0, 0, 1, 0])
    # ==== Chop 1
    posVal = pos2Dec([0])
    client.send_message("/song/vocals/chop1", [chop1Vol, vocalRatio, posVal, posVal, posVal, 0, 1, 0])
    # ==== Chop 5
    posVal = pos2Dec([2])
    client.send_message("/song/vocals/chop5", [chop5Vol, vocalRatio, posVal, posVal, posVal, 0, 1, 0])
    # ==== Chop 7
    posVal = pos2Dec([14])
    client.send_message("/song/vocals/chop7", [chop7Vol, vocalRatio, 0, 0, posVal, 0, maxNumPhrase, 0])
    
    # ==== Wait for 1 cycles
    server.handle_request()

# ==== Synth
client.send_message("/song/synth/saw0", [synthVol, 40, posSynthVal1, 40, 0, 40, posSynthVal3, 40, 0, maxNumPhrase, 0])
client.send_message("/song/synth/saw1", [synthVol, 52, posSynthVal1, 52, 0, 52, posSynthVal3, 52, 0, maxNumPhrase, 0])
client.send_message("/song/synth/saw2", [synthVol, 59, posSynthVal1, 59, 0, 59, posSynthVal3, 59, 0, maxNumPhrase, 0])
client.send_message("/song/synth/saw3", [synthVol, 64, posSynthVal1, 64, 0, 64, posSynthVal3, 64, 0, maxNumPhrase, 0])
# ==== Bass
playPhrase = 1
client.send_message("/song/bass/bassriff", [bassVol, 1.0, playPhrase, 1, 1, 1, 1, maxNumPhrase, 0])

# ==== Wait for 4 cycles
server.handle_request()
server.handle_request()
server.handle_request()
server.handle_request()

# VERSE 2
# ./31_SynthVerse.py p2 t15 & ./50_BassRiff.py p2 & ./21_Chop.py & ./25_Chop.py m11 & ./24_Chop.py m12 d1 & ./27_Chop.py m8
# ==== Synth
client.send_message("/song/synth/saw0", [synthVol, 40, posSynthVal1, 40, posSynthVal2, 40, posSynthVal3, 40, posSynthVal4, maxNumPhrase, 0])
client.send_message("/song/synth/saw1", [synthVol, 52, posSynthVal1, 52, posSynthVal2, 52, posSynthVal3, 52, posSynthVal4, maxNumPhrase, 0])
client.send_message("/song/synth/saw2", [synthVol, 59, posSynthVal1, 59, posSynthVal2, 59, posSynthVal3, 59, posSynthVal4, maxNumPhrase, 0])
client.send_message("/song/synth/saw3", [synthVol, 64, posSynthVal1, 64, posSynthVal2, 64, posSynthVal3, 64, posSynthVal4, maxNumPhrase, 0])
# ==== Bass
playPhrase = 1
client.send_message("/song/bass/bassriff", [bassVol, 1.0, playPhrase, 1, 1, 1, 1, maxNumPhrase, 0])

# ==== Wait for 6 cycles
server.handle_request()
server.handle_request()
server.handle_request()
server.handle_request()
server.handle_request()
server.handle_request()

# ./31_SynthVerse.py p2 t15 & ./50_BassRiff.py p2 & ./21_Chop.py m11 & ./25_Chop.py m11 & ./24_Chop.py m12 & ./27_Chop.py m8 
# ==== Synth
client.send_message("/song/synth/saw0", [synthVol, 40, posSynthVal1, 40, posSynthVal2, 40, posSynthVal3, 40, posSynthVal4, maxNumPhrase, 0])
client.send_message("/song/synth/saw1", [synthVol, 55, posSynthVal1, 54, posSynthVal2, 52, posSynthVal3, 52, posSynthVal4, maxNumPhrase, 0])
client.send_message("/song/synth/saw2", [synthVol, 62, posSynthVal1, 61, posSynthVal2, 59, posSynthVal3, 59, posSynthVal4, maxNumPhrase, 0])
client.send_message("/song/synth/saw3", [synthVol, 67, posSynthVal1, 66, posSynthVal2, 64, posSynthVal3, 64, posSynthVal4, maxNumPhrase, 0])
# ==== Bass
playPhrase = 2
client.send_message("/song/bass/bassriff", [bassVol, 1.0, playPhrase, 1, 1, 1, 1, maxNumPhrase, 0])
# ==== Chop 1
posVal = pos2Dec([0])
client.send_message("/song/vocals/chop1", [chop1Vol, vocalRatio, posVal, 0, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 4
posVal = pos2Dec([10])
client.send_message("/song/vocals/chop4", [chop4Vol, vocalRatio, posVal, posVal, 0, 0, maxNumPhrase, 0])
# ==== Chop 5
posVal = pos2Dec([2])
client.send_message("/song/vocals/chop5", [chop5Vol, vocalRatio, posVal, 0, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 7
posVal = pos2Dec([14])
client.send_message("/song/vocals/chop7", [chop7Vol, vocalRatio, posVal, 0, 0, 0, maxNumPhrase, 0])

# ==== Wait for 4 cycles
server.handle_request()
server.handle_request()
server.handle_request()
server.handle_request()

# ./31_SynthVerse.py t15 m10 & ./50_BassRiff.py m10
# ==== Synth
client.send_message("/song/synth/saw0", [synthVol, 40, posSynthVal1, 40, 0, 40, posSynthVal3, 40, 0, maxNumPhrase, 0])
client.send_message("/song/synth/saw1", [synthVol, 52, posSynthVal1, 52, 0, 52, posSynthVal3, 52, 0, maxNumPhrase, 0])
client.send_message("/song/synth/saw2", [synthVol, 59, posSynthVal1, 59, 0, 59, posSynthVal3, 59, 0, maxNumPhrase, 0])
client.send_message("/song/synth/saw3", [synthVol, 64, posSynthVal1, 64, 0, 64, posSynthVal3, 64, 0, maxNumPhrase, 0])
# ==== Bass
playPhrase = 1
client.send_message("/song/bass/bassriff", [bassVol, 1.0, playPhrase, 1, 1, 1, 1, maxNumPhrase, 0])

# ==== Wait for 2 cycles
server.handle_request()
server.handle_request()

# CHORUS 2
# ./32_SynthChorus.py p1 t15 & ./50_BassRiff.py p3 & ./21_Chop.py & ./25_Chop.py & ./24_Chop.py & 
# ./32_SynthChorus.py p2 t15 d1 r1 & ./50_BassRiff.py p4 r1 d1 & ./21_Chop.py d1 m14 & ./25_Chop.py d1 m14 & ./27_Chop.py d1 m2 
# # ==== Synth
client.send_message("/song/synth/saw0", [synthVol, 40, posSynthVal1, 40, posSynthVal2, 40, posSynthVal3, 40, posSynthVal4, numPhrase])
client.send_message("/song/synth/saw1", [synthVol, 55, posSynthVal1, 52, posSynthVal2, 50, posSynthVal3, 47, posSynthVal4, numPhrase])
client.send_message("/song/synth/saw2", [synthVol, 62, posSynthVal1, 59, posSynthVal2, 57, posSynthVal3, 54, posSynthVal4, numPhrase])
client.send_message("/song/synth/saw3", [synthVol, 67, posSynthVal1, 64, posSynthVal2, 62, posSynthVal3, 59, posSynthVal4, numPhrase])
# ==== Bass
playPhrase = 3
client.send_message("/song/bass/bassriff", [bassVol, 1.0, playPhrase, 1, 0, 0, 0, maxNumPhrase])
# ==== Chop 1
posVal = pos2Dec([0])
client.send_message("/song/vocals/chop1", [chop1Vol, vocalRatio, posVal, posVal, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 4
posVal = pos2Dec([10])
client.send_message("/song/vocals/chop4", [chop4Vol, vocalRatio, posVal, posVal, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 5
posVal = pos2Dec([2])
client.send_message("/song/vocals/chop5", [chop5Vol, vocalRatio, posVal, posVal, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 7
posVal = pos2Dec([14])
client.send_message("/song/vocals/chop7", [chop7Vol, vocalRatio, posVal, 0, 0, 0, maxNumPhrase, 0])

# ==== Wait for 1 cycles
server.handle_request()

# ==== Synth
client.send_message("/song/synth/saw0", [synthVol, 40, posSynthVal1, 40, posSynthVal2, 40, posSynthVal3, 40, posSynthVal4, 1, 0])
client.send_message("/song/synth/saw1", [synthVol, 48, posSynthVal1, 48, posSynthVal2, 52, posSynthVal3, 52, posSynthVal4, 1, 0])
client.send_message("/song/synth/saw2", [synthVol, 55, posSynthVal1, 55, posSynthVal2, 59, posSynthVal3, 59, posSynthVal4, 1, 0])
client.send_message("/song/synth/saw3", [synthVol, 60, posSynthVal1, 60, posSynthVal2, 64, posSynthVal3, 64, posSynthVal4, 1, 0])
# ==== Bass
playPhrase = 4
client.send_message("/song/bass/bassriff", [bassVol, 1.0, playPhrase, 1, 0, 0, 0, 1, 0])
# ==== Chop 1
posVal = pos2Dec([0])
client.send_message("/song/vocals/chop1", [chop1Vol, vocalRatio, posVal, posVal, posVal, 0, 1, 0])
# ==== Chop 4
posVal = pos2Dec([10])
client.send_message("/song/vocals/chop4", [chop4Vol, vocalRatio, posVal, 0, posVal, posVal, maxNumPhrase, 0])
# ==== Chop 5
posVal = pos2Dec([2])
client.send_message("/song/vocals/chop5", [chop5Vol, vocalRatio, posVal, posVal, posVal, 0, maxNumPhrase, 0])
# ==== Chop 7
posVal = pos2Dec([14])
client.send_message("/song/vocals/chop7", [chop7Vol, vocalRatio, 0, 0, posVal, 0, maxNumPhrase, 0])
 
# ==== Wait for 4 cycles
server.handle_request()
server.handle_request()
server.handle_request()
server.handle_request()

#./32_SynthChorus.py p2 t15 & ./50_BassRiff.py p4 
# ==== Synth
client.send_message("/song/synth/saw0", [synthVol, 40, posSynthVal1, 40, posSynthVal2, 40, posSynthVal3, 40, posSynthVal4, maxNumPhrase, 0])
client.send_message("/song/synth/saw1", [synthVol, 48, posSynthVal1, 48, posSynthVal2, 52, posSynthVal3, 52, posSynthVal4, maxNumPhrase, 0])
client.send_message("/song/synth/saw2", [synthVol, 55, posSynthVal1, 55, posSynthVal2, 59, posSynthVal3, 59, posSynthVal4, maxNumPhrase, 0])
client.send_message("/song/synth/saw3", [synthVol, 60, posSynthVal1, 60, posSynthVal2, 64, posSynthVal3, 64, posSynthVal4, maxNumPhrase, 0])
# ==== Bass
playPhrase = 4
client.send_message("/song/bass/bassriff", [bassVol, 1.0, playPhrase, 1, 0, 0, 0, maxNumPhrase, 0])

# ==== Wait for 6 cycles
server.handle_request()
server.handle_request()
server.handle_request()
server.handle_request()
server.handle_request()
server.handle_request()

## Final Fade out THIS FADES OUT IN  1:20
# ./01_SongFade.py m31 r-0.01 
client.send_message("/song/master/fade", [-0.1, 31])

# ====================================


