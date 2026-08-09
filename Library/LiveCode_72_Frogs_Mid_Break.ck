CHmUsiCK Library => SndBuf buffer  => Envelope envelope => Envelope fader => dac;

"/song/sounds/frogs_mid" => string oscInstrMsgName;

me.dir() + "Samples/frogsAnd/Drum_Frogs_32511__daveincamas_Right_Processed.wav" => buffer.read;

buffer.samples() => int sampleEnd;
sampleEnd => buffer.pos;
1.0 => buffer.rate; 

// 64dec
6 => int songFadeEnblIndx;

// Get the sample rate
buffer.sampleRate() => float sampleHz;

// Map out the slices in the sample
8 => int numSampleSlices;
int sliceNotePos[numSampleSlices];
float sliceNoteSec[numSampleSlices];
// x00
670 => sliceNotePos[0];
// x1D
21639 => sliceNotePos[1];
// x3D
44315 => sliceNotePos[2];
// x62
72207 => sliceNotePos[3];
// x83
95543 => sliceNotePos[4];
// x95
116481 => sliceNotePos[5];
// xC3
139668 => sliceNotePos[6];
sampleEnd => sliceNotePos[7];

// Work out the time of each section of the sample
for (0 => int i; i < numSampleSlices - 1; i++) {
    (sliceNotePos[i+1] - sliceNotePos[i]) / sampleHz => sliceNoteSec[i];
}

// Setup the envelope
0.05 => float rampTimeSec;
rampTimeSec::second => envelope.duration;
1.0 => envelope.value;

// Switch on the master fader envelope
1.0 => fader.value;

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
arrayLen => int oscNumElements;

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

            // Update the timing information
            Library.calcTimer(numBeats, beatDivision, songTempo, oscInstrShufflePercent) @=> timerInfo;

            0 => countLocl;
             // Copy across the notes and zero samplePos
            for (0 => int i; i < arrayLen; i++) {
                if (i < oscNumElements) {
                    oscInstrArrayPos[i] => samplePos[i];
                    oscInstrArrayNote[i] => sampleNote[i];
                    oscInstrArrayNumNoteDivs[i] => sampleNumNoteDivs[i];
                    oscInstrArrayEmphasis[i] => sampleEmphasis[i];
                    oscInstrArraySliceIndx[i] => sampleSliceIndx[i];
                }
                else {
                    // Set the rest of the position information beyond the phrase length
                    timerInfo.numPhraseDivisions + 1 => samplePos[i];
                }    
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

    // Loop round and play the sample slice
    0 => int sampleIndx;
    1 => int evenVal;
    for (0 => int i; i < timerInfo.numPhraseDivisions; i++) {
        // Play the sample if required and it's less than the stop number then play it
        if ((samplePos[sampleIndx] == i) && (countLocl < stopNumber) && (sampleNumNoteDivs[sampleIndx] > 0)) {
            // Only checks the probabilty when the other conditions are true        
            if (Math.randomf() <= sampleProb) {

                // Set the individual sample amplitude   
                sampleEmphasis[sampleIndx] * instrAmp => buffer.gain;

                // Map across the correct position within the sample
                Math.clampi(sampleSliceIndx[sampleIndx], 0, numSampleSlices - 1) => int indx;

                // Play the sample slice
                spork ~ playSample(sampleNote[sampleIndx], sliceNotePos[indx], sliceNoteSec[indx], sampleNumNoteDivs[sampleIndx] * timerInfo.divVal + evenVal * timerInfo.shuffleOffset);
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
}  

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
    Math.min(sliceSec / rate, beatTime) - rampTimeSec=> float val;

    // Ramp up - assume don't need anything as starts have been set to zero crossing
    1.0 => envelope.value;

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
                    // Collect the note information
                     msg.getInt(5) => int oscNumElements;
                    // Allow bypass changing what is played
                    if (oscNumElements > 0) {
                        // Put the position information beyond the length of the phrase
                        for (0 => int i; i < arrayLen; i++) {
                            timerInfo.numPhraseDivisions + 1 => oscInstrArrayPos[i];
                        }
                        // Populate the new instrument information
                        for (0 => int i; i < oscNumElements; i++) {
                            msg.getInt(6 + i * 5) => oscInstrArrayPos[i];
                            msg.getInt(7 + i * 5) => oscInstrArrayNote[i];
                            msg.getInt(8 + i * 5) => oscInstrArrayNumNoteDivs[i];
                            msg.getFloat(9 + i * 5) => oscInstrArrayEmphasis[i];
                            msg.getInt(10 + i * 5) => oscInstrArraySliceIndx[i];
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

