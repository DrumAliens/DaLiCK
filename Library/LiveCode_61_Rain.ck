
CHmUsiCK Library => SndBuf2 buffer => Envelope fader[2] => dac;

"/song/sounds/rain" => string oscInstrMsgName;

me.dir() + "Samples/frogsAnd/41937__dobroide__20071002.downpour.wav" => buffer.read;
buffer.samples() => buffer.pos;

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

1 => int oscInstrPlay;
1.0 => float oscInstrAmp;
1.0 => float oscInstrFreq;
0 => int oscInstrDelay;
1.0 => float oscInstrGain;

4.0 => float oscFadeDur;
int oscFadeEnbleArray[16];

// Start the OSC Message Receiver
spork ~ OscRecvr();

// Wait for the OSC signal on the song information
while (oscMsgRecvr == 0){
    samp => now;
}
// Reset the osc message flag 
0 => oscMsgRecvr;

// Switch on the master fader envelope
1.0 => fader[0].value;
1.0 => fader[1].value;

// NEED TO PUT A WAIT HERE TO ALIGN WITH THE TIME AND THE START OF A PHRASE

// Setup the initial counter     

// Calculate the timing information
TimerInfo timerInfo;
Library.calcTimer(oscNumBeats, oscBeatDivision, oscSongTempo, oscInstrShufflePercent) @=> timerInfo;

timerInfo.numPhraseDivisions*timerInfo.divVal => float val;
val::second => dur phraseDur;

// This waits for each phrase cycle and exits if called
while(oscInstrPlay)
{

    // Wait for a new phrase 
    phraseDur => now;

    // Map across OSC Instrument changes 
    if (oscMsgInstrRecvr > 0){

        if (oscInstrDelay == 0) {
            oscInstrFreq => buffer.rate;            
            oscInstrAmp => buffer.gain;
            0 => oscMsgInstrRecvr;
            // Exit the while loop
            0 => oscInstrPlay;
        }
        else {
            oscInstrDelay--;
        }        
    }
}  

// Play from the begining to the start of the loop
// This puts it a a point 14 seconds into the wav file
617000 => int startLoop;
0 => buffer.pos;
startLoop::samp => now;

// Enable the while loop to play
1 => oscInstrPlay;

// Loop round the sample
while(oscInstrPlay)
{

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

    // Just play the next 10 seconds of the sample on a loop
    startLoop => buffer.pos;
    10.0::second => now;

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

            // Instrument
            if (msg.address == oscInstrMsgName) {
                msg.numArgs() => oscMsgInstrRecvr;
                if (msg.numArgs() != 1) {
                    msg.getFloat(0) => oscInstrAmp;
                    msg.getFloat(1) => oscInstrFreq;
                    msg.getInt(2) => oscInstrDelay;
                }            
            }  
        }     
    }

}

