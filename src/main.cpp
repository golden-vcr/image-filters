#include "image-filters.h"

#include <stdio.h>
#include <string.h>

static int run_remove_background(int num_opts, char* opts[])
{
	// Parse options for remove-background command
	static const char* infile = nullptr;
	static const char* outfile = nullptr;
	int i = 0;
	while (i < num_opts)
	{
		if (strcmp(opts[i], "-i") == 0)
		{
			if (i + 1 < num_opts)
			{
				infile = opts[i+1];
				i += 2;
			}
			else
			{
				fprintf(stderr, "No value specified for -i\n");
				break;
			}
		}
		else if (strcmp(opts[i], "-o") == 0)
		{
			if (i + 1 < num_opts)
			{
				outfile = opts[i+1];
				i += 2;
			}
			else
			{
				fprintf(stderr, "No value specified for -o\n");
				break;
			}
		}
		else
		{
			fprintf(stderr, "Unrecognized option: %s\n", opts[i]);
			break;
		}
	}

	// If we didn't parse all required options, print subcommand usage and exit
	if (infile == nullptr || outfile == nullptr)
	{
		fprintf(stderr, "Usage: imf remove-background -i <infile> -o <outfile>\n");
		return 1;
	}

	// Call our library function to remove the input image's background, writing the
	// updated image at the desired output path, and capture the background color hex
	// string and print it to stdout
	char bgcolor[8];
	imf_remove_background(infile, outfile, bgcolor);
	printf("%s\n", bgcolor);
	return 0;
}

int main(int argc, char* argv[])
{
	// Parse the first positional argument as a command name
	static const char* command = nullptr;
	if (argc > 1)
	{
		command = argv[1];
	}

	// Branch to the appropriate command implementation
	if (command != nullptr && strcmp(command, "remove-background") == 0)
	{
		return run_remove_background(argc - 2, argv + 2);
	}

	// If we matched no valid commands, print usage and exit with an error
	fprintf(stderr, "Usage: imf (remove-background) ...\n");
	return 1;
}
