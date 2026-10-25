
CHmUsiCK Library => SndBuf2 buffer => Envelope envelope[2] => LPF instrLPF[2] => dac;

// Run the fader for the filter through into a blackhole
Envelope faderFilt => blackhole;

"/song/sounds/thunder" => string oscInstrMsgName;
"/frogs" => string oscInstrMsgSongPhrase;
me.dir() + "Samples/frogsAnd/194364__dave-welsh__thunder-clap-Mod.wav" => buffer.read;

buffer.samples() => int sampleEnd;
sampleEnd => buffer.pos;

// Get the sample rate
buffer.sampleRate() => float sampleHz;

// Map play back rate to a midi note
Library.MIDIROOTNOTE => float midiRootNote;

// Map out the slices in the sample
sampleEnd / sampleHz => float sliceNoteSec;

// Setup the envelope
0.5 => float rampTimeSec;
rampTimeSec::second => envelope[0].duration => envelope[1].duration;
0.0 => envelope[0].value => envelope[1].value;

// 
"52" => string instrEnblStr;
Std.atoi(instrEnblStr) => int instrEnblVal;

// Switch on the filter fader envelope
1.0 => faderFilt.value;
60.0 => float filtFadeDurABS;
// Minimum filter cutoff
500.0 => float minLPFFreq;
// Maximum filter cutoff
24000.0 => float maxLPFFreq => instrLPF[0].freq => instrLPF[1].freq;  
// Work out the delta for spork function
maxLPFFreq / minLPFFreq => float ratioLPFFreq;       
// Filter resonance
3.0 => instrLPF[0].Q => instrLPF[1].Q;  

// ============= DON'T CHANGE BEYOND HERE

0 => int oscMsgRecvr;
0 => int oscMsgInstrRecvr;
0 => int oscMsgFadeRecvr;
0 => int oscMsgFiltFadeRecvr;

// Map across the song parameters
16 => int oscNumBeats;
4 => int oscBeatDivision;
4 => int oscBeatBar;
120.0 => float oscSongTempo;
50.0 => float oscInstrShufflePercent;
oscNumBeats * oscBeatDivision => int oscPhraseDiv => int phraseDiv;
// Calculate the timing information
TimerInfo timerInfo;

1 => int oscInstrPlay;
1.0 => float oscInstrAmp;
0 => int oscInstrDelay;
5 => int oscInstrStop => int instrStop;
1.0 => float oscInstrGain;
0.0 => float oscInstrProbPlay => float sampleProbPlay;
0.0 => float oscInstrProbGlitch => float sampleProbGlitch;
0.0 => float oscInstrProbSlice => float sampleProbSlice;
"" => string oscStrMsg;

4.0 => float oscFadeDur;
4.0 => float oscFiltFadeDur;

// Setup the initial counter     
0 => int countLocl;
99999999 => int stopNumber;

// Number of beats that make up a phrase
Library.MAXNUMNOTES => int arrayLen;
arrayLen => int oscNumElements;

// Position of note
int oscInstrArrayPos[arrayLen];
int samplePos[arrayLen];
// MIDI note to be played
float oscInstrArrayNote[arrayLen];
float sampleNote[arrayLen];
// Position amp of the slice 
float oscInstrArrayEmphasis[arrayLen];
float sampleEmphasis[arrayLen];
// Length of that note in seconds
float oscInstrArrayNoteTime[arrayLen];
float sampleNoteTime[arrayLen];
// Position of the slice within a sample 
int oscInstrArraySliceIndx[arrayLen];
int sampleSliceIndx[arrayLen];
// Effects arrays 
float oscInstrArrayEffect1[arrayLen];
float sampleEffect1[arrayLen];
float oscInstrArrayEffect2[arrayLen];
float sampleEffect2[arrayLen];

// Start the OSC Message Receiver
spork ~ OscRecvr() @=> Shred @shredId;

// Wait for the OSC signal on the song information
while (oscMsgRecvr == 0) {
    samp => now;
}
// Reset the osc message flag 
0 => oscMsgRecvr;

// NEED TO PUT A WAIT HERE TO ALIGN WITH THE TIME AND THE START OF A PHRASE

// Setup the initial counter     
oscNumBeats => int numBeats;
oscBeatDivision => int beatDivision;
oscBeatBar => int beatBar;
oscSongTempo => float songTempo;
oscPhraseDiv => phraseDiv;

// Calculate the timing information
Library.calcTimer(numBeats, beatDivision, beatBar, songTempo, oscInstrShufflePercent) @=> timerInfo;

timerInfo.numPhraseDivisions*timerInfo.divVal => float val;
val::second => dur phraseDur;

// Flag to allow the played sample to complete
0 => int finishPlaying;

// Counter to determine whether the instrument is played over the phrase 
0 => int instrPlayedLastPhrase;

// This waits for each phrase cycle and exits if called
while(oscInstrPlay)
{

   // Master 
   if (oscMsgRecvr > 0){
        oscNumBeats => numBeats;
        oscBeatDivision => beatDivision;
        oscBeatBar => beatBar;
        oscSongTempo => songTempo;
        oscPhraseDiv => phraseDiv;

        // Calculate the timing information
        Library.calcTimer(numBeats, beatDivision, beatBar, songTempo, oscInstrShufflePercent) @=> timerInfo;

		// Reset the osc message flag 
		0 => oscMsgRecvr;
    }

    // Low Pass Filter Fader 
    if (oscMsgFiltFadeRecvr > 0) {
        // Set the length of time to fade over
        Math.fabs(oscFiltFadeDur) => filtFadeDurABS;
        filtFadeDurABS::second => faderFilt.duration;

        if (oscFiltFadeDur < 0.0) {
           faderFilt.keyOff();
        }
        else {
           faderFilt.keyOn();
        }
        // Reset the osc message flag 
        0 => oscMsgFiltFadeRecvr;
    }

    // Remove OSC Instrument request to stop an instrument if it hasn't run previously
    // Otherwise you will end up triggering the instrument
    if ((oscMsgInstrRecvr == 1) && (oscInstrStop > 0) && (instrPlayedLastPhrase == 0)) {
        0 => oscMsgInstrRecvr;
    }

    // Map across OSC Instrument changes 
    if (oscMsgInstrRecvr > 0){

        // Update the lowpass filter frequency
        minLPFFreq * Math.pow(ratioLPFFreq, (faderFilt.value() * filtFadeDurABS) / filtFadeDurABS) => instrLPF[0].freq  => instrLPF[1].freq;

        if (oscInstrDelay == 0) {
            // oscInstrAmp => buffer.gain;
            oscInstrAmp => buffer.gain;
            oscInstrStop => stopNumber;
            oscInstrProbPlay => sampleProbPlay;
            oscInstrProbGlitch => sampleProbGlitch;
            oscInstrProbSlice => sampleProbSlice;

            // Update the timing information
            Library.calcTimer(numBeats, beatDivision, beatBar, songTempo, oscInstrShufflePercent) @=> timerInfo;

            0 => countLocl;
            // Copy across the instrument information
            for (0 => int i; i < oscNumElements; i++) {
                oscInstrArrayPos[i] => samplePos[i];
                oscInstrArrayNote[i] => sampleNote[i];
                oscInstrArrayNoteTime[i] => sampleNoteTime[i];
                oscInstrArrayEmphasis[i] => sampleEmphasis[i];
                oscInstrArraySliceIndx[i] => sampleSliceIndx[i];
                oscInstrArrayEffect1[i] => sampleEffect1[i];
                oscInstrArrayEffect2[i] => sampleEffect2[i];
            }
            // Put in stop condition
            oscInstrArrayPos[oscNumElements] => samplePos[oscNumElements];
            
            // Print out helping string
            if (oscStrMsg.length() > 0) {
                cherr <= oscStrMsg <= IO.newline();
            }

            // Reset the osc message flag 
            0 => oscMsgInstrRecvr;
        }
        else {
            oscInstrDelay--;
        }        
    }

    0 => int sampleIndx;
    1 => int evenVal;
    0 => instrPlayedLastPhrase;
    for (0 => int i; i < phraseDiv; i++) {
        // Play the sample if required and it's less than the stop number then play it
        if ((samplePos[sampleIndx] == i) && (countLocl < stopNumber) && (sampleNoteTime[sampleIndx] > 0.0) && (finishPlaying == 0)) {
            // Only checks the probabilty when the other conditions are true        
            if (Math.randomf() >= sampleProbPlay) {
                // Play the sample slice
                spork ~ playSample(sampleNoteTime[sampleIndx]);
            }    
            // Increment sample indx counter
            sampleIndx++;

            // Increment counter when instrument is played
            instrPlayedLastPhrase++;
        }    
        // Wait for a div time to pass
        Library.waitDivTime(timerInfo, evenVal);

        // Swap sign
        -1 * evenVal => evenVal;
    }

    //cherr <= "Thunder: \"" <= finishPlaying <= IO.newline();  
}  

// Close/remove the sporked shred using its ID
Machine.remove(shredId.id());

//----------------------------------------------------------------------------
// Function to play part of sample
//----------------------------------------------------------------------------
fun void playSample(float playTime) {

    // Open up the envelope
    1.0 => envelope[0].value => envelope[1].value;

    1 => finishPlaying;

    // Play from the begining to the start of the loop
    0 => buffer.pos;

    Math.min(playTime, sliceNoteSec) => float val;
    val::second => now;

    // Ramp off
    envelope[0].keyOff();
    envelope[1].keyOff();
    rampTimeSec::second => now;

    0 => finishPlaying;

    countLocl++;
    cherr <= "Finished Thunder: " <= countLocl <= IO.newline();        
}

//----------------------------------------------------------------------------
// OpenSoundControl (OSC) receiver for Instr
//----------------------------------------------------------------------------
fun void OscRecvr()
{

    // create our OSC receiver
    OscIn oscIn;
    // create our OSC message
    OscMsg msg;
    // OSC Input port 
    Library.OSCINPORT => oscIn.port;

    // create an address in the receiver, expect an int and a float
    oscIn.addAddress( "/song/*");

    // infinite event loop
    while( true )
    {
        // wait for event to arrive
        oscIn => now;

        // grab the next message from the queue. 
        while( oscIn.recv(msg) )
        {
            // print stuff
            // cherr <= "received OSC message: \"" <= msg.address <= "\" "
            //      <= "typetag: \"" <= msg.typetag <= "\" "
            //      <= "arguments: " <= msg.numArgs() <= IO.newline();        

            // Master setup
           if (msg.address == "/song/master/setup" + oscInstrMsgSongPhrase) {
                msg.numArgs() => oscMsgRecvr;
                msg.getInt(0) => oscNumBeats;
                msg.getInt(1) => oscBeatDivision;
                msg.getInt(2) => oscBeatBar;
                msg.getFloat(3) => oscSongTempo;
                oscNumBeats * oscBeatDivision => oscPhraseDiv;
                // Check to see if this instrument is affected
                for (4 => int i; i < oscMsgRecvr; 2 +=> i) {
                    msg.getInt(i) => int loclInt;
                    if (instrEnblVal == loclInt) {
                        msg.getInt(i+1) * oscBeatDivision => oscPhraseDiv;
                    }
                } 
            }

            // Master Fade
            if (msg.address == "/song/master/fade/" + instrEnblStr) {
                // Only do something if the message is non zero
                msg.getFloat(0) => oscFadeDur;
                if (oscFadeDur != 0.0) {
                    msg.numArgs() => oscMsgFadeRecvr;
                }
            }

            // Filter Fade
            if (msg.address == "/song/master/filt/" + instrEnblStr) {
                // Only do something if the message is non zero
                msg.getFloat(0) => oscFiltFadeDur;
                if (oscFiltFadeDur != 0.0) {
                    msg.numArgs() => oscMsgFiltFadeRecvr;
                }
            }

            // Drums
            if (msg.address == oscInstrMsgName) {
                msg.numArgs() => oscMsgInstrRecvr;
                if (msg.numArgs() != 1) {
                    msg.getFloat(0) => oscInstrAmp;
                    msg.getInt(1) => oscInstrStop;
                    msg.getInt(2) => oscInstrDelay;
                    msg.getFloat(3) => oscInstrProbPlay;
                    msg.getFloat(4) => oscInstrProbGlitch;
                    msg.getFloat(5) => oscInstrProbSlice;
                    msg.getFloat(6) => oscInstrShufflePercent;
                    msg.getString(7) => oscStrMsg;
                    // Collect the note information
                     msg.getInt(8) => oscNumElements;
                    // Allow bypass changing what is played
                    if (oscNumElements > 0) {
                        // Populate the new instrument information
                        for (0 => int i; i < oscNumElements; i++) {
                            msg.getInt(9 + i * 7) => oscInstrArrayPos[i];
                            msg.getFloat(10 + i * 7) => oscInstrArrayNote[i];
                            // YOU CAN SWAP THIS STRAIGHT WITH OTHER INSTRUMENTS
                            msg.getFloat(11 + i * 7) => oscInstrArrayNoteTime[i];
                            msg.getFloat(12 + i * 7) => oscInstrArrayEmphasis[i];
                            msg.getInt(13 + i * 7) => oscInstrArraySliceIndx[i];
                            msg.getFloat(14 + i * 7) => oscInstrArrayEffect1[i];
                            msg.getFloat(15 + i * 7) => oscInstrArrayEffect2[i];
                        }
                        // Put the position information beyond the length of the phrase
                        phraseDiv + 1 => oscInstrArrayPos[oscNumElements];
                    } 
                }            
                else {
                    msg.getInt(0) => oscInstrStop;
                }
            }    
            // Stop the instrument
            if (msg.address == oscInstrMsgName+"/kill") {
                if (msg.numArgs() == 1) {
                    0 => oscInstrPlay;
                }
            }  
        }     
    }

}

