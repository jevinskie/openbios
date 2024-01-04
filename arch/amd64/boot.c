/*
 *
 */
#undef BOOTSTRAP
#include "config.h"
#include "libopenbios/bindings.h"
#include "libopenbios/elf_load.h"
#include "arch/common/nvram.h"
#include "libc/diskio.h"
#include "libopenbios/sys_info.h"

int linux_load(struct sys_info *, const char *filename, const char *cmdline);

void boot(void);

void *elf_boot_notes = NULL;

void boot(void)
{
	char *path=pop_fstr_copy(), *param;

	// char *param="root=/dev/hda2 console=ttyS0,115200n8 console=tty0";

	if(!path) {
		printk("[x86] Booting default not supported.\n");
		return;
	}

	param = strchr(path, ' ');
	if(param) {
		*param = '\0';
		param++;
	}

	printk("[x86] Booting file '%s' with parameters '%s'\n",path, param);

	if (elf_load(&sys_info, open_package(param, find_dev(path)), param, &elf_boot_notes) == LOADER_NOT_SUPPORT)
		if (linux_load(&sys_info, path, param) == LOADER_NOT_SUPPORT)
			printk("Unsupported image format\n");

	free(path);
}
