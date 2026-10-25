// 1. Set up the input buffer
SndBuf input; // Use SndBuf for mono, SndBuf2 for stereo

"DingDongPitching_12thUp" => string fileName;
"_Ding" => string prefix1;
"_Dong" => string prefix2;
me.dir() + "/" + fileName + ".wav" => input.read; // Load your source file

input.sampleRate() => float sampleHz;

int sliceNotePos[3];
// ding
0 => sliceNotePos[0];
// dong
49474 => sliceNotePos[1];
// ding
98545 => sliceNotePos[2];

// 2. Route the buffer to a file writer instead of speakers (dac)
// Blackhole absorbs the samples so they process instantly without playing out loud
input => WvOut waveWriter => blackhole; 

// 4. Record Part 1
me.dir() + "/" + fileName + prefix1 + ".wav" => waveWriter.wavFilename;

// Start playback for first slice
sliceNotePos[0] => input.pos;             
// Advance time to fill the first file
(sliceNotePos[1] - sliceNotePos[0]) /sampleHz => float sampleSec;
sampleSec::second => now;        

// 5. Close Part 1 and clear the stream
waveWriter.closeFile();

// 6. Record Part 2
me.dir() + "/" + fileName + prefix2 + ".wav" => waveWriter.wavFilename;
// Start playback for second slice
sliceNotePos[1] => input.pos;
// Advance time to fill the second file
(sliceNotePos[2] - sliceNotePos[1]) /sampleHz => sampleSec;
sampleSec::second => now;    

// 7. Clean up and close the final file
waveWriter.closeFile();
<<< "WAV file successfully split in half!" >>>;
