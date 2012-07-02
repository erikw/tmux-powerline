# Build the small MPD NP program.
DEBUG=0
CC = $(shell hash clang 2>/dev/null && echo clang || echo gcc)
CFLAGS = -O3 -Wall -std=c99 -I /usr/include/ -D DEBUG=${DEBUG}
LDLIBS = -lmpdclient

.PHONY: all clean

all: np_mpd

clean:
	$(RM) np_mpd
