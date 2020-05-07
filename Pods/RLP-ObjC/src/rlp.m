#import "rlp.h"

#import "NSData+RLP.h"

// spec: https://github.com/ethereum/wiki/wiki/RLP

// length of encoded size, excluding length prefix byte
static size_t rlp_len_length(size_t length) {
    size_t loglen = 1;
    while (length >>= 8) loglen++;
    return loglen;
}

// the length of a buffer that exact fits the rlp encoding of root
static size_t rlp_buf_length(id root) {
    size_t rootLen;
    if ([root isKindOfClass:[NSData class]]) {
        NSData *rootData = root;
        rootLen = rootData.length;
        if (rootLen == 0
            || (rootLen == 1 && ((uint8_t *)rootData.bytes)[0] < 0x7f)) {
            return 1;
        }
    } else if ([root isKindOfClass:[NSString class]]) {
        NSString *rootString = root;
        rootLen = rootString.length;
        if (rootLen == 0
            || (rootLen == 1 && rootString.UTF8String[0] < 0x7f)) {
            return 1;
        }
    } else if ([root isKindOfClass:[NSValue class]]) {
        NSData *rootData = [NSData rlpFromNSValue:root];
        rootLen = rootData.length;
        if (rootLen == 0
            || (rootLen == 1 && ((uint8_t *)rootData.bytes)[0] < 0x7f)) {
            return 1;
        }
    } else if ([root isKindOfClass:[NSArray class]]) {
        NSArray *rootArray = root;
        rootLen = 0; 
        for (id object in rootArray) {
            rootLen += rlp_buf_length(object);
        }
    } else {
        NSLog(@"Unsupported type: %@", [root class]);
        rootLen = 0;
    }
    if (rootLen <= 55) {
        return 1 + rootLen;
    }
    return 1 + rlp_len_length(rootLen) + rootLen;
}

static void _rlp_encode_buf(uint8_t *outBytes, const uint8_t *inBytes, size_t inLength) {
    if (inLength == 0) {
        *outBytes = 0x80;
        return;
    }
    if (inLength == 1 && *inBytes < 0x7f) {
        *outBytes = *inBytes;
        return;
    }
    #define rlp_encode_length(outBytes, inLength, offset) \
    if (inLength <= 55) { \
        *outBytes++ = offset + inLength; \
    } else { \
        size_t lenLength = rlp_len_length(inLength); \
        *outBytes++ = offset + 55 + lenLength; \
        size_t lengthLeft = inLength; \
        size_t lenLengthLeft = lenLength; \
        while (lenLengthLeft --> 0) { \
            outBytes[lenLengthLeft] = (uint8_t)lengthLeft; \
            lengthLeft >>= 8; \
        } \
        outBytes += lenLength; \
    }
    rlp_encode_length(outBytes, inLength, 0x80);
    for (size_t i = 0; i < inLength; i++) {
        outBytes[i] = inBytes[i];
    }
}
static void _rlp_encode_root(uint8_t *outBytes, id root, size_t bufLength) {
    if ([root isKindOfClass:[NSData class]]) {
        NSData *rootData = root;
        _rlp_encode_buf(outBytes, rootData.bytes, rootData.length);
    } else if ([root isKindOfClass:[NSString class]]) {
        NSString *rootString = root;
        _rlp_encode_buf(outBytes, (uint8_t *)rootString.UTF8String, rootString.length);
    } else if ([root isKindOfClass:[NSValue class]]) {
        NSData *rootData = [NSData rlpFromNSValue:root];
        _rlp_encode_buf(outBytes, rootData.bytes, rootData.length);
    } else if ([root isKindOfClass:[NSArray class]]) {
        NSArray *rootArray = root;
        size_t innerLength;
        // it's 56 not 55 because bufLength includes the length prefix
        if (bufLength <= 56) {
            innerLength = bufLength - 1;
        } else {
            innerLength = bufLength - 1 - rlp_len_length(bufLength - 1);
        }
        rlp_encode_length(outBytes, innerLength, 0xc0);
        for (id leaf in rootArray) {
            size_t leafBufLength = rlp_buf_length(leaf);
            _rlp_encode_root(outBytes, leaf, leafBufLength);
            outBytes += leafBufLength;
        }
    } else {
        NSLog(@"Unsupported type: %@", [root class]);
    }
}

FOUNDATION_EXPORT NSData *rlp_encode(id root) {
    size_t length = rlp_buf_length(root);
    uint8_t *outBuf = malloc(length);
    _rlp_encode_root(outBuf, root, length);
    return [NSData
        dataWithBytesNoCopy:outBuf
        length:length
        freeWhenDone:YES
    ];
}

static id rlp_decode_root(const uint8_t **bytes) {
    uint8_t len = **bytes;
    if (len < 0x80) {
        NSData *small = [NSData dataWithBytes:*bytes length:1];
        (*bytes)++;
        return small;
    }
    (*bytes)++;
    if (len < 0xb8) {
        len -= 0x80;
        NSData *ret = [NSData dataWithBytes:*bytes length:len];
        *bytes += len;
        return ret;
    }
    if (len < 0xc0) {
        len -= 0xb7;
        size_t longLen = 0;
        while (len --> 0) {
            longLen <<= 8;
            longLen |= *(*bytes)++;
        }
        NSData *ret = [NSData dataWithBytes:*bytes length:longLen];
        *bytes += longLen;
        return ret;
    }
    if (len < 0xf8) {
        len -= 0xc0;
    } else {
        len -= 0xf7;
        size_t longLen = 0;
        while (len --> 0) {
            longLen <<= 8;
            longLen |= *(*bytes)++;
        }
        len = longLen;
    }
    NSMutableArray *ret = [NSMutableArray array];
    const uint8_t *destination = *bytes + len;
    while (*bytes < destination) {
        [ret addObject:rlp_decode_root(bytes)];
    }
    return ret;
}

FOUNDATION_EXPORT id rlp_decode(NSData *data) {
    const uint8_t *bytes = data.bytes;
    return rlp_decode_root(&bytes);
}
