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

In this version instruments have been split out into individual ChucK files this allows for the following advantages
- samples that blend across bars can be properly handled (any decays can play on and not overwritten)
- instrument changes are only reloaded when a change actually happens

What each instrument plays is controlled by sending out OSC messages to the ChucK code which decodes this into a set of musical instructions. Importantly, as in CHmuSK any changes made to the song have to be sent at a point during the current phrase so that the changes can be instigated at the start of the next phrase. (I have included the ability to use delay and wait statements to make life easier when performing live). The timing and synching is handled by ChucK.

Note: this approach doesn't give you as much control as you would get in a standard livecoding approach. With the elements of the song/code having to be generated before each performance.

<h2 align="center"> You are more conducting than livecoding </h2>

An example of the what you can do with the software is given here 

https://drumaliens.bandcamp.com/track/bastardisation-of-a-theme-by-dustin-brown-frogs-and-rain

and the set of instructions to generate this is given in Song/SongNotes.ipynb

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

In this terminal window it will first display the length of time to complete a phrase. This will be the time required to delay an instrument using **W**ait command. It will then display the phrase number this helps align the introduction of different instruments as the song evolves.

### Terminal 2 - Starting a Song
You run this from the Song folder 

| Command | Example | Type | Description |
| --- | --- | --- | --- |
|**Number of beats**  |n27   |int |defines how many beats are in that phrase (16)  |\
|**beat Divisor**  |d1 |int   |defines how the beat is divided. The granularity to which you can place samples (4) |\
|**Tempo**  |t165.0 |float   |defines the tempo of the song (120.0) |\
|**phrase lengths**  |54:81,82 | int:int,int  |allows you to define different phrase for different instruments (1) |\
|**instrument groupings**  |"/steamengine" | string |defines a which grouping of instruments you want to start running ("") |\
|**Kill**|kill | string | this allows you to terminate an instrument that has been running (the idea behind this is good housekeeping/resource management) |\

So in this example

```bash
    $ ./00_StartSong.py n27 d1 b3 t165.0 54:81,82 /steamengine 
```
This will start all of the instruments that are grouped under "steamengine" banner, all of the other instruments contained in Library.ck will be waiting for their group to be called. The idea of this is to ensure that other instruments can't be called in error and also elininate any timing slip that might occur over a long performance as any new group will be synched to started at the same time. 

Note instruments 81 and 82 will take twice as long to complete their cycle than the others. This then allows, as an example vocals to run over a longer cycle than a rhythm section. This makes it easier to program/run and eliminates the need of having to swap between programmed shorter phrases. You could set everything to use the long phrase length but that would mean that changes can only happen when the longer phrase completes which might make the tune slow to progress. Using this approach comes at a cost if you want to, at some point, sync the two sets of instruments running at different cycles, then you have to be accurate when you run any commands live ... it's a trade off.

Once you have done this then you can start playing the different instruments. There are two different approaches you can use to play the song.

#### 1. Copy and Paste 

Store all of the command line statements into a text file and copy and pasted into the instrument terminal. Note: if you are using instructions which delay when an instrument is played then this can block you from copying and pasting in the next command ... which is why you might want more terminals.

Personally I don't use this approach as copying and pasting live can lead to disaster.

#### 2. Jupyter Notebook

SongNotes.ipynb contains the same series of commands as SongNotes.txt but in a Jupyter notebook. The instrument commands are contained in a python window with !! preceeding the instrument commands, this allows the commands to be run as if it was in a terminal window. The commands can be run by clicking the play button on the left of that section. Using this approach allows you to use the play button to run an individual command live. **Note: you can only run one command at a time so if you use any commands that involve a wait then you will be blocked from running any other commands until the first command has finished.**

## 01_SongFade.py

This allows you to fade individual or multiple instruments using the following input arguements

| Command | Example | Type | Description |
| --- | --- | --- | --- |
|**Rate**  |r-10.0   |float |reduces the volume of the instrument linearly. The number indicates the decay time in seconds  |\
|**Wait time**  |w10.0 |float   |defines a wait time/delay of 10.0 seconds before the python sends out the OSC message (0.0) |\

To choose which instrument this effects just provide the instrument number/s either as a comma separated or space separated list. So for example to fade out the drums over the next 30 seconds 

```bash
    $ ./01_SongFade.py r-30.0 11,12,13
```

Note: for all of the instuments the default is that the fader is set to one. However, it is also possible to fade in an instrument using a positive time but you would first have to fade that instrument to zero using a negative time before it is going to be used.

## 02_SongFiltFade.py

This allows you to control the frequency of a Low Pass Filter for an individual or multiple instruments using the following input arguements (currently only implemented in Livecode_62_Thunder.ck, Livecode_71_Frogs_Left_Break.ck, Livecode_72_Frogs_Mid_Break.ck and Livecode_73_Frogs_Right_Break.ck). The start and end frequency is set in the ChucK program for each individual instrument.

| Command | Example | Type | Description |
| --- | --- | --- | --- |
|**Rate**  |r-10.0   |float |reduces the volume of the instrument linearly. The number indicates the decay time in seconds  |\
|**Wait time**  |w10.0 |float   |defines a wait time/delay of 10.0 seconds before the python sends out the OSC message (0.0) |\

To choose which instrument this effects just provide the instrument number/s either as a comma separated or space separated list. So for example to change the frequency of the LPF on the frogs over the next 30 seconds 

```bash
    $ ./02_SongFiltFade.py r30.0 71 72 73
```

Note: for all of the instuments the default is that the fader is set to one. However, it is also possible to fade in an instrument using a positive time but you would first have to fade that instrument to zero using a negative time.

## Instrument files

Each instrument is grouped with the leading number categorises the type of instrument, this then allows multiple versions of the same instrument if required
- 1X drums
- 2X vocals
- 3X piano
- 4X guitar
- 5X environmental noises
- 6X frogs
- 7X steam engine
- 8X vocals 

You can use the following command line arguements to control what is played. The following are a list of examples with default settings in brackets
| Command | Example | Type | Description |
| --- | --- | --- | --- |
|**Repeat**  |r4   |integer |repeat this instrument for 4 cycles (99999999) |\
|**Phrase**  |p2   |integer |play the second 2nd programmed pattern in the script (default 1) |\
|**Chance**  |c0.5  |float |defines the probability that that sample will be played (0.0) |\
|**Glitch**  |g0.5  |float |defines the probability that that current slice will have glitch effect applied to it (0.0) |\
|**Slice**  |s0.5  |float |defines the probability that a different available slice will be used instead (0.0) |\
|**Delay**   |d2   |integer |delays playing this phrase for 2 cycles (0) |\
|**Quiet**    |q2   |integer |stops playing that instrument after 2 cycles (0) |\
|**Volume**  |v0.5 |float   |allows you to change the current volume (1.0) |\
|**sHuffle**  |h66.0 |float   |defines a shuffle relationship of the even and odd beats range 50.0 to 75.0 (50.0)  |\
|**Wait time**  |w10.0 |float   |defines a wait time/delay of 10.0 seconds before the python sends out the OSC message (0.0) |\
|**message** |">hello" | string | this allows you to send a messeage to the terminal window useful for debugging ("") |\
|**Kill** |kill | string | this allows you to terminate an instrument that has been running (the idea behind this is good housekeeping/resource management) |\

You can also mask out which bars are to be played by providing the bar number either as a comma separated or space separated list, for example

```bash
./24_Chop.py 1,2
```
will play the first and second bar of the phrase. Note: if you specify a bar that is out of the range of the number of bars in the songs phrase then it will be ignored

Note:
- **S**top doesn't change what that instrument is playing where as **R**epeat also updates the instrument parameters
- **W**ait delays sending out OSC messages this then allows you to chain several parameters to the same instrument by creating various instances of the python script using && in the command line. **D**elay only allows a single future change to an instrument

Note: you can create instruments which are not synchronised to the song phrases. For example the environmental instrument LiveCode_61_Rain.ck is initiated in synch with the song timing, to allow it to start at a point defined in the song, but then runs on it's own timing which is defined by looping parts of a sample.

### Multiple instances of python OSC scripts 
By using && in the command line allows you to create complex instrument changes to occur at the same time and/or delayed using **W**ait command, see SongNotes.txt in Song directory for a number of different examples.

## Library.py
This contains a bunch of functions which are shared across the python scripts

## Processing scripts
There are a number of bash scripts that have been written to help setup the sample files before they are used

- convertFLAC2WAV this converts a flac file to a wav file
- convertWAV44100Hz this converts the sample to 44100Hz sample rate. ChucK assumes this rate if you don't do this then your sample will be played back at the wrong rate leading to notes in a different key
- splitWAVStereo this allows the left and right channels of the sample to be split out. You may need to do this to allow you to handle stereo files differently within the ChucK code

The above scripts make use of ffmpeg to do the above conversion so this needs to be installed on your machine

