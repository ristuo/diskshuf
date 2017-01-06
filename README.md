#Diskshuf

Reads random subset of lines from given file and prints them to output file with. At any given time the program will maintain one line in memory (plus two integers for each line in source file), which means that even very large files can be processed smoothly. If subset size is set to greater than or equal to the size of the file, a random permutation is produced.

What shuf accomplished in 6 seconds in sampling a 800 MB file took about 2 minutes with this program, so if data fits to main memory shuf is the way to go.

In reading the source file diskshuf will scan the file once to construct an array of line indeces that are to be included in the result. After this these lines are one by one read from the source file and written to output.

Because this program is for the usecase where files and sample sizes are large, stdin and stdout are not supported.
