//
//  NSString+CVETH.m
//  CVETHWallet
//
//  Created by coin on 03/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import "NSString+CVETH.h"
#import "NSDecimalNumber+MOD.h"
#import "NSData+CVETH.h"
#import "NSMutableData+CVETH.h"
#import "TrezorCrypto.h"
#import "ccMemory.h"

static const UniChar base58chars[] = {
  '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P',
  'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'm', 'n',
  'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
};
static const int8_t base58map[] = {
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, -1, -1, -1, -1, -1, -1,
  -1, 9, 10, 11, 12, 13, 14, 15, 16, -1, 17, 18, 19, 20, 21, -1,
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, -1, -1, -1, -1, -1,
  -1, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, -1, 44, 45, 46,
  47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, -1, -1, -1, -1, -1
};

@implementation NSString (CVETH)

- (NSData *)  parseHexData{
    
    NSString *str = [[self removePrefix0x] hexUp];
    if ([str isEqualToString:@"00"]) {
        str = @"";
    }
    NSString *pattern = @".{1,2}";
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options: 0 error: &error];
    
    NSArray *matches = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
    
    NSMutableData *result = [[NSMutableData alloc] init];
    NSInteger i = 0;
    for (NSTextCheckingResult *match in matches) {
        NSString *part = [str substringWithRange:match.range];
        NSScanner *scanner = [NSScanner scannerWithString:part];
        unsigned int hex = 0;
        [scanner scanHexInt:&hex];
        
        UInt8 uintHex = hex;
        [result appendBytes:&uintHex length:sizeof(UInt8)];
        ++i;
    }
    return result;
}
-(NSString *)decFromHex
{
    return [NSNumberFormatter
            localizedStringFromNumber:[self decimalNumberFromHexStr]
            numberStyle:NSNumberFormatterNoStyle];
}
-(NSString *)hexFromDec
{
    NSString *decStr = [self stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString *result = @"";
    NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithString:decStr];
    NSDecimalNumber *modNum = [NSDecimalNumber decimalNumberWithString:@"16"];
    
    while (![[NSNumberFormatter localizedStringFromNumber:decNum numberStyle:NSNumberFormatterNoStyle] isEqualToString:@"0"]) {
        NSDecimalNumber *remineNum = [decNum decimalNumberByModBy:modNum];
        NSString *remine = [NSNumberFormatter
                            localizedStringFromNumber:remineNum
                            numberStyle:NSNumberFormatterNoStyle];
        decNum = [decNum decimalNumberByDividingBy:modNum withBehavior:[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO]];
        if ([remine isEqualToString:@"10"]) {
            remine = @"a";
        } else if ([remine isEqualToString:@"11"]) {
            remine = @"b";
        } else if ([remine isEqualToString:@"12"]) {
            remine = @"c";
        } else if ([remine isEqualToString:@"13"]) {
            remine = @"d";
        } else if ([remine isEqualToString:@"14"]) {
            remine = @"e";
        } else if ([remine isEqualToString:@"15"]) {
            remine = @"f";
        }
        result = [NSString stringWithFormat:@"%@%@", remine, result];
    }
    return [NSString stringWithFormat:@"%@", result];
}
-(NSDecimalNumber *)decimalNumberFromHexStr
{
    NSDecimalNumber *result = [NSDecimalNumber zero];
//    NSString * balance0xremoveStr = self;
//    if ([balance0xremoveStr hasPrefix:@"0x"]) {
//        balance0xremoveStr = [balance0xremoveStr substringWithRange:NSMakeRange(2, balance0xremoveStr.length - 2)];
//    }
    NSString * balance0xremoveStr = [self removePrefix0x];
    
    for (int i=0; i<balance0xremoveStr.length; i++) {
        NSString *currentStr = [balance0xremoveStr substringWithRange:NSMakeRange(balance0xremoveStr.length - i - 1, 1)];
        unsigned int balanceInt;
        [[NSScanner scannerWithString:currentStr] scanHexInt:&balanceInt];
        currentStr = [NSString stringWithFormat:@"%d", balanceInt];
        NSDecimalNumber *currentDecimal = [NSDecimalNumber decimalNumberWithString:currentStr];
        
        NSDecimalNumber *multiflyDecimal = [NSDecimalNumber decimalNumberWithString:@"16"];
        multiflyDecimal = [multiflyDecimal decimalNumberByRaisingToPower:i];
        
        
        NSDecimalNumber *currentResultDecimal = [currentDecimal decimalNumberByMultiplyingBy:multiflyDecimal];
        result = [result decimalNumberByAdding:currentResultDecimal];
    }
    return result;
}
-(NSString *)hexUp
{
    return [self trim].length % 2 == 1 ? [NSString stringWithFormat:@"0%@", [self trim]] : [self trim];
}
-(NSString *)hexTrim
{
    return [[self trim] hasPrefix:@"00"] ? [[self trim] substringFromIndex:2] : [self trim];
}
-(NSString *)removePrefix0x
{
    return [[self trim] hasPrefix:@"0x"] ? [[self trim] substringFromIndex:2] : [self trim];
}
-(NSString *)addPrefix0x
{
    return [[self trim] hasPrefix:@"0x"] ? [self trim] : [NSString stringWithFormat:@"0x%@", [self trim]];
}
-(NSString *)keccak256HashString
{
    NSData *encodData = [self dataUsingEncoding:NSUTF8StringEncoding];
//    uint8_t *digest = malloc(sizeof(uint8_t) * 32);
//    keccak_256(encodData.bytes, encodData.length, digest);
//    NSData *hash = [NSData dataWithBytes:digest length:32];
//    NSString *hashString = [hash dataDirectString];
    NSData *hashData = [encodData keccak256];
    NSString *hashString = [hashData dataDirectString];
    return hashString;
}
-(NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
-(NSData *)base58ToData
{
    // From https://github.com/voisine/breadwallet/blob/ce1d76ef20d39be0ae31c4d5f22f912de4ac0b89/BreadWallet/NSString%2BBitcoin.m
    size_t i, z = 0;
    
    
    // Check all chars are allowed
    BOOL pass;
    for (NSUInteger w = 0; w < self.length; ++w) {
      pass = false;
      for (NSUInteger q = 0; q < 59; ++q)
        if ( [self characterAtIndex:w] == base58chars[q] )
          pass = true;
      if ( !pass )
        return NULL;
    }
    
    
    // Decode
    while (z < self.length && [self characterAtIndex:z] == *base58chars) z++; // count leading zeroes
    
    uint8_t buf[(self.length - z)*733/1000 + 1]; // log(58)/log(256), rounded up
    
    CC_XZEROMEM(buf, sizeof(buf));
    
    for (i = z; i < self.length; i++) {
      
      UniChar c = [self characterAtIndex:i];
      
      if (c >= sizeof(base58map)/sizeof(*base58map) || base58map[c] == -1) break; // invalid base58 digit
      
      uint32_t carry = (uint32_t)base58map[c];
      
      for (ssize_t j = (ssize_t)sizeof(buf) - 1; j >= 0; j--) {
        carry += (uint32_t)buf[j]*58;
        buf[j] = carry & 0xff;
        carry >>= 8;
      }
    }
    i = 0;
    
    while (i < sizeof(buf) && buf[i] == 0) i++; // skip leading zeroes
    
    NSMutableData *d = [NSMutableData secureDataWithCapacity:z + sizeof(buf) - i];
    
    d.length = z;
    
    [d appendBytes:&buf[i] length:sizeof(buf) - i];
    
    CC_XZEROMEM(buf, sizeof(buf));
    
    return d;
}
- (BOOL) isAllDigits
{
    if ([self componentsSeparatedByString:@"."].count > 2) {
        return false;
    }
    NSString *newStr = [self stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [newStr rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound && newStr.length > 0;
}
@end
