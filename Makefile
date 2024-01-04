include config-host.mak

all: requirements info build

requirements:
	@which xsltproc &>/dev/null || ( echo ; echo "Please install libxslt2"; \
			echo; exit 1 )

info:
	@echo "Building OpenBIOS for $(TARGETS)"

clean:
	@echo "Cleaning up..."
	@for dir in $(ODIRS); do \
		$(MAKE) $(MAKEFLAGS) -C $$dir clean; \
	done

build: start-build
	@echo ODIR: $(ODIR) ODIRS: $(ODIRS)
	@for dir in $(ODIRS); do \
		$(MAKE) $(MAKEFLAGS) -C $$dir > $$dir/build.log 2>&1 && echo "ok." || \
		( echo "error:"; tail -15 $$dir/build.log; exit 1 ) \
	done

SUBDIR_RULES=$(patsubst %,subdir-%, $(TARGETS))
SUBDIR_MAKEFLAGS=$(if $(V),,--no-print-directory)

quiet-command = $(if $(V),$1,$(if $(2),@echo $2 && $1, @$1))

build-verbose: start-build $(SUBDIR_RULES)

subdir-%:
	$(call quiet-command,$(MAKE) $(MAKEFLAGS) $(SUBDIR_MAKEFLAGS) -C obj-$* V="$(V)" all,)

start-build:
	@echo "Building..."

run:
	@echo "Running..."
	@for dir in $(ODIRS); do \
		$$dir/openbios-unix $$dir/openbios-unix.dict; \
	done


# The following two targets will only work on x86 so far.
#
obj-x86/openbios.iso: $(ODIR)/openbios.multiboot obj-x86/openbios-x86.dict
	@mkisofs -input-charset UTF-8 -r -b boot/grub/stage2_eltorito -no-emul-boot \
	-boot-load-size 4 -boot-info-table -o $@ utils/iso $^

obj-amd64/openbios.iso: obj-amd64/openbios.multiboot obj-amd64/openbios-amd64.dict
	@mkisofs -input-charset UTF-8 -r -b boot/grub/stage2_eltorito -no-emul-boot \
	-boot-load-size 4 -boot-info-table -o $@ utils/iso $^

runiso-x86: obj-x86/openbios.iso
	qemu-system-i386 -cdrom $^

runiso-amd64: obj-amd64/openbios.iso
	qemu-system-x86_64 -cdrom $^
