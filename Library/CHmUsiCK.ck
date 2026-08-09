// Define a container class
public class TimerInfo {
    int numPhraseDivisions;
    float barVal;
    float divVal;
    float shuffleOffset;
    dur divDur;
    dur divDurOdd;
    dur divDurEven;
}

public class CHmUsiCK extends Chugraph {

    //Notes tool;
    
    // Define the midi root note for a rate of 1.0
    // 72 -> C4
    72 => int MIDIROOTNOTE;

    // Maximum size of the arrays that store the note positions
    64 => int MAXNUMNOTES;

    // OSC port to listen on for instructions
    49162 => int OSCINPORT;

    // OSC ip and port information
    "127.0.0.1" => string OSCOUTIP; 
    49163 => int OSCOUTPORT;

    // midi offset for the chop wav files
    0.0 => float chopMidiOffset;

    // Calculate all of the different timings required
    public TimerInfo calcTimer(int numBeats, int beatDivision, float songTempo, float shuffle) {
        new TimerInfo @=> TimerInfo res;

        // Calculate the length of the phrase
        numBeats * beatDivision => res.numPhraseDivisions;

        // Calculate the bpm based upon 4 beats in a bar
        (60.0 * 4) / songTempo => res.barVal;
        // Calculate the length of the beat division
        res.barVal / (4 * beatDivision) => res.divVal;
        res.divVal::second => res.divDur;     

        // Calculate the differences for shuffle timing
        calcShuffleOffset(res.divVal, shuffle) => res.shuffleOffset;
        (res.divVal + res.shuffleOffset)::second => res.divDurEven;
        (res.divVal - res.shuffleOffset)::second => res.divDurOdd;

        return res;
    }

    // Calculate the offset time
    public float calcShuffleOffset(float divVal, float shuffle) {
        return divVal * (shuffle - 50.0) / 50.0;
    }

    // Delay Wait the div time
    public void waitDivTime(TimerInfo timerInfo, float evenVal){
        // Switch between shuffle timings
        if (evenVal > 0) {
          timerInfo.divDurEven => now;
        } else {
          timerInfo.divDurOdd => now;
        }
    }

    public int[] rand(int capacity)
    // randomly fills an array with ones
    {
        int random[capacity];

        for(0 => int i; i < random.cap(); i ++)
        {
            Math.random2(0,1) => random[i];
        }
        return random;
    }
    public int toNote(int note)
    {
        if(maybe)
            return note;
        return 0;
    }
    public int[] trigToNote(int pattern[] ,int note)
    {
        int toReturn[pattern.cap()];

        for(0 => int i; i < toReturn.cap(); i ++)
        {
            if(pattern[i] == 1){
              note => toReturn[i];
            }
        }
        return toReturn;
    }
    public int[] subArray(int pattern[], int toCut[])
    // cuts an array pattern
    // Thanx to Santiago Beta
    {
        toCut.size() => int newsize;
        int sub[newsize];

        for(0 => int i; i < newsize; i++)
        {
            if(toCut[i] < pattern.size() && toCut[i] >= 0) {
                pattern[toCut[i]] => sub[i];
            }
            else {
                0 => sub[i];
            }
        }
        return sub;
    }
    public int[] trunc(int pattern[], float howmany)
    // truncates an array pattern by howmany
    {
        (pattern.size() * howmany)$int => int newsize;
        int truncated[newsize];

        for(0 => int i; i < newsize; i++)
        {
            pattern[i] => truncated[i];
        }
        return truncated;
    }
    public int[] trunc(int pattern[], int from, int to)
    // cuts an array from - to // idea: Santiago Beta
    {
        if(from >= 0 && to <= pattern.cap() && from < to)
        {
            int truncated[0];

            for(from => int i; i < to; i++)
            {
                truncated << pattern[i];
            }
            return truncated;
        }
        else
        {
            <<< "something is wrong, check trunc() parameters" >>>;
            return pattern;
        }
    }
    public int[] reverse(int pattern[])
    // reverse an array
    {
        int reversed[0];

        for((pattern.cap()-1) => int i; i >= 0 ; i - 1 => i)
        {
            reversed << pattern[i];
        }
        return reversed;
    }
    public int[] densify(int pattern[])
    // ramdomly add ones to an int array
    {
        int notes[0];

        for(0 => int i; i < pattern.cap(); i++)
        {
            if(pattern[i] != 0)
            {
                notes << pattern[i];
            }
        }
        for(0 => int i; i < pattern.cap(); i++)
        {
            if(pattern[i] == 0 && maybe)
            {
                notes[Math.random2(0, (notes.cap() - 1))] => pattern[i];
            }
        }
        return pattern;
    }

    public int[] reverse(SndBuf buffer){
      buffer => outlet;
      buffer.samples() => int total;
      while(true){
        total => buffer.pos;
        total--;
        samp => now;
      }
      return int toReturn[0];;
    }

    public int[] density(int pattern[],int times)
    {
        int toReturn[0];

        for(0 => int i; i < times; i++)
        {
            for(0 => int j; j < pattern.size(); j++)
            {
                toReturn << pattern[j];
            }
        }
        return toReturn;
    }

    public int[] degrade(int pattern[])
    // randomly removes non zero events of an int array
    {
        for(0 => int i; i < pattern.cap(); i++)
        {
            if(pattern[i] != 0 && maybe)
            {
                0 => pattern[i];
            }
        }
        return pattern;
    }

    public int[] every(int parameter)
    // fills an array of parameter size with ones
    {
        int everyArray[parameter];

        if(parameter == 0)
        {
            everyArray << 0;
            return everyArray;
        }
        else
        {
            1 => everyArray[0];

            for(1 => int i; i < everyArray.cap(); i++)
            {
                0 => everyArray[i];
            }
        }
        return everyArray;
    }

    // ==========================================================================
    // pking6 modification
    // ==========================================================================

    public int[] dec2Pos(float val)
    // Takes a decimal value and returns and array of positions
    //  - assumes the position array length is 16 
    {
        int everyArray[16]; 
        if (val > 0){
           for (0 => int i; i < 16; i++) {
                ((val % 2) >= 1) => everyArray[i];
                val / 2 => val;
           }
        }   
        return everyArray;
    }

    public int[] freqArray(int freq, int posArray[])
    // Takes a decimal value and returns and array of positions
    //  - assumes the position array length is 16 
    {
        posArray.size() => int patLength;
        int freqArray[patLength]; 
        for (0 => int i; i < patLength; i++) {
            freq*posArray[i] => freqArray[i];
        }
        return freqArray;
    }

    public int[] fill(int list[], int patLength)
    // Takes the list of positions of pattern and fills the positions with 1's to generate a pattern
    //  - the order in pattern is not important
    //  - patLength is the length of the resulting pattern
    {
        if (patLength == 0) {
           <<< "Pattern length should be greater than 0" >>>;
           16 => patLength;
        }    

        int everyArray[patLength];
        
        for( int i : list)
        {
            1 => everyArray[i];
        }
        
        return everyArray;
    }

    public int[] mask(int midiNote, int list[], int patLength)
    // Takes a list of positions of pattern and fills the midiNote when the position is not 
    // a value in the position list
    //  - patLength is the length of the resulting pattern
    {
        int everyArray[patLength];

        // If the first element greater than 0 then apply the mask
        // otherwise leave fully populated
        if (list[0] >= 0) {
            fill(list, patLength) @=> int pattern[];
            for (0 => int i; i < patLength; i++)
            {
               // Assume only have to deal with 0's in the position 
               // as by default everyArray starts as an array of zeros
               if (pattern[i] == 0)
               {
                  midiNote => everyArray[i];
               }
           }
        }
        else
        {
            ones(patLength,midiNote) @=> everyArray;
        }
       
        return everyArray;
    }

    public int[] join(int pattern1[], int pattern2[])
    // Takes two arrays of patterns and joins them together in order
    // Note: the pattern doesn't have to be of equal length
    {
        int everyArray[pattern1.cap()+pattern2.cap()];
        
        for(0 => int i; i < pattern1.cap(); i++)
        {
            pattern1[i] => everyArray[i];
        }
        for(0 => int i; i < pattern2.cap(); i++)
        {
            pattern2[i] => everyArray[i+pattern1.cap()];
        }
        return everyArray;
    }
    
   public int[] join(int pattern1[], int pattern2[], int pattern3[])
    // Takes three arrays of patterns and joins them together in order
    // Note: the pattern doesn't have to be of equal length
    {
        int everyArray[pattern1.cap()+pattern2.cap()+pattern3.cap()];
        
        for(0 => int i; i < pattern1.cap(); i++)
        {
            pattern1[i] => everyArray[i];
        }
        pattern1.cap() => int offset;
        for(0 => int i; i < pattern2.cap(); i++)
        {
            pattern2[i] => everyArray[i+offset];
        }
        pattern2.cap() +=> offset;
        for(0 => int i; i < pattern3.cap(); i++)
        {
            pattern3[i] => everyArray[i+offset];
        }
        return everyArray;
    }

   public int[] join(int pattern1[], int pattern2[], int pattern3[], int pattern4[])
    // Takes four arrays of patterns and joins them together in order
    // Note: the pattern doesn't have to be of equal length
    {
        int everyArray[pattern1.cap()+pattern2.cap()+pattern3.cap()+pattern4.cap()];
        
        for(0 => int i; i < pattern1.cap(); i++)
        {
            pattern1[i] => everyArray[i];
        }
        pattern1.cap() => int offset;
        for(0 => int i; i < pattern2.cap(); i++)
        {
            pattern2[i] => everyArray[i+offset];
        }
        pattern2.cap() +=> offset;
        for(0 => int i; i < pattern3.cap(); i++)
        {
            pattern3[i] => everyArray[i+offset];
        }
        pattern3.cap() +=> offset;
        for(0 => int i; i < pattern4.cap(); i++)
        {
            pattern4[i] => everyArray[i+offset];
        }
        return everyArray;
    }

    public int[] join(int list1[], int list2[], int patLength)
    // Takes two lists of positions and joins them together to generate a pattern
    //  - patLength is the length of the resulting pattern for an individual lists
    // Note: Assumes both lists generate patterns of the same length 
    {
        // Convert the position lists into patterns 
        fill(list1, patLength) @=> int pattern1[];
        fill(list2, patLength) @=> int pattern2[];

        // Join the two patterns together
        join(pattern1,pattern2) @=> int everyArray[];
        
        return everyArray;
    }
  
    public int[] join(int list1[], int list2[], int patLength1, int patLength2)
    // Takes two lists of positions and joins them together to generate a pattern
    // Note: Lists can generate patterns of different lengths
    // Resulting pattern length is patLength1 + patLength2 
    {
        // Convert the position lists into patterns 
        fill(list1, patLength1) @=> int pattern1[];
        fill(list2, patLength2) @=> int pattern2[];

        // Join the two patterns together
        join(pattern1,pattern2) @=> int everyArray[];
        
        return everyArray;
    }
    
    public int[] copy(int pattern[], int num)
    // Takes a pattern and then copies it num times
    {
        pattern.cap() => int patLength;
        
        int everyArray[patLength*num];

        for(0 => int i; i < num; i++)
        {
           for(0 => int j; j < patLength; j++)
           {
               pattern[j] => everyArray[j+i*patLength];
           }
        }
        return everyArray;
    } 
    
    public int[] zeros(int patLength)
    // Creates an empty pattern array of length patLength
    // Note: if patLength is zero then set it to the default bar length
    {
        if (patLength == 0) {
           <<< "Pattern length should be greater than 0" >>>;
           16 => patLength;
        }    
        int everyArray[patLength];
        return everyArray;
    }
    
    public int[] ones(int patLength)
    // Creates a pattern array full of ones of length patLength
    // Note: if patLength is zero then set it to the default bar length
    {
        if (patLength == 0) {
           <<< "Pattern length should be greater than 0" >>>;
           16 => patLength;
        }    
        
        int everyArray[patLength];
           
        for(0 => int i; i < patLength; i++)
        {
           1 => everyArray[i];
        }
        return everyArray;
           
    }


    public int[] ones(int patLength, int midiNote)
    // Creates a pattern array full of MIDI note frequency of length patLength
    // Note: if patLength is zero then set it to the default bar length
    {
        if (patLength == 0) {
           <<< "Pattern length should be greater than 0" >>>;
           16 => patLength;
        }    
        
        int everyArray[patLength];
           
        for(0 => int i; i < patLength; i++)
        {
           midiNote => everyArray[i];
        }
        return everyArray;
    }

    // public int[] durCheck(int patLength, int midiNote)
    // {

    // }


    // Converts a rate to an "equivalent" midiNote
    public float rateToMidiNote(float rate)
    {
        // Seems like log2 doesn't work in chuck
        return 12.0 * (Math.log(rate) / Math.log(2.0)) + MIDIROOTNOTE;
    }

    // Play a sample or a slice of a sample MONO WAV
    //    Note midiNote is a float so can set specific desired rate (see rateToMidiNote function)
    public void playSample(SndBuf buffer, float midiNote, int slicePos, float sliceSec, float beatTime) {

        // Set up the envelope within the function
        buffer => Envelope envelope => outlet;

        0.050 => float rampTimeSec;
        rampTimeSec::second => envelope.duration;

        // Sort out slice start postion
        slicePos => buffer.pos;

        // Sort frequency of slice - assume midi 72 (C4) is 1.0
        Math.pow(2.0, (midiNote - MIDIROOTNOTE) / 12.0) => float rate;
        rate => buffer.rate;
        
        // Calculate how long to play that slice for 
        // - adjust for pitch changes 
        // - make sure it only plays that sample slice
        // - subtract the ramp up and ramp down time
        Math.min(sliceSec / rate, beatTime) - rampTimeSec => float val;
        // Math.min(sliceSec / rate, beatTime) => float val;

        // Ramp up
        1.0 => envelope.value;
        
        // Play the slice
        val::second => now;

        // Ramp down
        envelope.keyOff();
        rampTimeSec::second => now;
        
        // Have to put the play head at the end of the sample
        // otherwise the sample will play after you exit the function
        buffer.samples() => buffer.pos;
    }

    // // Sinewave 
    // public float lfoSine(float minValue, float maxValue, float value)
    // {
    //    return 0.5*((maxValue-minValue)*Math.sin(value*STATIC.BEATS) + maxValue + minValue);
    // }

  // ==========================================================================

    public int[] granularize(int array[], int howmany)
    {
        int granularized[0];

        for(0 => int count; count < array.cap(); count++)
        {
            for(0 => int i; i < howmany; i++)
            {
                granularized << array[count];
            }
        }
        return granularized;
    }

}

