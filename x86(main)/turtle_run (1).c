#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#define max_bmp_size 90000
#define max_bin_size 8192

extern int turtle(unsigned char *dest_bitmap, unsigned char *commands, unsigned int commands_size);

char binary[max_bin_size];
char bitmap[max_bmp_size];
char header[54] = 
{ 
	66, 77, 200, 95, 1, 0, 0, 0, 0, 0, 54, 0, 0, 0, 40, 0, 0, 0, 88, 2, 0, 0, 50, 0, 0, 0, 1, 0, 24, 0, 0, 0, 0, 0, 146, 95, 1, 0, 18, 11, 0, 0, 18, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
};

int main(int argc, char** argv) {
	FILE* hBinFile = fopen("program.bin", "rb");
	if (hBinFile == NULL) {
		printf("Error: Couldn't read the program binary\n");
		return -1;
	}
	size_t binary_size = fread(binary, 1, max_bin_size, hBinFile);
	fclose(hBinFile);
	printf("Loaded program: %i bytes\n", binary_size);
	memset(bitmap, 0xFF, max_bmp_size);
	int res = turtle(bitmap, binary, binary_size);	
	printf("Turtle function returned: %i\n", res);
	if (res == 0) {
		FILE* hBmpFile = fopen("result.bmp", "wb");
		if (hBmpFile == NULL) {
			printf("Error: Couldn't write the output bitmap\n");
			return -1;
		}
		fwrite(header, 1, 54, hBmpFile);
		fwrite(bitmap, 1, max_bmp_size, hBmpFile);
		fclose(hBmpFile);
	} else {
		printf("Error: Invalid program binary\n");
	}
	return 0;
}