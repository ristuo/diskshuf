import std.path;
import std.file;
import std.conv;
import std.stdio;
import std.getopt;
import reservoir;
import filesampler;

int main(string[] args) 
{
    string usage = "Usage: " ~ args[0] ~ " SOURCEFILE SAMPLESIZE [OPTION]"; 
    if (args.length < 3) 
    {
        writeln(usage);
        return(1);
    }
    string srcPath = args[1]; 
    ulong lines;
    try
    {
        lines = to!ulong(args[2]);
    }
    catch (ConvException)
    {
        string msg = "Samplesize was \"" ~ args[2];
        msg ~= "\". It should be integer and in range (0, ";
        msg ~= text(ulong.max) ~ ")";
        writeln(msg);
        return(1);
    }
    
    string outPath; 
    bool verbose = false;
    try
    {
        auto helpInformation = getopt( args
                                     , "verbose|v", "Verbose", &verbose
                                     , "out|o", "Output filepath", &outPath );
        if (helpInformation.helpWanted)
        {
            defaultGetoptPrinter( usage
                                , helpInformation.options );
            return(1);
        }
        if (outPath == "")
        {
            outPath = stripExtension( baseName( srcPath ) ) ~ "_out.txt";
        }
        debug writeln("srcPath: " ~ srcPath);
        debug writeln("outPath: " ~ outPath);
        debug writeln("lines: " ~ text(lines));
        sampleOnDisk(srcPath, outPath, lines, verbose);
    }
    catch(GetOptException)
    {
        writeln("See " ~ args[0] ~ " --help for available options"); 
        return 1;
    }
    return 0;
}
