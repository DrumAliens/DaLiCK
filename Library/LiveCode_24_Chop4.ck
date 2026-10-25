CHmUsiCK Library;

LiSa buffer[2] => JCRev rev[2] => HPF instrHPF[2] => LPF instrLPF[2] => Envelope fader[2] => dac;

"4" => string rootStrNum;
"/song/vocals/chop" + rootStrNum => string oscInstrMsgName;
"/barstardisation" => string oscInstrMsgSongPhrase;

buffer[0].read(me.dir() + "Samples/resources/chop" + rootStrNum + "_Left.wav");
buffer[1].read(me.dir() + "Samples/resources/chop" + rootStrNum + "_Right.wav");

"2" + rootStrNum => string instrEnblStr;
Std.atoi(instrEnblStr) => int instrEnblVal;

// Work out the length of the sample 
buffer[0].duration() / 1::second => float sliceNoteSec;

// Map play back rate to a midi note
Library.MIDIROOTNOTE + Library.chopMidiOffset => float midiRootNote;

// Sort frequency of slice - assume midi 72 (C4) is 1.0
Math.pow(2.0, (midiRootNote - Library.MIDIROOTNOTE) / 12.0) => float sampleRatio;

// Setup the LiSa sample envelope
0.0::second => dur rampUpTimeDur;
0.05::second => dur rampDownTimeDur;

200 => instrHPF[0].freq => instrHPF[1].freq;
0.6 => instrHPF[0].Q => instrHPF[1].Q;

6000 => instrLPF[0].freq => instrLPF[1].freq;
0.6 => instrLPF[0].Q => instrLPF[1].Q;

0.04 => rev[0].mix => rev[1].mix;

// Switch on the master fader envelope
1.0 => fader[0].value => fader[1].value;

// ============= DON'T CHANGE BEYOND HERE

0 => int oscMsgRecvr;
0 => int oscMsgInstrRecvr;
0 => int oscMsgFadeRecvr;

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

// Number of beats that make up a phrase
Library.MAXNUMNOTES => int arrayLen;
arrayLen => int oscNumElements;

// Position of note
int oscInstrArrayPos[arrayLen];
int samplePos[arrayLen];
// MIDI note to be played
float oscInstrArrayNote[arrayLen];
float sampleNote[arrayLen];
// Length of that note in beats
int oscInstrArrayNumNoteDivs[arrayLen];
int sampleNumNoteDivs[arrayLen];
// Position amp of the slice 
float oscInstrArrayEmphasis[arrayLen];
float sampleEmphasis[arrayLen];
// Position of the slice within a sample 
int oscInstrArraySliceIndx[arrayLen];
int sampleSliceIndx[arrayLen];
// Effects arrays 
float oscInstrArrayEffect1[arrayLen];
float sampleEffect1[arrayLen];
float oscInstrArrayEffect2[arrayLen];
float sampleEffect2[arrayLen];

4.0 => float oscFadeDur;

// Setup the initial counter     
0 => int countLocl;
99999999 => int stopNumber;

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
            oscInstrAmp => instrAmp;
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

    // Loop round and play the sample slice
    0 => int sampleIndx;
    1 => int evenVal;
    0 => instrPlayedLastPhrase;
    for (0 => int i; i < phraseDiv; i++) {
        // Play the sample if required and it's less than the stop number then play it
        if ((samplePos[sampleIndx] == i) && (countLocl < stopNumber) && (sampleNumNoteDivs[sampleIndx] > 0)) {
            // Only checks the probabilty when the other conditions are true        
            if (Math.randomf() >= sampleProbPlay) {

                // Check length of sample
                Math.min(sliceNoteSec / sampleRatio, sampleNumNoteDivs[sampleIndx] * timerInfo.divVal + evenVal * timerInfo.shuffleOffset) => float samplePlayTime;

                // Play the sample slice
                spork ~ Library.lisaPlaySample(buffer[0], 0::samp, samplePlayTime::second, rampUpTimeDur, rampDownTimeDur, sampleRatio, sampleEmphasis[sampleIndx] * instrAmp);
                spork ~ Library.lisaPlaySample(buffer[1], 0::samp, samplePlayTime::second, rampUpTimeDur, rampDownTimeDur, sampleRatio, sampleEmphasis[sampleIndx] * instrAmp);

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
    countLocl++;
}  

// Close/remove the sporked shred using its ID
Machine.remove(shredId.id());

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
