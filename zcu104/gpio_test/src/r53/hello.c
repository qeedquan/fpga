#include <stdio.h>
#include "xil_printf.h"
#include "sleep.h"

int
main(void)
{
	unsigned i;

	for (i = 0;; i++) {
		xil_printf("Hello World: %u\n\r", i);
		sleep(1);
	}
	return 0;
}
