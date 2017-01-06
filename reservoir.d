import std.random;
import std.math;
import std.stdio;
import std.conv;
import std.algorithm; 

class ReservoirSampler(T)
{
    private:
        T[] values;
        ulong counter;
        ulong sampleSize;
    public:
        this(ulong sampleSize)
        {
            this.values = new T[](0);
            this.values.reserve(sampleSize);
            this.sampleSize = sampleSize;
            this.counter = 0;
            debug(2)
            {
                string log = "constructing sampler with samplesize ";
                log ~= text(sampleSize);
                log ~= " and values capacity: " ~ text(this.values.capacity);
                writeln(log);
            }
        }

        bool step(T value)
        {
            if (this.values.length < this.sampleSize) 
            {
                debug(2)
                {
                    string log = "original insert, this.values.length: ";
                    log ~= text(this.values.length);
                    writeln(log);
                }
                this.values ~= value;
                this.counter++;
                return true;
            }
            ulong j = uniform(0, this.counter + 1); 
            this.counter++;
            debug(3) 
            {
                writeln("counter: " ~ text(this.counter) ~ " j: " ~ text(j));
            }
            if (j < this.values.length)
            {
                debug(2) 
                {
                    writeln("inserting to position: " ~ text(j));
                    writeln("this.values.length: " ~ text(this.values.length));
                }
                
                this.values[j] = value;
                return true;
            }
            return false;
        }

        const(T[]) getValues() 
        {
            return this.values;
        }

        override pure string toString()
        {
            return text(this.values);            
        }
}

unittest
{
    int reps = 500000;
    int innerLength = 4;
    int numbersToTest = 12;
    int[] res = new int[](numbersToTest);
    for (int i = 0; i < reps; i++) 
    {
        auto rs = new ReservoirSampler!int(innerLength);
        for (int j = 0; j < numbersToTest; j++)
        {
            rs.step(j);
        }
        foreach (int k; rs.getValues())
        {
            res[k]++; 
        }
    }
    float[] relativeFreqs = new float[](numbersToTest);
    for (int i = 0; i < numbersToTest; i++)
    {
        relativeFreqs[i] = (cast(float)res[i])/(cast(float) reps * innerLength);
    }
    foreach (freq; relativeFreqs)
    {
        float error = abs(freq - 1.0/cast(float)numbersToTest);
        assert(error < 0.01);
    }
}
