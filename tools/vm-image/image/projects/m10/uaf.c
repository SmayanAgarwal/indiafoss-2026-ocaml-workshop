/* Use-after-free. We free a heap block, then keep using the old
 * pointer. C does not stop us: the read "works" and returns the old
 * bytes, because nothing zeroed them. Nothing crashes. That silence
 * is the danger: the bug is invisible until the allocator hands the
 * block to someone else, and what happens then depends on the C
 * library, the load, and (in an attack) the attacker.
 *
 *   cc -o uaf uaf.c && ./uaf
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct session {
    int  user_id;
    char role[16];
};

int main(void) {
    struct session *s = malloc(sizeof *s);
    s->user_id = 1001;
    strcpy(s->role, "guest");
    printf("before free: id=%d role=%s\n", s->user_id, s->role);

    free(s);                       /* the block is returned to the heap */

    /* s is now a DANGLING pointer. Reading through it is undefined
     * behaviour, but nothing crashes: the old bytes are still there. */
    printf("after free:  id=%d role=%s\n", s->user_id, s->role);
    return 0;
}
