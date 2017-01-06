import reservoir;
import std.stdio;
import progresscounter;
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
    string intro = "Drawing sample.";
    auto progCounter = new progressCounter!ulong( srcFileSize
                                                , intro);
    auto rSampler = new ReservoirSampler!SrcLine(sampleSize);
    ulong i = 0;
    long lineStart = 0;
    string line;
    SrcLine lineStruct;
    bool firstReport = true;
    while (!srcFile.eof())
    {
        line = srcFile.readln();
        lineStruct = SrcLine( lineStart, i ); 
        rSampler.step( lineStruct );
        i++;
        lineStart += cast(long)validLength(line);
        if (verbose && (i % 500000 == 0))
        {
            if (firstReport)
            {
                writeln("");
                firstReport = false; 
            }
            progCounter.printProgressReport(lineStart);
        }
    }
    srcFile.close();
    progCounter.printEnd("Finished sampling.");
    return rSampler.getShuffledValues();
}

void writeIndeces( const SrcLine[] indeces
                 , string srcPath
                 , string outPath
                 , bool verbose )
{
    File srcFile = File(srcPath, "r"); 
    File outFile = File(outPath, "w");
    string line;
    ulong i = 0;

    string intro = "Writing to file: " ~ outPath ~ ".";
    auto progCounter = new progressCounter!ulong(indeces.length, intro);
    bool firstReport = true;

    foreach (srcLine; indeces)
    {
        srcFile.seek( srcLine.headPos );
        line = srcFile.readln();
        outFile.write(line);
        srcFile.rewind();
        if (verbose && (i % 500 == 0))
        {
            if (firstReport)
            {
                writeln(""); 
                firstReport = false;
            }
            progCounter.printProgressReport(i);
        }
        i++;
    }
    string msg = "Finished writing " ~ text(indeces.length) ~ " records.";
    progCounter.printEnd(msg);
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
    writeIndeces(indeces, srcPath, outPath, verbose);
}
