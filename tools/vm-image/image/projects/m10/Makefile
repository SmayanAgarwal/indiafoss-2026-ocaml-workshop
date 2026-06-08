# M10 memory-safety demos. Each target builds one bug to run and watch
# fail. These are deliberately UNSAFE C programs; the warnings are the
# point. Build them inside the in-browser VM:
#
#   cd /root/m10
#   make uaf        && ./uaf
#   make check_ub check_safe            # UB deletes the guard; -fwrapv keeps it
#   make overflow   && ./overflow AAAAAAAAAAAAAAAAAAAAAAAAAAAA
#   make uninit     && ./uninit
#   make race       && ./race
#   make heartbleed && ./heartbleed_mini

CC      ?= cc
CFLAGS  ?= -Wall

.PHONY: all clean

all: uaf overflow uninit race heartbleed check_ub check_safe

uaf: uaf.c
	$(CC) $(CFLAGS) -o uaf uaf.c

# UB vs -fwrapv: the guard is deleted under the UB assumption, and
# restored when -fwrapv defines signed overflow. Same -O2 both times.
check_ub: deleted_check.c
	$(CC) -O2 -o check_ub deleted_check.c

check_safe: deleted_check.c
	$(CC) -O2 -fwrapv -o check_safe deleted_check.c

# Stack protector off so the overflow corrupts the neighbour, not a canary.
overflow: overflow.c
	$(CC) $(CFLAGS) -fno-stack-protector -o overflow overflow.c

uninit: uninit.c
	$(CC) $(CFLAGS) -o uninit uninit.c

# Built at -O0 on purpose: at -O2 the optimiser collapses the loop
# into a single `counter += ITERS`, which hides the race. At -O0 each
# `counter++` is a real load/add/store that the two threads interleave.
race: race.c
	$(CC) -O0 -o race race.c -lpthread

heartbleed: heartbleed_mini.c
	$(CC) $(CFLAGS) -o heartbleed_mini heartbleed_mini.c

clean:
	rm -f uaf check_ub check_safe overflow uninit race heartbleed_mini
