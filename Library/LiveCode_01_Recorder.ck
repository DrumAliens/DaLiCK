CHmUsiCK Library;

// Osc sender object
OscOut oscOut;
// Aim the transmitter to a destination
oscOut.dest("127.0.0.1", 49163);

// ============= DON'T CHANGE BEYOND HERE

"/song/master" => string oscInstrMsgRoot;

0 => int oscMsgRecvr;
1 => int oscInstrPlay;

16 => int oscNumBeats;
4 => int oscBeatDivision;
4 => int oscBeatBar;
120.0 => float oscSongTempo;

// Start the OSC Message Receiver
spork ~ OscRecvr() @=> Shred @shredId;

// Wait for the OSC signal on the song information
while (oscMsgRecvr == 0){
    samp => now;
}
// Reset the osc message flag 
0 => oscMsgRecvr;

dac => WvOut2 w => blackhole;

// Set the output file name
"my_recording.wav" => w.wavFilename;

// Loop round the sample
while(oscInstrPlay)
{
    // Record for 60 seconds
    5.0::second => now;
}

// Close the file properly to flush data
w.closeFile();

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
    // use port 49162 (or whatever)
    49162 => oscIn.port;

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
            //  - ignores any additional strings past /setup
            //    if the system is triggering specific groups of instruments
            if (msg.address.find(oscInstrMsgRoot + "/setup") == 0) {
                msg.numArgs() => oscMsgRecvr;
                msg.getInt(0) => oscNumBeats;
                msg.getInt(1) => oscBeatDivision;
                msg.getInt(2) => oscBeatBar;
                msg.getFloat(3) => oscSongTempo;
            }

            // Stop the instrument
            if (msg.address == oscInstrMsgRoot + "/kill") {
                if (msg.numArgs() == 1) {
                    0 => oscInstrPlay;
                }
            }  

        }     
    }

}

