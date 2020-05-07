#import "NSData+RLP.h"

@implementation NSData (RLP)

+ (NSData *)fromNSValue:(NSValue *)value
{
    NSUInteger size;
    const char *encoding = value.objCType;
    NSGetSizeAndAlignment(encoding, &size, NULL);

    void *ptr = malloc(size);
    [value getValue:ptr size:size];
    return [NSData
        dataWithBytesNoCopy:ptr
        length:size
        freeWhenDone:YES
    ];
}

+ (NSData *)rlpFromNSValue:(NSValue *)value{
    NSUInteger size;
    const char *encoding = value.objCType;
    NSGetSizeAndAlignment(encoding, &size, NULL);

    uint8_t *data = malloc(size);
    [value getValue:data size:size];
    switch (encoding[0]) {
        case 's': // short
        case 'i': // int
        case 'q': // quad
            if (encoding[1] == '\0') {
                // assumption: data returned in little endian
                NSUInteger last = 0;
                for (NSUInteger i = 1; i < size; i++) {
                    if (data[i]) {
                        last = i;
                    }
                }
                if (last == 0 && !data[0]) {
                    // all zeros; return zero length
                    free(data);
                    return [NSData
                        dataWithBytesNoCopy:data
                        length:0
                        freeWhenDone:NO
                    ];
                }
                size = last + 1;
                // now reverse little endian to big endian
                NSUInteger stop = size / 2;
                for (NSUInteger i = 0; i < stop; i++) {
                    NSUInteger j = size - i - 1;
                    uint8_t swap = data[i];
                    data[i] = data[j];
                    data[j] = swap;
                }
                break;
            }
        default:
            NSLog(@"Warning: unhandled encoding: %s", encoding);
    }
    return [NSData
        dataWithBytesNoCopy:data
        length:size
        freeWhenDone:YES
    ];
}

@end
