#Diskshuf

Reads random subset of lines from given file and prints them to output file with. At any given time the program will maintain one line in memory (plus two integers for each line in source file), which means that even very large samples can be processed smoothly. GNU Shuf on the other hand maintains the sample in memory for the duration of the program, which means that the random subset cannot practically be larger than main memory. This on the other hand will not store sampled lines in memory. 
When sampling 5 million lines from 1.3 GB file shuf finished in 20 seconds, whereas with diskshuf it took 53. Then again shuf had 800 MB in memory (which is surprising given that the resulting file was 200 MB), this had like 80 or so.

On the other hand, with large samples writing to file is really slow because all lines in sample must be fetched by fseek on the source file. Writing 7 000 000 line (3 GB) sample to a file would have taken some 31 hours.

If subset size is set to greater than or equal to the size of the file, a random permutation is produced.


In reading the source file diskshuf will scan the file once to construct an array of line indeces that are to be included in the result. After this these lines are one by one read from the source file and written to output.

Because this program is for the usecase where files and sample sizes are large, stdin and stdout are not supported.
