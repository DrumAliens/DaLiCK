CHmUsiCK Library;

// Osc sender object
OscOut oscOut;
// Aim the transmitter to a destination
oscOut.dest(Library.OSCOUTIP, Library.OSCOUTPORT);

// ============= DON'T CHANGE BEYOND HERE

0 => int oscMsgRecvr;

16 => int oscNumBeats;
4 => int oscBeatDivision;
120.0 => float oscSongTempo;

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
50 => float shuffle;

// Calculate the timing information
TimerInfo timerInfo;
Library.calcTimer(numBeats, beatDivision, songTempo, shuffle) @=> timerInfo;

timerInfo.numPhraseDivisions*timerInfo.divVal => float val;
cherr <= "Length of phrase is "<= val <=  " seconds " <= IO.newline(); 
val::second => dur phraseDur;

// Setup the phrase counter     
0 => int countLocl;
0 => int countMaster;

// Loop round the sample
while(true)
{

    // Master 
    if (oscMsgRecvr > 0){
        oscNumBeats => numBeats;
        oscBeatDivision => beatDivision;
        oscSongTempo => songTempo;

        // Calculate the timing information
        Library.calcTimer(numBeats, beatDivision, songTempo, shuffle) @=> timerInfo;

        timerInfo.numPhraseDivisions*timerInfo.divVal => float val;
        cherr <= "Length of phrase is "<= val <=  " seconds " <= IO.newline(); 
        val::second => dur phraseDur;

        // Reset the phrase counter if there is a change
        0 => countLocl;

		// Reset the osc message flag 
		0 => oscMsgRecvr;
    }

    // Display the current phrase
    <<< "Phrase", countLocl >>>;

    // Setup OSC message 
    //  Don't reset the counter that is sent out for the player piano mode
    oscOut.start( "/song/master/phrase" );
    countMaster => oscOut.add;
    oscOut.send();    

    // Wait for a new phrase 
    phraseDur => now;

    // // Loop round 
    // for (0 => int i; i < timerInfo.numPhraseDivisions; i++) {
    //     timerInfo.divDur => now;
    // }
 
    countLocl++;
    countMaster++;
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
                msg.getInt(0) => oscNumBeats;
                msg.getInt(1) => oscBeatDivision;
                msg.getFloat(2) => oscSongTempo;
            }

        }     
    }

}

