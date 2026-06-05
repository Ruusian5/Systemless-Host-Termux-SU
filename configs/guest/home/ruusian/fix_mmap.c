#define _GNU_SOURCE
#include <stdio.h>
#include <dlfcn.h>
#include <sys/mman.h>
#include <errno.h>

// Fix 1: Older Android kernels 39-bit mmap limitation
void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset) {
    static void *(*real_mmap)(void *, size_t, int, int, int, off_t) = NULL;
    if (!real_mmap) {
        real_mmap = dlsym(RTLD_NEXT, "mmap");
    }
    if ((unsigned long)addr >= 0x8000000000UL) {
        addr = NULL;
    }
    return real_mmap(addr, length, prot, flags, fd, offset);
}

void *mmap64(void *addr, size_t length, int prot, int flags, int fd, off_t offset) {
    return mmap(addr, length, prot, flags, fd, offset);
}

// Fix 2: Broken close_range syscall on this custom kernel causing 100% CPU lockups
int close_range(unsigned int first, unsigned int last, unsigned int flags) {
    errno = ENOSYS;
    return -1;
}
