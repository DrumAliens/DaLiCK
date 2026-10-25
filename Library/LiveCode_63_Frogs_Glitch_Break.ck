CHmUsiCK Library => SndBuf buffer => Gain normPass => Gain glitchGain => Envelope envelope => Gain outputGain => Envelope fader  => LPF instrLPF => Pan2 pan => dac;

// Sort out the feedback for the glitch delay signal
outputGain => Delay delayEffect => Gain glitchPass => glitchGain;

// Configure the delay line
2.5::second => delayEffect.max;
1.0 => delayEffect.gain;
// 0.06 => float minDelay;
// 0.2 => float maxDelay;

// For the rate change of 1.2 the warbles at the end are about 0.05 seconds
// so vary around this amount
0.25 => float minDelay;
0.5 => float maxDelay;
maxDelay::second => delayEffect.delay;

// Setup the envelope
0.01 => float rampTimeSec;
rampTimeSec::second => envelope.duration;
1.0 => envelope.value;

// Run the fader for the filter through into a blackhole
Envelope faderFilt => blackhole;

// Run lfo into a blackhole
SinOsc lfo => blackhole;
// Set the lof period t be 5 seconds
0.2 => lfo.freq;
// Set initial pan in the middle
0.0 => pan.pan;

"/song/sounds/frogs_glitch" => string oscInstrMsgName;
"/frogs" => string oscInstrMsgSongPhrase;
me.dir() + "Samples/frogsAnd/Drum_Frogs_32511__daveincamas_Right_Processed.wav" => buffer.read;

buffer.samples() => int sampleEnd;
sampleEnd => buffer.pos;
1.0 => buffer.rate; 

// 64dec
"63" => string instrEnblStr;
Std.atoi(instrEnblStr) => int instrEnblVal;

// Get the sample rate
buffer.sampleRate() => float sampleHz;
// Work out the sample length in time
sampleEnd / sampleHz => float sampleSecTotal;

// Map out the slices in the sample
16 => int numSampleSlices;
int sliceNotePos[numSampleSlices + 1];
float sliceNoteSec[numSampleSlices];

// Sample doesn't start from zero so adjust for it 
670 => int slicePos0; 
// Work out the position of the slice
for (0 => int i; i < numSampleSlices; i++) {
    Std.ftoi(i * (sampleEnd - slicePos0) / numSampleSlices) + slicePos0 => sliceNotePos[i];
}
sampleEnd => sliceNotePos[numSampleSlices];

// Work out the time of each section of the sample
for (0 => int i; i < numSampleSlices; i++) {
    (sliceNotePos[i+1] - sliceNotePos[i]) / sampleHz => sliceNoteSec[i];
}

// Switch on the master fader envelope
1.0 => fader.value;

// Switch on the filter fader envelope
1.0 => faderFilt.value;
60.0 => float filtFadeDurABS;
// Minimum filter cutoff
200 => float minLPFFreq;
// Maximum filter cutoff
24000 => float maxLPFFreq => instrLPF.freq;  
// Work out the delta for spork function
maxLPFFreq / minLPFFreq => float ratioLPFFreq;       
// Filter resonance
3.0 => instrLPF.Q;  

// ============= DON'T CHANGE BEYOND HERE

0 => int oscMsgRecvr;
0 => int oscMsgInstrRecvr;
0 => int oscMsgFadeRecvr;
0 => int oscMsgFiltFadeRecvr;

16 => int oscNumBeats;
4 => int oscBeatDivision;
4 => int oscBeatBar;
120.0 => float oscSongTempo;
50.0 => float oscInstrShufflePercent;
oscNumBeats * oscBeatDivision => int oscPhraseDiv => int phraseDiv;
// Calculate the timing information
TimerInfo timerInfo;

1 => int oscInstrPlay;
1.0 => float oscInstrAmp => float instrAmp;
9999999 => int oscInstrStop;
0 => int oscInstrDelay;
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
// Length of that note in beats
int oscInstrArrayNumNoteDivs[arrayLen];
int sampleNumNoteDivs[arrayLen];
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
while (oscMsgRecvr == 0){
    samp => now;
}
// Reset the osc message flag 
0 => oscMsgRecvr;

oscNumBeats => int numBeats;
oscBeatDivision => int beatDivision;
oscBeatBar => int beatBar;
oscSongTempo => float songTempo;
oscPhraseDiv => phraseDiv;

// Calculate the timing information
Library.calcTimer(numBeats, beatDivision, beatBar, songTempo, oscInstrShufflePercent) @=> timerInfo;

// Fit the sample over two bars
sampleSecTotal / (2 * timerInfo.barVal) => buffer.rate;

// Counter to determine whether the instrument is played over the phrase 
0 => int instrPlayedLastPhrase;

// Loop round the sample
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

        // Workout the ratio to get the sample to match the length of the bpm
        // Fit the sample over two bars
        sampleSecTotal / (2 * timerInfo.barVal) => buffer.rate;

		// Reset the osc message flag 
		0 => oscMsgRecvr;
    }

    // Remove OSC Instrument request to stop an instrument if it hasn't run previously
    // Otherwise you will end up triggering the instrument
    if ((oscMsgInstrRecvr == 1) && (oscInstrStop > 0) && (instrPlayedLastPhrase == 0)) {
        0 => oscMsgInstrRecvr;
    }

    // Map across OSC Instrument changes 
    if (oscMsgInstrRecvr > 0){
        // If the phrase is delayed then need to wait before updating
        if (oscInstrDelay == 0) {
            oscInstrAmp => buffer.gain;
            oscInstrStop => stopNumber;
            oscInstrProbPlay => sampleProbPlay;
            oscInstrProbGlitch => sampleProbGlitch;
            oscInstrProbSlice => sampleProbSlice;

            // Update the timing information
            Library.calcTimer(numBeats, beatDivision, beatBar, songTempo, oscInstrShufflePercent) @=> timerInfo;
            // Fit the sample over two bars
            sampleSecTotal / (2 * timerInfo.barVal) => buffer.rate;

            0 => countLocl;
             // Copy across the notes
            for (0 => int i; i < oscNumElements; i++) {
                oscInstrArrayPos[i] => samplePos[i];
                oscInstrArrayNote[i] => sampleNote[i];
                oscInstrArrayNumNoteDivs[i] => sampleNumNoteDivs[i];
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

    // Master Fader 
    if (oscMsgFadeRecvr > 0) {
        // Set the length of time to fade over
        Math.fabs(oscFadeDur)::second => fader.duration;
        if (oscFadeDur < 0.0) {
           fader.keyOff();
        }
        else {
           fader.keyOn();
        }
        // Reset the osc message flag 
        0 => oscMsgFadeRecvr;
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

    // Loop round and play the sample slice
    0 => int sampleIndx;
    0 => instrPlayedLastPhrase;
    for (0 => int i; i < phraseDiv; i++) {

        // Update the lowpass filter frequency
        minLPFFreq * Math.pow(ratioLPFFreq, (faderFilt.value() * filtFadeDurABS) / filtFadeDurABS) => instrLPF.freq;

        // Play the sample if required and it's less than the stop number then play it
        if ((samplePos[sampleIndx] == i) && (countLocl < stopNumber) && (sampleNumNoteDivs[sampleIndx] > 0)) {

            // Select the requested sample
            Math.clampi(sampleSliceIndx[sampleIndx], 0, numSampleSlices - 1) => int indx;
            // Randomise the order the sample is played
            if (Math.randomf() <= sampleProbSlice) {
                Math.random2(0, numSampleSlices - 1) => indx;
            }
       
            // Set the position of the pan based upon the slice being played
            sampleEffect1[indx] => pan.pan;

            // Randomise the use of the echo delay
            if (Math.randomf() <= sampleProbGlitch) {
                1.0 => glitchPass.gain;
                0.0 => normPass.gain;
            }
            else {
                0.0 => glitchPass.gain;
                1.0 => normPass.gain;
            }    

            // Randomise the delay
            Math.random2f(maxDelay, minDelay)::second => delayEffect.delay;
            
            // // Randomise whether the sample plays
            // 0.0 => outputGain.gain;
            // if (Math.randomf() <= samplePlay) {
            //     1.0 => outputGain.gain;
            // }

            spork ~ playSample(sampleNote[sampleIndx], sliceNotePos[indx], sliceNoteSec[indx], sampleNumNoteDivs[sampleIndx] * timerInfo.divVal);

            // Increment sample indx counter
            sampleIndx++;

            // Increment counter when instrument is played
            instrPlayedLastPhrase++;

        }    
        // Wait for a div time to pass
        Library.waitDivTime(timerInfo, timerInfo.divVal);

    }
    countLocl++;
}  

// Close/remove the sporked shred using its ID
Machine.remove(shredId.id());

//----------------------------------------------------------------------------
// Function to play part of sample
//----------------------------------------------------------------------------
fun void playSample(float midiNote, int slicePos, float sliceSec, float beatTime) {

    // Sort out slice start postion
    slicePos => buffer.pos;
    
    // Sort frequency of slice - assume midi 72 (C4) is 1.0
    Math.pow(2.0, (midiNote - Library.MIDIROOTNOTE) / 12.0) => float rate;
    rate => buffer.rate;
    
    // Calculate how long to play that slice for 
    // - adjust for pitch changes 
    // - make sure it only plays that sample slice
    // - subtract the ramp off time - ramp up is included when start to play the slice
    Math.min(sliceSec / rate, beatTime) - 2 * rampTimeSec=> float val;

    // Ramp on
    envelope.keyOn();
    rampTimeSec::second => now;

    // Play the slice
    val::second => now;

    // Ramp off
    envelope.keyOff();
    rampTimeSec::second => now;

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
                            msg.getInt(11 + i * 7) => oscInstrArrayNumNoteDivs[i];
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

