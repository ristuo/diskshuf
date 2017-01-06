import std.random;
import std.stdio;
import std.conv;
import std.algorithm; 

class reservoirSampler(T)
{
    private:
        T[] values;
        ulong counter;
    public:
        this(ulong sampleSize)
        {
            this.values = new T[](0);
            this.values.reserve(sampleSize);
            this.counter = 0;
        }

        bool step(T value)
        {
            if (this.values.length < this.values.capacity) 
            {
                this.values ~= value;
                this.counter++;
                return true;
            }
            ulong j = uniform(0, this.counter + 1); 
            this.counter++;
            debug writeln("counter: " ~ text(this.counter) ~ " j: " ~ text(j));
            if (j < this.values.length)
            {
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
