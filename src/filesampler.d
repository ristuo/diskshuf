import reservoir;
import std.stdio;
import std.conv;
import std.file;
import core.stdc.stdlib;
import std.encoding;
import std.datetime;

struct SrcLine { long headPos;
                 ulong index; }
               

string getTimestamp()
{
    auto time = Clock.currTime();
    return text(cast(DateTime)time);
}

const(SrcLine[]) sampleLineIndeces( string srcPath
                                  , ulong sampleSize
                                  , bool verbose)
{
    File srcFile = File(srcPath, "r");
    ulong srcFileSize = srcFile.size();
    auto rSampler = new ReservoirSampler!SrcLine(sampleSize);
    ulong i = 0;
    long lineStart = 0;
    string line;
    SrcLine lineStruct;
    SysTime startTime = Clock.currTime();
    if (verbose)
    {
        writeln("");
    }
    while (!srcFile.eof())
    {
        line = srcFile.readln();
        lineStruct = SrcLine( lineStart, i ); 
        rSampler.step( lineStruct );
        i++;
        lineStart += cast(long)validLength(line);
        if (verbose && (i % 500000 == 0))
        {
            SysTime now = Clock.currTime();
            Duration took = now - startTime;
            double fracDone= cast(double)lineStart/cast(double)srcFileSize;
            int progressBarParts = 15;
            long tookSec = took.total!"seconds";
            long totalEstimateSecs = cast(long)(tookSec*(1/fracDone));
            long leftSecs = totalEstimateSecs - tookSec;
            Duration left = dur!"seconds"(leftSecs);
            int pctDone = cast(int)(fracDone*100);
            string log = "Constructing sample: ";
            log ~= "[";
            int j = 0;
            while (j <= cast(int)(progressBarParts*fracDone))
            {
                log ~= "=";
                j++;
            }
            while (j < progressBarParts)
            {
                log ~= " ";
                j++;
            }
            log ~= "] ";
            log ~= text(lineStart/1000_000) ~ "MB processed. ";
            log ~= text(pctDone) ~ "% done, " ~ text(left);
            log ~= " left.";
            write("\033[1A");
            write("\033[K\r");
            writeln("\r" ~ log);
        }
    }
    srcFile.close();
    return rSampler.getValues();
}

void writeIndeces( const SrcLine[] indeces, string srcPath, string outPath)
{
    File srcFile = File(srcPath, "r"); 
    File outFile = File(outPath, "w");
    string line;
    foreach (srcLine; indeces)
    {
        srcFile.seek( srcLine.headPos );
        line = srcFile.readln();
        outFile.write(line);
        srcFile.rewind();
    }
    srcFile.close();
    outFile.close();
}

void sampleOnDisk( string srcPath
                 , string outPath
                 , ulong sampleSize
                 , bool verbose) 
{
    if (!exists(srcPath))
    {
        writeln("File " ~ srcPath ~ " does not exist!");
        exit(1);
    }
    const SrcLine[] indeces = sampleLineIndeces(srcPath, sampleSize, verbose);
    debug writeln("Writing " ~ text(indeces.length) ~ " lines:");
    debug writeln(indeces);
    if (verbose)
    {
        string log = getTimestamp() ~ ": ";
        log ~= "Finished constructing sample, now starting to write to"; 
        log ~= " file: ";
        log ~= outPath;
        writeln(log); 
    }
    writeIndeces(indeces, srcPath, outPath);
}
