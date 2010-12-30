CC := $(CROSS_COMPILE)gcc

GCONF_CFLAGS := $(shell pkg-config --cflags gconf-2.0 gobject-2.0)
GCONF_LIBS := $(shell pkg-config --libs gconf-2.0 gobject-2.0)

CFLAGS := -O2 -ggdb -Wall -Wextra -Wno-unused-parameter -Wmissing-prototypes -ansi -std=c99

override CFLAGS += -D_GNU_SOURCE
override LDFLAGS += -Wl,--no-undefined -Wl,--as-needed

prefix := /usr
libdir := $(prefix)/lib
version := $(shell ./get-version)

all:

libproxy.so: proxy.o
libproxy.so: override CFLAGS += $(GCONF_CFLAGS) -fPIC
libproxy.so: override LIBS += $(GCONF_LIBS)
libproxy.so: override LDFLAGS += -Wl,-soname,libproxy.so.0

all: libproxy.so

libproxy.pc: libproxy.pc.in
	sed -e 's#@prefix@#$(prefix)#g' \
		-e 's#@version@#$(version)#g' \
		-e 's#@libdir@#$(libdir)#g' $< > $@

D = $(DESTDIR)

install: libproxy.so libproxy.pc
	mkdir -p $(D)/$(libdir)
	install -m 755 libproxy.so $(D)/$(libdir)/libproxy.so.0
	ln -sf libproxy.so.0 $(D)/$(libdir)/libproxy.so
	mkdir -p $(D)/$(prefix)/include/libproxy
	install -m 644 proxy.h $(D)/$(prefix)/include/
	mkdir -p $(D)/$(libdir)/pkgconfig
	install -m 644 libproxy.pc $(D)/$(libdir)/pkgconfig/libproxy.pc

dist: base := libproxy-$(version)
dist:
	git archive --format=tar --prefix=$(base)/ HEAD > /tmp/$(base).tar
	mkdir -p $(base)
	echo $(version) > $(base)/.version
	chmod 664 $(base)/.version
	tar --append -f /tmp/$(base).tar --owner root --group root $(base)/.version
	rm -r $(base)
	gzip /tmp/$(base).tar

# pretty print
ifndef V
QUIET_CC    = @echo '   CC         '$@;
QUIET_LINK  = @echo '   LINK       '$@;
QUIET_CLEAN = @echo '   CLEAN      '$@;
endif

.PHONY: clean

%.so::
	$(QUIET_LINK)$(CC) $(LDFLAGS) -shared -o $@ $^ $(LIBS)

%.o:: %.c
	$(QUIET_CC)$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -o $@ -c $<

clean:
	$(QUIET_CLEAN)$(RM) libproxy.so $(binaries) libproxy.pc \
		`find -name '*.[oad]'`

-include *.d
