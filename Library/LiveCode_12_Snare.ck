CHmUsiCK Library;
SndBuf2 buffer => Envelope envelope[2] => JCRev rev[2] => HPF instrHPF[2] => Envelope fader[2] => dac;

"/song/drums/snare" => string oscInstrMsgName;
me.dir() + "Samples/resources/OS_TS_Snare_2.wav" => buffer.read;
buffer.samples() => int sampleEnd;
sampleEnd => buffer.pos;

// Get the sample rate
buffer.sampleRate() => float sampleHz;

// Map out the slices in the sample
sampleEnd / sampleHz => float sliceNoteSec;
0 => int sliceNotePos;

0 => int songFadeEnblIndx;

// Setup the enve[0]ope
0.02 => float rampTimeSec;
rampTimeSec::second => envelope[0].duration  => envelope[1].duration;
1.0 => envelope[0].value => envelope[1].value;

55 => instrHPF[0].freq => instrHPF[1].freq;
0.6 => instrHPF[0].Q => instrHPF[1].Q;

0.004 => rev[0].mix => rev[1].mix;

// Switch on the master fader envelope
1.0 => fader[0].value => fader[1].value;

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
        Math.fabs(oscFadeDur)::second => fader[0].duration => fader[1].duration;
        if (oscFadeDur < 0.0) {
           fader[0].keyOff();
           fader[1].keyOff();
        }
        else {
           fader[0].keyOn();   
           fader[1].keyOn();   
        }
        // Reset the osc message flag 
        0 => oscMsgFadeRecvr;
    }

    0 => int sampleIndx;
    1 => int evenVal;
    for (0 => int i; i < timerInfo.numPhraseDivisions; i++) {

        // Play the sample if required and it's less than the stop number then play it
        if ((samplePos[sampleIndx] == i) && (countLocl < stopNumber) && (sampleNumNoteDivs[sampleIndx] > 0)) {
            // Only checks the probabilty when the other conditions are true        
            if (Math.randomf() <= sampleProb) {
                // Set the individual sample amplitude    
                sampleEmphasis[sampleIndx] * instrAmp => buffer.gain;

                // Sort out slice start postion
                sliceNotePos => buffer.pos;                         
            }    
            // Increment sample indx counter
            sampleIndx++; 
        }    
         // Wait for a div time to pass
        Library.waitDivTime(timerInfo, evenVal);

        // Switch sign
        -1 * evenVal => evenVal;
    }
    countLocl++;
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

