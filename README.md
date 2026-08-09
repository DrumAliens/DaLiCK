# DaLiCK
Drumaliens Liveconducting in ChucK

# Inspiration for this code

The ChucK framework makes use of the following code

https://github.com/celestebetancur/CHmUsiCK

This then has made use of the samples and original musical idea from here

https://github.com/dbrown2642/ChucK-live-code-performance

with additional samples have been taken from Freesound.org https://freesound.org/ or recorded by myself

## Objective
In the orginal version of CHmUsiCK a single livecode.ck file is reloaded (re-sporked in ChucK terminology) after a predefined number of bars. With the track being developed live with the changes being reloaded and turned into music.

In this version instruments have been split out into individual chuck files this allows for the following advantages
- samples that blend across bars can play properly handled (any decays can play on and not overwritten)
- instrument changes are only reloaded when a change is triggered

What each instrument plays is controlled by sending out OSC messages to the ChucK code which decodes this into a set of musical instructions. Importantly, as in CHmuSK any changes made to the song have to be sent at a point during the current phrase so that the changes can be instigated at the start of the new phrase. THe timing is and synching is handled by ChucK.

Note: this approach doesn't give you as much control as you would get in a standard livecoding approach. With the elements of the song/code having to be generated before each performance.

<h2 align="center"> You are more conducting than livecoding </h2>

# Operating System
This code has been tested and run on MAC (I have run previous version in Ubuntu but I have not tested recent versions I don't have a powerfull enough computer to do this).

# Chuck Installation Setup

This project makes use of ChucK livecoding environment. Get the latest version of the software from here
```
https://chuck.stanford.edu/release/
```

## MAC
Install as per any other software

# Python setup
Setup a virtual environment for python in the project root directory using

```bash
python3 -m venv .venv
```
switch to the virtual environment 

```bash
    $ source .venv/bin/activate
```
and then install python-osc
```bash
    $ pip install python-osc
```

## Make the python executable

Since we are using the virtual environment we can point to this in the first line of the code to ensure that the python script uses this instead of any another python instance on your machine
```
    #!.venv/bin/python
```
Make the file executable with the following command
```bash
    chmod +x myfile.py
```
and execute with the following command
```bash
    ./myfile.py
```

# OSC Control
The ChucK scripts listens to commands on the localhost address 127.0.0.1 and listen to commands sent on port 49162. It should be possible to run the script over a network in that case you would have to change the IP addresses accordingly. The OSC messages packet address are structured in the form /song/"base instrument"/"specific instrument".

LiveCode_00_Sync.ck also transmits the current Phrase number on port 49162 which was used as part of a playpiano mode. The idea of this is to allow you to play the entire song using a single script, see oscPlay.py. This currently doesn't work but I might look into this more in the future. 

# Running the code for performing live

Essentially you need at least two terminal windows open to run the code. There are a number of tools to allow you to do this more eligantly I have been using tmux as this is works across MAC and Linux

### Terminal 1 - Running ChucK 
In one of the terminal window run the following in the project root directory

```bash
    $ chuck Library.ck
```
This then loads all of the different chuck elements to run the code. The list of the files to be included is contained in Library.ck in the root directory. It will waits for an OSC synch message and the instructions sent by ./00_StartSong.py

In this terminal window it will first display the length of time to complete a phrase. This will be the time required to delay an instrument using **W**wait command. It will then display the phrase number this helps align the introduction of different instruments as the song evolves.

### Terminal 2 - Starting a Song
You run this from the Song folder 

```bash
    $ ./00_StartSong.py
```

This transmits all of the song timing information ChucK to allow everything to be synced. This has to be run after the ChucK library has been started.

Once you have done this then you can start running the different instruments. SongNotes.txt (in the Song directory) contains a series of commands which can be copied and pasted into you instrument terminal. Note: if you are using instructions which include a **W**ait then this can block you from copying and pasting in the next command into that terminal ... this is why you might want more terminals for a smoother performance.

## 01_SongFade.py

This allows you to fade individual or multiple instruments using the following input arguements

| Command | Example | Type | Description |
| --- | --- | --- | --- |
|**Rate**  |r-10.0   |float |reduces the volume of the instrument linearly. The number indicates the decay time in seconds  |\
|**Mark**    |m10  |integer |fade instruments starting in 1X and 3X |\

The mark information is converted into binary in ChucK to control specific instruments to fade. The leading number of the instrument file indicates the bit being enabled

Note: for all of the instuments the default is that the fader is set to one. However, it is also possible to fade in an instrument using a positive time but you would, before using it, have to fade out that instrument to get the fader to start from zero.

## Instrument files

Each instrument is grouped with the leading number categorises the type of instrument, this then allows 10 versions of the same instrument if required
- 1X drums
- 2X vocals
- 3X piano
- 4X guitar
- 5X bass guitar
- 6x environmental noises
- 7x frogs 

You can use the following command line arguements to control what is played. The following are a list of examples with default settings in brackets
| Command | Example | Type | Description |
| --- | --- | --- | --- |
|**Repeat**  |r4   |integer |repeat this instrument for 4 cycles (99999999) |\
|**Phrase**  |p2   |integer |play the second 2nd programmed pattern in the script (default 1) |\
|**Mark**    |m10  |integer |selects bar 1 and bar 3 parts of the phrase to be played converts decimal to binary with the MSB being bar 1 (15) |\
|**Chance**  |c0.5  |float |allows you to introduce some randomness into the song probability that that sample will be played (1.0) |\
|**Delay**   |d2   |integer |delays playing this phrase for 2 cycles (0) |\
|**Stop**    |s2   |integer |stops playing that instrument after 2 cycles (0) |\
|**Volume**  |v0.5 |float   |allows you to change the current volume (1.0) |\
|**sHuffle**  |h66.0 |float   |defines a shuffle relationship of the even and odd beats range 50.0 to 75.0 (50.0)  |\
|**Wait time**  |w10.0 |float   |defines a wait time/delay of 10.0 seconds before the python sends out the OSC message (0.0) |\

Note:
- **S**top doesn't change what that instrument is playing where as **R**epeat also updates the instrument parameters
- **W**ait delays sending out OSC messages this then allows you to chain several parameters to the same instrument by creating various instances of the python script using && in the command line. **D**elay only allows a single future change to an instrument

Note: you can create instruments which are not syncronised to the song phrases. For example the environmental instrument LiveCode_61_Rain.ck is initiated in synch with the song timing, to allow it to start at a point defined in the song, but then runs on it's own timing which is defined by looping parts of a sample.

### Multiple instances of python OSC scripts 
By using && in the command line allows you to create complex instrument changes to occur at the same time and/or delayed using **W**ait command, see SongNotes.txt in Song directory for a number of different examples.

## Library.py
This contains a bunch of functions which are shared across the python scripts

## Processing scripts
There are a number of bash scripts that have been written to help setup the sample files before they are used

- convertFLAC2WAV this converts a flac file to a wav file
- convertWAV44100Hz this converts the sample to 44100Hz sample rate. ChucK assumes this rate if you don't do this then your sample will be played back at the wrong rate leading to notes in a different key
- splitWAVStereo this allows the left and right channels of the sample to be split out. You may need to do this to allow you to handle stereo files differently within the ChucK code

Both scripts make use of ffmpeg to do the above conversion so this needs to be installed on your machine

