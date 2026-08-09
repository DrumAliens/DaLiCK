
CHmUsiCK Library => SndBuf2 buffer => Envelope envelope[2] => dac;

"/song/sounds/thunder" => string oscInstrMsgName;

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

// 32dec
5 => int songFadeEnblIndx;

// ============= DON'T CHANGE BEYOND HERE

0 => int oscMsgRecvr;
0 => int oscMsgInstrRecvr;
0 => int oscMsgFadeRecvr;

// Map across the song parameters
16 => int oscNumBeats;
4 => int oscBeatDivision;
120.0 => float oscSongTempo;
50.0 => float oscInstrShufflePercent;
// Calculate the timing information
TimerInfo timerInfo;
Library.calcTimer(oscNumBeats, oscBeatDivision, oscSongTempo, oscInstrShufflePercent) @=> timerInfo;

1 => int oscInstrPlay;
1.0 => float oscInstrAmp;
0 => int oscInstrDelay;
5 => int oscInstrStop => int instrStop;
1.0 => float oscInstrGain;
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
// Length of that note in seconds
float oscInstrArrayNoteTime[arrayLen];
float sampleNoteTime[arrayLen];
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

// NEED TO PUT A WAIT HERE TO ALIGN WITH THE TIME AND THE START OF A PHRASE

// Setup the initial counter     
oscNumBeats => int numBeats;
oscBeatDivision => int beatDivision;
oscSongTempo => float songTempo;

// Calculate the timing information
Library.calcTimer(oscNumBeats, oscBeatDivision, oscSongTempo, oscInstrShufflePercent) @=> timerInfo;

timerInfo.numPhraseDivisions*timerInfo.divVal => float val;
val::second => dur phraseDur;

// Flag to allow the played sample to complete
0 => int finishPlaying;

// This waits for each phrase cycle and exits if called
while(oscInstrPlay == 1)
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

        if (oscInstrDelay == 0) {
            // oscInstrAmp => buffer.gain;
            oscInstrAmp => buffer.gain;
            oscInstrStop => stopNumber;
            oscInstrProb => sampleProb;

            // Update the timing information
            Library.calcTimer(numBeats, beatDivision, songTempo, oscInstrShufflePercent) @=> timerInfo;

            0 => countLocl;
            // Copy across the instrument information
            for (0 => int i; i < arrayLen; i++) {
                oscInstrArrayPos[i] => samplePos[i];
                oscInstrArrayNote[i] => sampleNote[i];
                oscInstrArrayNoteTime[i] => sampleNoteTime[i];
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

    0 => int sampleIndx;
    1 => int evenVal;
    for (0 => int i; i < timerInfo.numPhraseDivisions; i++) {
       // Play the sample if required and it's less than the stop number then play it
       if ((samplePos[sampleIndx] == i) && (countLocl < stopNumber) && (sampleNoteTime[sampleIndx] > 0.0) && (finishPlaying == 0)) {
            // Only checks the probabilty when the other conditions are true        
            if (Math.randomf() <= sampleProb) {

                // Play the sample slice
                spork ~ playSample(sampleNoteTime[sampleIndx]);
            }    
            // Increment sample indx counter
            sampleIndx++;
        }    
        // Wait for a div time to pass
        Library.waitDivTime(timerInfo, evenVal);

        // Swap sign
        -1 * evenVal => evenVal;
    }

}  

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

    // print stuff
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
                            msg.getFloat(8 + i * 5) => oscInstrArrayNoteTime[i];
                            msg.getFloat(9 + i * 5) => oscInstrArrayEmphasis[i];
                            msg.getInt(10 + i * 5) => oscInstrArraySliceIndx[i];
                        }
                    } 
                }            
                else {
                    msg.getInt(0) => oscInstrStop;
                }
            }    
        }     
    }

}

