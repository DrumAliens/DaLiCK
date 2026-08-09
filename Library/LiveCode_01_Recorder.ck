CHmUsiCK Library;

// Osc sender object
OscOut oscOut;
// Aim the transmitter to a destination
oscOut.dest("127.0.0.1", 49163);

// ============= DON'T CHANGE BEYOND HERE

0 => int oscMsgRecvr;

4 => int oscSongCycles;
4 => int oscSongMeasure;
16 => int oscSongDivision;
120.0 => float oscSongTempo;

// Start the OSC Message Receiver
spork ~ OscRecvr();

// Wait for the OSC signal on the song information
while (oscMsgRecvr == 0){
    samp => now;
}
// Reset the osc message flag 
0 => oscMsgRecvr;

dac => WvOut2 w => blackhole;

// Set the output file name
"my_recording.wav" => w.wavFilename;

// Record for 60 seconds
20.0::minute => now;

// Close the file properly to flush data
w.closeFile();

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
            if (msg.address == "/song/master/setup") {
                msg.numArgs() => oscMsgRecvr;
                msg.getInt(0) => oscSongCycles;
                msg.getInt(1) => oscSongMeasure;
                msg.getInt(2) => oscSongDivision;
                msg.getFloat(3) => oscSongTempo;
            }

        }     
    }

}

