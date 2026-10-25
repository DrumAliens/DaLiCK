
SndBuf buffer => Envelope envelope => WvOut recorder => dac;

"424940__blukotek__heavy-machine-steam-pressure-gauge_44100Hz" => string fileName;

me.dir() + "424940__blukotek__heavy-machine-steam-pressure-gauge_44100Hz.wav" => buffer.read;

buffer.samples() => int sampleEnd;
sampleEnd => buffer.pos;

// Get the sample rate
buffer.sampleRate() => float sampleHz;

// Setup the envelope
0.01 => float rampTimeSec;
rampTimeSec::second => envelope.duration;
1.0 => envelope.value;

// Sliced positions worked out in excel spreadsheet
8 => int numSampleSlices;
int sliceNotePos[numSampleSlices + 1];
float sliceNoteSec[numSampleSlices];

// 622240 => sliceNotePos[0];
659683 => sliceNotePos[0];
696547 => sliceNotePos[1];
733918 => sliceNotePos[2];
771465 => sliceNotePos[3];
808247 => sliceNotePos[4];
845984 => sliceNotePos[5];
883569 => sliceNotePos[6];
920851 => sliceNotePos[7];
956913 => sliceNotePos[8];

// Work out the time of each section of the sample
for (0 => int i; i < numSampleSlices; i++) {
    (sliceNotePos[i+1] - sliceNotePos[i]) / sampleHz => sliceNoteSec[i];
}

// Original 
74 => int bpm;

// Beat length
60.0 / bpm => float beatTime;

// Label the loop file name
me.dir() + fileName + "_Loop_" + Std.itoa(bpm) + "bpm.wav" => recorder.wavFilename;

// Loop through each note
for (0 => int i; i < numSampleSlices; i++) {
    
    sliceNotePos[i] => buffer.pos;
    
    beatTime - 2.0 * rampTimeSec=> float val;

    // Ramp on
    envelope.keyOn();
    rampTimeSec::second => now;

    // Play the slice
    val::second => now;

    // Ramp off
    envelope.keyOff();
    rampTimeSec::second => now;

  
}

// 2. Finalize and close the file
recorder.closeFile();

