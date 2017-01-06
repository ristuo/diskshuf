import reservoir;
import std.stdio;
import std.conv;
import std.file;
import core.stdc.stdlib;
import std.encoding;

struct SrcLine { long headPos;
                 ulong index; }
               
const(SrcLine[]) sampleLineIndeces(string srcPath, ulong sampleSize)
{
    File srcFile = File(srcPath, "r");
    auto rSampler = new ReservoirSampler!SrcLine(sampleSize);
    ulong i = 0;
    long lineStart = 0;
    string line;
    SrcLine lineStruct;
    while (!srcFile.eof())
    {
        line = srcFile.readln();
        lineStruct = SrcLine( lineStart, i ); 
        rSampler.step( lineStruct );
        i++;
        lineStart += cast(long)validLength(line);
    }
    srcFile.close();
    return rSampler.getValues();
}

void writeIndeces(const SrcLine[] indeces, string srcPath, string outPath)
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

void sampleOnDisk(string srcPath, string outPath, ulong sampleSize) 
{
    if (!exists(srcPath))
    {
        writeln("File " ~ srcPath ~ " does not exist!");
        exit(1);
    }
    const SrcLine[] indeces = sampleLineIndeces(srcPath, sampleSize);
    debug writeln("Writing " ~ text(indeces.length) ~ " lines:");
    debug writeln(indeces);
    writeIndeces(indeces, srcPath, outPath);
}
