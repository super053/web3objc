//
//  NSMutableData+CVETH.m
//  CVETHWallet
//
//  Created by coin on 21/02/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import "NSMutableData+CVETH.h"
#import "ccMemory.h"

static void *secureAllocate(CFIndex allocSize, CFOptionFlags hint, void *info) {
  void *ptr = CC_XMALLOC(sizeof(CFIndex) + (unsigned long)allocSize);

  if (ptr) {  // we need to keep track of the size of the allocation so it can
    // be cleansed before deallocation
    *(CFIndex *)ptr = allocSize;
    return (CFIndex *)ptr + 1;
  } else
    return NULL;
}

static void secureDeallocate(void *ptr, void *info) {
  CFIndex size = *((CFIndex *)ptr - 1);

  if (size) {
    CC_XZEROMEM(ptr, (unsigned long)size);
    CC_XFREE((CFIndex *)ptr - 1, sizeof(CFIndex) + size);
  }
}

static void *secureReallocate(void *ptr, CFIndex newsize, CFOptionFlags hint,
                              void *info) {
  // There's no way to tell ahead of time if the original memory will be
  // deallocted even if the new size is smaller
  // than the old size, so just cleanse and deallocate every time.
  void *newptr = secureAllocate(newsize, hint, info);
  CFIndex size = *((CFIndex *)ptr - 1);

  if (newptr && size) {
    CC_XMEMCPY(newptr, ptr, (size < newsize) ? (unsigned long)size : (unsigned long)newsize);
    secureDeallocate(ptr, info);
  }

  return newptr;
}

// Since iOS does not page memory to storage, all we need to do is cleanse
// allocated memory prior to deallocation.
inline CFAllocatorRef SecureAllocator() {
  static CFAllocatorRef alloc = NULL;
  static dispatch_once_t onceToken = 0;

  dispatch_once(&onceToken, ^{
      CFAllocatorContext context;

      context.version = 0;
      CFAllocatorGetContext(kCFAllocatorDefault, &context);
      context.allocate = secureAllocate;
      context.reallocate = secureReallocate;
      context.deallocate = secureDeallocate;

      alloc = CFAllocatorCreate(kCFAllocatorDefault, &context);
  });

  return alloc;
}
@implementation NSMutableData (CVETH)
+ (NSMutableData *)secureDataWithCapacity:(NSUInteger)aNumItems {
  return CFBridgingRelease(CFDataCreateMutable(SecureAllocator(), (CFIndex)aNumItems));
}
@end
