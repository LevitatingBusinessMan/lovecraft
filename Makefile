CC=gcc
CFLAGS=-g

.PHONY: build

build:
	mkdir -p build
	$(CC) $(CFLAGS) -o build/lovecraft lovecraft.c

clean:
	rm -rv build
