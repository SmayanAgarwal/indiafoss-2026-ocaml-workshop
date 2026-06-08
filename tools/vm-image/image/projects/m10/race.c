/* Data race. Two threads each add 1 to the same counter a million
 * times, with no lock. `counter++` is read-modify-write: the two
 * threads interleave and lose updates, so the total comes out short
 * and varies from run to run. In C this is undefined behaviour.
 *
 *   cc -O0 -o race race.c -lpthread && ./race
 *
 * Built at -O0 deliberately: at -O2 the optimiser turns the loop into
 * one `counter += ITERS`, which hides the race.
 */
#include <stdio.h>
#include <pthread.h>

#define ITERS 1000000

static long counter = 0;           /* shared, unsynchronised */

void *bump(void *arg) {
    (void) arg;
    for (int i = 0; i < ITERS; i++)
        counter++;                 /* RACE: read, add, write */
    return NULL;
}

int main(void) {
    pthread_t a, b;
    pthread_create(&a, NULL, bump, NULL);
    pthread_create(&b, NULL, bump, NULL);
    pthread_join(a, NULL);
    pthread_join(b, NULL);

    printf("expected %d, got %ld\n", 2 * ITERS, counter);
    return 0;
}
