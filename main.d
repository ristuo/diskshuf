import std.path;
import std.file;
import std.conv;
import std.stdio;
import std.getopt;
import reservoir;
import filesampler;

int main(string[] args) 
{
    string usage = "Usage: " ~ args[0]; 
    bool tooFewArgs = args.length < 2;
    string srcPath; 
    string outPath; 
    ulong lines = 1;
    try
    {
        auto helpInformation = getopt( args
                                     , "source|s", "Source filepath", &srcPath
                                     , "lines|n", "Lines to sample", &lines
                                     , "out|o", "Output filepath", &outPath );
        if (tooFewArgs || helpInformation.helpWanted)
        {
            defaultGetoptPrinter( usage
                                , helpInformation.options );
        }
        if (outPath == "" || lines < 2)
        {
            outPath = stripExtension( baseName( srcPath ) ) ~ "_out.txt";
        }
        sampleOnDisk(srcPath, outPath, lines);
    }
    catch(GetOptException)
    {
        writeln("See " ~ args[0] ~ " --help for available options"); 
        return 1;
    }
    return 0;
}
