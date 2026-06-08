/* Undefined behaviour does not just crash: it lets the optimiser
 * delete your code. Signed integer overflow is UB, so the compiler
 * assumes `x + 100` never wraps below `x`, and folds the guard below
 * to "always false" -- deleting it.
 *
 *   cc -O2 -o check_ub   deleted_check.c && ./check_ub      # guard deleted
 *   cc -O2 -fwrapv -o check_safe deleted_check.c && ./check_safe  # guard fires
 *
 * -fwrapv tells gcc to DEFINE signed overflow as two's-complement
 * wraparound. With the UB assumption gone, the guard can be true, so
 * the compiler keeps it and it fires. Same source, same input: the
 * difference is whether overflow is undefined.
 */
#include <stdio.h>
#include <limits.h>

/* Returns 1 if adding 100 to x would "overflow" (wrap negative). */
int will_overflow(int x) {
    return (x + 100) < x;          /* UB when x is near INT_MAX */
}

int main(void) {
    int x = INT_MAX - 50;
    if (will_overflow(x))
        printf("guard fired: %d + 100 would overflow\n", x);
    else
        printf("no overflow reported for %d + 100\n", x);
    return 0;
}
