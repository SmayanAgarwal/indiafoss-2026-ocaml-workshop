/* Uninitialised read. C does not zero local variables. `secret`
 * leaves a recognisable pattern on the stack; `leak` is then
 * declared over the same stack slot and read before it is written,
 * so it sees the leftover bytes.
 *
 *   cc -o uninit uninit.c && ./uninit
 */
#include <stdio.h>

void stash_secret(void) {
    char secret[32];
    for (int i = 0; i < 32; i++)
        secret[i] = "DEADBEEF"[i % 8];   /* leave a pattern behind */
    /* secret goes out of scope here, but its bytes stay on the stack */
}

void read_uninitialised(void) {
    char leak[32];                        /* never written to */
    printf("uninitialised buffer: ");
    for (int i = 0; i < 16; i++)
        printf("%c", leak[i]);
    printf("\n");
}

int main(void) {
    stash_secret();
    read_uninitialised();                 /* prints stale stack bytes */
    return 0;
}
