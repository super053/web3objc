//
//  NSData+CVETH.m
//  CVETHWallet
//
//  Created by coin on 03/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import "NSData+CVETH.h"
#import "TrezorCrypto.h"
#import "ccMemory.h"
static const UniChar base58chars[] = {
    '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
};

@implementation NSData (CVETH)
-(NSString *)dataDirectString
{
    NSMutableString * str = [NSMutableString string];
    const unsigned char *bytes = (const unsigned char *)self.bytes;
    for (int i = 0; i<self.length; i++)
    {
        [str appendFormat:@"%02x", bytes[i]];
    }

//    NSLog(@"%@",str);
//    return [[[[NSString stringWithFormat:@"%@", self] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    if (str.length == 0) {
        return @"";
    }
    return str;
}
-(NSData *)keccak256
{
    uint8_t *digest = malloc(sizeof(uint8_t) * SHA3_256_DIGEST_LENGTH);
    keccak_256(self.bytes, self.length, digest);
    return [NSData dataWithBytes:digest length:SHA3_256_DIGEST_LENGTH];
}
-(NSData *)sha256
{
    uint8_t *digest = malloc(sizeof(uint8_t) * SHA3_256_DIGEST_LENGTH);
//    sha3_256(self.bytes, self.length, digest);
    
    SHA256_CTX ctx;
    sha256_Init(&ctx);
    sha256_Update(&ctx, self.bytes, self.length);
    sha256_Final(&ctx, digest);
    
    return [NSData dataWithBytes:digest length:SHA3_256_DIGEST_LENGTH];
    
}
-(NSString *)base58
{
    size_t i, z = 0;
    
    while (z < self.length && ((const uint8_t *)self.bytes)[z] == 0) z++; // count leading zeroes
    
    uint8_t buf[(self.length - z)*138/100 + 1]; // log(256)/log(58), rounded up

    CC_XZEROMEM(buf, sizeof(buf));

    for (i = z; i < self.length; i++) {
        uint32_t carry = ((const uint8_t *)self.bytes)[i];

        for (ssize_t j = sizeof(buf) - 1; j >= 0; j--) {
            carry += (uint32_t)buf[j] << 8;
            buf[j] = carry % 58;
            carry /= 58;
        }
    }

    i = 0;
    while (i < sizeof(buf) && buf[i] == 0) i++; // skip leading zeroes
    
    NSString *s = @"";
    
    while (z-- > 0)  s = [s stringByAppendingString:[NSString stringWithCharacters:base58chars length:1]];
    while (i < sizeof(buf)) s = [s stringByAppendingString:[NSString stringWithCharacters:&base58chars[buf[i++]] length:1]];
    CC_XZEROMEM(buf, sizeof(buf));
    return s;
}
@end
