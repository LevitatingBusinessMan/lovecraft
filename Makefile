CC=gcc
CFLAGS=-g

ifeq ($(PREFIX),)
    PREFIX := /usr/local
endif

build: lovecraft.c
	mkdir -p build
	$(CC) $(CFLAGS) -o build/lovecraft lovecraft.c

install:
	install -Dvm 755 ./build/lovecraft			$(DESTDIR)$(PREFIX)/bin/lovecraft
	mkdir -vp $(DESTDIR)$(PREFIX)/share/lovecraft/.indented/
	install -Dvm 755 library/double_no_indent/*	$(DESTDIR)$(PREFIX)/share/lovecraft/
	install -Dvm 755 library/single_indent/*	$(DESTDIR)$(PREFIX)/share/lovecraft/.indented/

clean:
	rm -rv build
