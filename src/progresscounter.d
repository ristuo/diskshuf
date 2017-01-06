import std.datetime;
import std.conv;
import std.stdio;

class progressCounter(T)
{
    private:
        const SysTime startTime;
        SysTime timeNow;
        const T goal;        
        T progress;
        string intro;
        string units;

    public:
        this(T goal, string intro = "") 
        {
            this.startTime = Clock.currTime();
            this.goal = goal;
            this.intro = intro;
        }
        void update(T progress)
        {
            this.progress = progress; 
            this.timeNow = Clock.currTime();
            this.intro = intro;
        }
        float fracDone()
        {
            return cast(float)(this.progress)/(cast(float)this.goal);
        }
        int pctDone()
        {
            return cast(int)(fracDone()*100);
        }
        Duration timeLeft()
        {
            auto took = this.timeNow - this.startTime;
            auto tookSec = took.total!"seconds";
            auto estimate = cast(long)(tookSec * 1/fracDone()) - tookSec;
            return dur!"seconds"(estimate);
        }

        string progressReport(T progress)
        {
            update(progress);
            float done = fracDone();
            int pct = pctDone();
            string bar = progressBar(done, 15);
            string res = this.intro;
            res ~= " " ~ bar ~ " " ~ text(pct) ~ "% done.";
            res ~= " Estimated time left: " ~ text(timeLeft()) ~ ".";
            return res;
        }
    
        void printProgressReport(T progress)
        {
            string res = progressReport(progress);
            write("\033[1A");
            write("\033[K\r");
            writeln("\r" ~ res);
        }

        string progressBar(float fractionDone, int barParts)
        {
            string res = "[";
            float barFraction = 1.0/cast(float)barParts;
            for (int i = 0; i < barParts; i++)
            {
                if (i * barFraction <= fractionDone)
                {
                    res ~= "=";
                }
                else
                {
                    res ~= " ";
                }
            }
            res ~= "]";
            return res;
        }

        void printEnd(string endnote)
        {
            auto took = Clock.currTime() - this.startTime;
            writeln(endnote ~ " Took " ~ text(took));
        }
}
