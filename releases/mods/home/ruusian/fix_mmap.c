#define _GNU_SOURCE
#include <stdio.h>
#include <dlfcn.h>
#include <sys/mman.h>
#include <errno.h>
#include <sys/syscall.h>
#include <stdarg.h>

// Assembly fallback syscall for ARM64 to prevent dlsym/RTLD_NEXT resolution loops
static inline long raw_syscall(long number, long arg1, long arg2, long arg3, long arg4, long arg5, long arg6) {
    long result;
    __asm__ volatile (
        "mov x8, %1\n"
        "mov x0, %2\n"
        "mov x1, %3\n"
        "mov x2, %4\n"
        "mov x3, %5\n"
        "mov x4, %6\n"
        "mov x5, %7\n"
        "svc #0\n"
        "mov %0, x0\n"
        : "=r"(result)
        : "r"(number), "r"(arg1), "r"(arg2), "r"(arg3), "r"(arg4), "r"(arg5), "r"(arg6)
        : "x0", "x1", "x2", "x3", "x4", "x5", "x8", "memory"
    );
    return result;
}

// Convert raw kernel return value to standard glibc return value and set errno on error
static inline long handle_error(long rc) {
    if (rc < 0 && rc >= -4095) {
        errno = -rc;
        return -1;
    }
    return rc;
}

// Fix 1: Older Android kernels 39-bit mmap limitation (glibc mmap override)
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

// Intercept direct syscall() used by tcmalloc with recursion guard
long syscall(long number, ...) {
    static long (*real_syscall)(long, ...) = NULL;
    static __thread int in_syscall = 0; // Thread-local recursion guard

    va_list args;
    va_start(args, number);

    // Guard recursion during dlsym resolution (e.g. timeout call)
    if (in_syscall) {
        long a1 = va_arg(args, long);
        long a2 = va_arg(args, long);
        long a3 = va_arg(args, long);
        long a4 = va_arg(args, long);
        long a5 = va_arg(args, long);
        long a6 = va_arg(args, long);
        va_end(args);
        return raw_syscall(number, a1, a2, a3, a4, a5, a6);
    }

    if (!real_syscall) {
        in_syscall = 1;
        real_syscall = dlsym(RTLD_NEXT, "syscall");
        in_syscall = 0;
    }

    if (number == SYS_mmap) {
        void *addr = va_arg(args, void *);
        size_t length = va_arg(args, size_t);
        int prot = va_arg(args, int);
        int flags = va_arg(args, int);
        int fd = va_arg(args, int);
        off_t offset = va_arg(args, off_t);
        va_end(args);

        if ((unsigned long)addr >= 0x8000000000UL) {
            addr = NULL;
        }
        return (long)mmap(addr, length, prot, flags, fd, offset);
    }

    long a1 = va_arg(args, long);
    long a2 = va_arg(args, long);
    long a3 = va_arg(args, long);
    long a4 = va_arg(args, long);
    long a5 = va_arg(args, long);
    long a6 = va_arg(args, long);
    va_end(args);

    return real_syscall(number, a1, a2, a3, a4, a5, a6);
}

// Fix 2: Broken close_range syscall on this custom kernel causing 100% CPU lockups (glibc override)
int close_range(unsigned int first, unsigned int last, unsigned int flags) {
    errno = ENOSYS;
    return -1;
}
