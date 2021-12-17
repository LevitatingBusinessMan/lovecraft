CC=gcc
CFLAGS=-g

ifeq ($(PREFIX),)
    PREFIX := /usr/local
endif

build: lovecraft.c
	mkdir -p build
	$(CC) $(CFLAGS) -o build/lovecraft lovecraft.c

install:
	install -Dvm 755 ./build/lovecraft $(DESTDIR)$(PREFIX)/bin/lovecraft
	install -Dvm 755 stories/* $(DESTDIR)$(PREFIX)/share/lovecraft/

clean:
	rm -rv build
