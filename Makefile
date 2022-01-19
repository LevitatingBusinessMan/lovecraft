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
	mkdir -vp $(DESTDIR)$(PREFIX)/share/lovecraft/
	mkdir -vp $(DESTDIR)$(PREFIX)/share/lovecraft/.double_indented/
	mkdir -vp $(DESTDIR)$(PREFIX)/share/lovecraft/.single_no_indent/
	install -Dvm 755 library/double_no_indent/*	$(DESTDIR)$(PREFIX)/share/lovecraft/
	install -Dvm 755 library/double_indented/*	$(DESTDIR)$(PREFIX)/share/lovecraft/.double_indented/
	install -Dvm 755 library/single_no_indent/*	$(DESTDIR)$(PREFIX)/share/lovecraft/.single_no_indent/

clean:
	rm -rv build
