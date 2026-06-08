/* Buffer overflow. The buffer holds 16 bytes; we copy a longer
 * string into it. C performs no bounds check, so the write runs off
 * the end and corrupts whatever sits next on the stack (here, a
 * second variable, and eventually the return address).
 *
 *   cc -fno-stack-protector -o overflow overflow.c
 *   ./overflow AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
 */
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
    volatile int canary = 0x600d;  /* "good": sits just past `buf` */
    char buf[16];

    if (argc < 2) {
        printf("usage: %s <text>\n", argv[0]);
        return 1;
    }

    strcpy(buf, argv[1]);          /* no bounds check: writes argv[1] verbatim */

    printf("buf    = %s\n", buf);
    printf("canary = 0x%x (expected 0x600d)\n", canary);
    return 0;
}
