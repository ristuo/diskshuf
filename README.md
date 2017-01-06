#Diskshuf

Reads random subset of lines from given file and prints them to output file with. At any given time the program will maintain one line in memory (plus two integers for each line in source file), which means that even very large samples can be processed smoothly. GNU Shuf on the other hand maintains the sample in memory for the duration of the program, which means that the random subset cannot practically be larger than main memory. This on the other hand will not store sampled lines in memory. 
When sampling 500 000 lines from 1.3 GB file shuf finished in 20 seconds, whereas with diskshuf it took 53. Then again shuf had 800 MB in memory (which is surprising given that the resulting file was 200 MB), this had like 80 or so. However, the running of this will increase quickly with the size of the source file and the sample, because fseek seems to take a while on bigger files.  Writing 7 000 000 line (3 GB) random permutation to a file would have taken some 31 hours.

If subset size is set to greater than or equal to the size of the file, a random permutation is produced.
