CHmUsiCK Library;

// Number of samples to be loaded in
18 => int numNotes;
float sliceNoteSec[numNotes];

// The sample is mono have added a delay at the end of processing the left channel to give a stereo effect
SndBuf bufferL[numNotes] => Envelope envelopeL => JCRev revL => HPF instrHPFL => Envelope faderL => DelayA delayLine => dac.left;
SndBuf bufferR[numNotes] => Envelope envelopeR => JCRev revR => HPF instrHPFR => Envelope faderR => dac.right;
"/song/guitar/guitar1" => string oscInstrMsgName;
// 64dec
3 => int songFadeEnblIndx;

// Configure the delay
0.015::second => delayLine.max; // Set maximum delay (e.g., 15ms)
0.015::second => delayLine.delay; // Set actual delay time
1.0 => delayLine.gain; // Optional: lower the volume of the delay

// Setup the envelope
0.02 => float rampTimeSec;
rampTimeSec::second => envelopeL.duration => envelopeR.duration; 
1.0 => envelopeL.value => envelopeR.value;

//Setup LPF
55 => instrHPFL.freq => instrHPFR.freq; 
0.6 => instrHPFL.Q => instrHPFR.Q; 

// Setup reverb
0.004 => revL.mix => revR.mix; 

// Switch on the master fader envelope
1.0 => faderL.value => faderR.value; 

// Load int the samples
48 => int strtMidiNote;
// Read in all of the wav files
for (0 => int i; i < numNotes; i++) {

    me.dir() + "Samples/AxGrinder/" + Std.itoa(strtMidiNote + i) + "_44100Hz.wav" => bufferL[i].read => bufferR[i].read;
    // Get the sample rate
    bufferL[i].sampleRate() => float sampleHz;
    // Work out how long that sample is
    bufferL[i].samples() => int bufferLength;
    bufferLength / sampleHz => sliceNoteSec[i];
    // Set play position to end of sample
    bufferLength => bufferL[i].pos => bufferR[i].pos;  
}

// ============= DON'T CHANGE BEYOND HERE

0 => int oscMsgRecvr;
0 => int oscMsgInstrRecvr;
0 => int oscMsgFadeRecvr;

16 => int oscNumBeats;
4 => int oscBeatDivision;
120.0 => float oscSongTempo;
50.0 => float oscInstrShufflePercent;
// Calculate the timing information
TimerInfo timerInfo;
Library.calcTimer(oscNumBeats, oscBeatDivision, oscSongTempo, oscInstrShufflePercent) @=> timerInfo;
timerInfo.numPhraseDivisions => int oscPhraseNumDivision => int phraseNumDivision;

1 => int oscInstrPlay;
1.0 => float oscInstrAmp => float instrAmp;
9999999 => int oscInstrStop;
0 => int oscInstrDelay;
1.0 => float oscInstrProb => float sampleProb;

4.0 => float oscFadeDur;
int oscFadeEnbleArray[16];

// Setup the initial counter     
0 => int countLocl;
99999999 => int stopNumber;

// Number of beats that make up a phrase
Library.MAXNUMNOTES => int arrayLen;

// Position of note
int oscInstrArrayPos[arrayLen];
int samplePos[arrayLen];
// MIDI note to be played
int oscInstrArrayNote[arrayLen];
int sampleNote[arrayLen];
// Position amp of the slice 
float oscInstrArrayEmphasis[arrayLen];
float sampleEmphasis[arrayLen];
// Length of that note in beats
int oscInstrArrayNumNoteDivs[arrayLen];
int sampleNumNoteDivs[arrayLen];
// Position of the slice within a sample 
int oscInstrArraySliceIndx[arrayLen];
int sampleSliceIndx[arrayLen];

// Start the OSC Message Receiver
spork ~ OscRecvr();

// Wait for the OSC signal on the song information
while (oscMsgRecvr == 0){
    samp => now;
}
// Reset the osc message flag 
0 => oscMsgRecvr;

oscNumBeats => int numBeats;
oscBeatDivision => int beatDivision;
oscSongTempo => float songTempo;

// Calculate the timing information
Library.calcTimer(numBeats, beatDivision, songTempo, oscInstrShufflePercent) @=> timerInfo;

// Loop round the sample
while(oscInstrPlay)
{

   // Master 
    if (oscMsgRecvr > 0){
        oscNumBeats => numBeats;
        oscBeatDivision => beatDivision;
        oscSongTempo => songTempo;
        
        // Calculate the timing information
        Library.calcTimer(numBeats, beatDivision, songTempo, oscInstrShufflePercent) @=> timerInfo;

		// Reset the osc message flag 
		0 => oscMsgRecvr;
    }

    // Map across OSC Instrument changes 
    if (oscMsgInstrRecvr > 0){
        // If the phrase is delayed then need to wait before updating
        if (oscInstrDelay == 0) {
            oscInstrAmp => instrAmp;
            oscInstrStop => stopNumber;
            oscInstrProb => sampleProb;
            oscPhraseNumDivision => phraseNumDivision;

            // Update the timing information
            Library.calcTimer(numBeats, beatDivision, songTempo, oscInstrShufflePercent) @=> timerInfo;

            0 => countLocl;
            // Copy across the instrument information
            for (0 => int i; i < arrayLen; i++) {
                oscInstrArrayPos[i] => samplePos[i];
                oscInstrArrayNote[i] => sampleNote[i];
                oscInstrArrayNumNoteDivs[i] => sampleNumNoteDivs[i];
                oscInstrArrayEmphasis[i] => sampleEmphasis[i];
                oscInstrArraySliceIndx[i] => sampleSliceIndx[i];
            }

            // Reset the osc message flag 
            0 => oscMsgInstrRecvr;
        }
        else {
            oscInstrDelay--;
        }
    }

    // Master Fader 
    if (oscFadeEnbleArray[songFadeEnblIndx] == 1 && oscMsgFadeRecvr > 0) {
        // Set the length of time to fade over
        Math.fabs(oscFadeDur)::second => faderL.duration => faderR.duration;
        // Fade to zero
        if (oscFadeDur < 0.0) {
           faderL.keyOff();
           faderR.keyOff();
        }
        // Fade to one
        else {
           faderL.keyOn();
           faderR.keyOn();
        }
        // Reset the osc message flag 
        0 => oscMsgFadeRecvr;
    }

    // Loop round and play the sample slice
    0 => int sampleIndx;
    1 => int evenVal;
    for (0 => int i; i < phraseNumDivision; i++) {
        // Play the sample if required and it's less than the stop number then play it
        if ((samplePos[sampleIndx] == i) && (countLocl < stopNumber) && (sampleNumNoteDivs[sampleIndx] > 0)) {
            // Only checks the probabilty when the other conditions are true        
            if (Math.randomf() <= sampleProb) {

                // Map across MIDI note to buffer index   
                Math.clampi(sampleNote[sampleIndx] - strtMidiNote, 0, numNotes - 1) => int bufferIndx;
            
                // Set the individual sample amplitude   
                sampleEmphasis[sampleIndx] * instrAmp => bufferL[bufferIndx].gain => bufferR[bufferIndx].gain;
            
                // Play the sample slice
                spork ~ playSample(Library.MIDIROOTNOTE, bufferIndx, sliceNoteSec[bufferIndx], sampleNumNoteDivs[sampleIndx] * timerInfo.divVal  + evenVal * timerInfo.shuffleOffset);
            }    
            // Increment sample indx counter
            sampleIndx++;
        }    
        // Wait for a div time to pass
        Library.waitDivTime(timerInfo, evenVal);

        // Swap sign
        -1 * evenVal => evenVal;
    }
    countLocl++;

    // <<< "52", faderL.value() >>>;
}  

//----------------------------------------------------------------------------
// Function to play part of sample
//----------------------------------------------------------------------------
fun void playSample(float midiNote, int sliceNoteIndx, float sliceSec, float beatTime) {

    // Sort out slice start postion
    0 => bufferL[sliceNoteIndx].pos  => bufferR[sliceNoteIndx].pos;

    // Sort frequency of slice - assume midi 72 (C4) is 1.0
    Math.pow(2.0, (midiNote - Library.MIDIROOTNOTE) / 12.0) => float rate;
    rate => bufferL[sliceNoteIndx].rate => bufferR[sliceNoteIndx].rate;
    
    // Calculate how long to play that slice for 
    // - adjust for pitch changes 
    // - make sure it only plays that sample slice
    // - subtract the ramp off time - ramp up is included when start to play the slice
    Math.min(sliceSec / rate, beatTime) - rampTimeSec=> float val;

    // Ramp up - assume don't need anything as starts have been set to zero crossing
    1.0 => envelopeL.value => envelopeR.value; 
    // Play the slice
    val::second => now;

    // Ramp off
    envelopeL.keyOff();
    envelopeR.keyOff();
    rampTimeSec::second => now;

    // Put play head at end of sample
    bufferL[sliceNoteIndx].samples() => bufferL[sliceNoteIndx].pos  => bufferR[sliceNoteIndx].pos;

}

///----------------------------------------------------------------------------
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
            if (msg.address == "/song/master/setup") {
                msg.numArgs() => oscMsgRecvr;
                msg.getInt(0) => oscNumBeats;
                msg.getInt(1) => oscBeatDivision;
                msg.getFloat(2) => oscSongTempo;
            }

            // Master Fade
            if (msg.address == "/song/master/fade") {
                // Only do something if the message is non zero
                msg.getFloat(0) => oscFadeDur;
                if (oscFadeDur != 0.0) {
                    msg.numArgs() => oscMsgFadeRecvr;
                    Library.dec2Pos(msg.getInt(1)) @=> oscFadeEnbleArray;
                }
            }

            // Drums
            if (msg.address == oscInstrMsgName) {
                msg.numArgs() => oscMsgInstrRecvr;
                if (msg.numArgs() != 1) {
                    msg.getFloat(0) => oscInstrAmp;
                    msg.getInt(1) => oscInstrStop;
                    msg.getInt(2) => oscInstrDelay;
                    msg.getFloat(3) => oscInstrProb;
                    msg.getFloat(4) => oscInstrShufflePercent;
                    msg.getInt(5) => oscPhraseNumDivision;
                    // Collect the note information
                    msg.getInt(6) => int oscNumElements;
                    // Allow bypass changing what is played
                    if (oscNumElements > 0) {
                        // Put the position information beyond the length of the phrase
                        for (0 => int i; i < arrayLen; i++) {
                            oscPhraseNumDivision + 1 => oscInstrArrayPos[i];
                        }
                        // Populate the new instrument information
                        for (0 => int i; i < oscNumElements; i++) {
                            msg.getInt(7 + i * 5) => oscInstrArrayPos[i];
                            msg.getInt(8 + i * 5) => oscInstrArrayNote[i];
                            msg.getInt(9 + i * 5) => oscInstrArrayNumNoteDivs[i];
                            msg.getFloat(10 + i * 5) => oscInstrArrayEmphasis[i];
                            msg.getInt(11 + i * 5) => oscInstrArraySliceIndx[i];
                        }
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

