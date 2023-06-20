#include "stdio.h"
#include "stdlib.h"
#include "string.h"

extern int replace(char* str);

int main(int argc, char** argv)
{
	printf("Source> ");	
	char str[64];
	memset(str, '\0', 64);
	scanf("%63s", str);
	int retval = replace(str);
	printf("Result> %s\n", str);
	printf("Return value: %i\n", retval);
	return retval;
}
