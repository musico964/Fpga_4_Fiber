/* SaveTime.c
 *
 */

#include <stdio.h>
#include <time.h>

main()
{
	FILE *f;
	time_t now;

	time(&now);
	if( (f=fopen("CompileTime.v", "w")) == NULL )
	{
		printf("Can't open output file\n");
	}
	else
	{
		fprintf(f, "`define COMPILE_TIME 32'h%08X\n", now);
		fclose(f);
	}
}
