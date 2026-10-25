CHmUsiCK Library => LiSa buffer => Envelope fader => Pan2 pan => dac;

"/song/sounds/ohhowvocals_mid" => string oscInstrMsgName;
"/steamengine" => string oscInstrMsgSongPhrase;
buffer.read(me.dir() + "Samples/SteamEngine/OhHowLovelyIsTheEvening_Split_Mono.wav");

// Set the ratio for the sample
0.97 => float sampleRatio;

// 64dec
"81" => string instrEnblStr;
Std.atoi(instrEnblStr) => int instrEnblVal;

// Map out the slices in the sample
14 => int numSampleSlices;
int sliceNotePos[numSampleSlices];
// dur sliceNoteDur[numSampleSlices];
// Oh how-love-ly is
19683 => sliceNotePos[0];
// the eve-ning
// 48332 => sliceNotePos[1];
// 94227 => sliceNotePos[2];
143996 => sliceNotePos[1];
// // is
209026 => sliceNotePos[2];
// // the even-ing
241283 => sliceNotePos[3];
// When
313383 => sliceNotePos[4];
// the
// 342200 => sliceNotePos[7];
// bells
// 359047 => sliceNotePos[7];
// // are
// 391106 => sliceNotePos[8];
// // sweet-
407911 => sliceNotePos[5];
// // ly ring-ing
// 439725 => sliceNotePos[10];
// // sweet-
504626 => sliceNotePos[6];
// // ly ring-ing
// 533150 => sliceNotePos[12];
// ding
// 600310 => sliceNotePos[2];
598262 => sliceNotePos[7];
// dong
649009 => sliceNotePos[8];
// ding
699857 => sliceNotePos[9];
// dong
749224 => sliceNotePos[10];
// ding
799660 => sliceNotePos[11];
// dong
848884 => sliceNotePos[12];
// end
905355 => sliceNotePos[13];

// Work out the time of each section of the sample
float sliceNoteSec[numSampleSlices - 1];
for (0 => int i; i < numSampleSlices - 1; i++) {
    (sliceNotePos[i+1] - sliceNotePos[i]) / Library.sampleHz => sliceNoteSec[i];
}

// Setup the LiSa sample envelope
0.0::second => dur rampUpTimeDur;
0.01::second => dur rampDownTimeDur;

// Pan to the middle
0.0 => pan.pan;

// Switch on the master fader envelope
1.0 => fader.value;         

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
            // Copy across the notes and zero samplePos
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

    // Loop round and play the sample slice
    0 => int sampleIndx;
    1 => int evenVal;
    0 => instrPlayedLastPhrase;
    for (0 => int i; i < phraseDiv; i++) {

        // Play the sample if required and it's less than the stop number then play it
        if ((samplePos[sampleIndx] == i) && (countLocl < stopNumber) && (sampleNumNoteDivs[sampleIndx] > 0)) {
            // Only checks the probabilty when the other conditions are true        
            if (Math.randomf() >= sampleProbPlay) {

                // Select the requested sample
                Math.clampi(sampleSliceIndx[sampleIndx], 0, numSampleSlices - 1) => int indx;

                 // Check length of sample
                Math.min(sliceNoteSec[indx] / sampleRatio, sampleNumNoteDivs[sampleIndx] * timerInfo.divVal + evenVal * timerInfo.shuffleOffset) => float samplePlayTime;

                // Play the sample slice
                spork ~ Library.lisaPlaySample(buffer, sliceNotePos[indx]::samp, samplePlayTime::second, rampUpTimeDur, rampDownTimeDur, sampleRatio, sampleEmphasis[sampleIndx] * instrAmp);

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

