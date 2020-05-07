//
//  CVETH.m
//  CVETHWallet
//
//  Created by coin on 27/08/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import "CVETH.h"

#define ETH_MESSAGE_FORMAT @"\x19""Ethereum Signed Message:\n%tu"
#define GWEI_WEI @"1000000000"
#define ETH_WEI @"1000000000000000000"


@implementation CVETH

+(NSString *)ethFromHexWei:(NSString *)_hexWei
{
    if ([_hexWei isEqualToString:@""]) {
        return @"0";
    }
    NSString *weiStr = [NSNumberFormatter
                        localizedStringFromNumber:[_hexWei decimalNumberFromHexStr]
                        numberStyle:NSNumberFormatterNoStyle];
    weiStr = [NSString stringWithFormat:@"0000000000000000000%@", weiStr];
    NSString *rearDecimalPoint = [weiStr substringWithRange:NSMakeRange(weiStr.length - 18, 18)];
    NSDecimalNumber *rearDecimal = [NSDecimalNumber decimalNumberWithString:rearDecimalPoint];
    NSDecimalNumber *decimalPow = [[NSDecimalNumber decimalNumberWithString:@"10"] decimalNumberByRaisingToPower:18];
    rearDecimal = [rearDecimal decimalNumberByDividingBy:decimalPow];
    rearDecimalPoint = [NSString stringWithFormat:@"%@", rearDecimal];
    if ([rearDecimalPoint hasPrefix:@"0."]) {
        rearDecimalPoint = [rearDecimalPoint substringWithRange:NSMakeRange(2, rearDecimalPoint.length - 2)];
    }
    NSString *frontDecimalPoint = [weiStr substringWithRange:NSMakeRange(0, weiStr.length - 18)];
    NSDecimalNumber *frontDecimal = [NSDecimalNumber decimalNumberWithString:frontDecimalPoint];
    NSString *result = [NSString stringWithFormat:@"%@.%@", [NSNumberFormatter localizedStringFromNumber:frontDecimal numberStyle:NSNumberFormatterDecimalStyle], rearDecimalPoint];
    return result;
    
    
}
+(NSString *)weiFromHexWei:(NSString *)_hexWei
{
    if ([_hexWei isEqualToString:@""]) {
        return @"0";
    }
    return [NSNumberFormatter
            localizedStringFromNumber:[_hexWei decimalNumberFromHexStr]
            numberStyle:NSNumberFormatterDecimalStyle];
}
+(NSString *)gweiFromHexWei:(NSString *)_hexWei
{
    if ([_hexWei isEqualToString:@""]) {
        return @"0";
    }
    NSString *weiStr = [NSNumberFormatter
                        localizedStringFromNumber:[_hexWei decimalNumberFromHexStr]
                        numberStyle:NSNumberFormatterNoStyle];
    weiStr = [NSString stringWithFormat:@"0000000000%@", weiStr];
    NSString *rearDecimalPoint = [weiStr substringWithRange:NSMakeRange(weiStr.length - 9, 9)];
    NSDecimalNumber *rearDecimal = [NSDecimalNumber decimalNumberWithString:rearDecimalPoint];
    NSDecimalNumber *decimalPow = [[NSDecimalNumber decimalNumberWithString:@"10"] decimalNumberByRaisingToPower:9];
    rearDecimal = [rearDecimal decimalNumberByDividingBy:decimalPow];
    rearDecimalPoint = [NSString stringWithFormat:@"%@", rearDecimal];
    if ([rearDecimalPoint hasPrefix:@"0."]) {
        rearDecimalPoint = [rearDecimalPoint substringWithRange:NSMakeRange(2, rearDecimalPoint.length - 2)];
    }
    NSString *frontDecimalPoint = [weiStr substringWithRange:NSMakeRange(0, weiStr.length - 9)];
    NSDecimalNumber *frontDecimal = [NSDecimalNumber decimalNumberWithString:frontDecimalPoint];
    NSString *result = [NSString stringWithFormat:@"%@.%@", [NSNumberFormatter localizedStringFromNumber:frontDecimal numberStyle:NSNumberFormatterDecimalStyle], rearDecimalPoint];
    return result;
}
+(NSString *)tokenFromHexWei:(NSString *)_hexWei Decimals:(int)_decimals
{
    if ([_hexWei isEqualToString:@""]) {
        return @"0";
    }
    NSString *weiStr = [NSNumberFormatter
                        localizedStringFromNumber:[_hexWei decimalNumberFromHexStr]
                        numberStyle:NSNumberFormatterNoStyle];
    weiStr = [NSString stringWithFormat:@"0000000000000000000%@", weiStr];
    NSString *rearDecimalPoint = [weiStr substringWithRange:NSMakeRange(weiStr.length - _decimals, _decimals)];
    NSDecimalNumber *rearDecimal = [NSDecimalNumber decimalNumberWithString:rearDecimalPoint];
    NSDecimalNumber *decimalPow = [[NSDecimalNumber decimalNumberWithString:@"10"] decimalNumberByRaisingToPower:_decimals];
    rearDecimal = [rearDecimal decimalNumberByDividingBy:decimalPow];
    rearDecimalPoint = [NSString stringWithFormat:@"%@", rearDecimal];
    if ([rearDecimalPoint hasPrefix:@"0."]) {
        rearDecimalPoint = [rearDecimalPoint substringWithRange:NSMakeRange(2, rearDecimalPoint.length - 2)];
    }
    NSString *frontDecimalPoint = [weiStr substringWithRange:NSMakeRange(0, weiStr.length - _decimals)];
    NSDecimalNumber *frontDecimal = [NSDecimalNumber decimalNumberWithString:frontDecimalPoint];
    NSString *result = [NSString stringWithFormat:@"%@.%@", [NSNumberFormatter localizedStringFromNumber:frontDecimal numberStyle:NSNumberFormatterDecimalStyle], rearDecimalPoint];
    return result;
}
+(NSString *)weiFromGas:(NSString *)_gwei
{
    if ([_gwei isEqualToString:@""]) {
        return @"0";
    }
    NSDecimalNumber *gwei = [NSDecimalNumber decimalNumberWithString:[_gwei stringByReplacingOccurrencesOfString:@"," withString:@""]];
    NSDecimalNumber *wei = [gwei decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:GWEI_WEI]];
    
    return [NSNumberFormatter
            localizedStringFromNumber:wei
            numberStyle:NSNumberFormatterDecimalStyle];
}
+(NSString *)hexWeiFromGwei:(NSString *)_gwei
{
    if ([_gwei isEqualToString:@""] || [_gwei isEqualToString:@"0"]) {
        return @"";
    }
    NSDecimalNumber *gwei = [NSDecimalNumber decimalNumberWithString:[_gwei stringByReplacingOccurrencesOfString:@"," withString:@""]];
    NSDecimalNumber *wei = [gwei decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:GWEI_WEI]];
    NSString *weiStr = [NSNumberFormatter
                        localizedStringFromNumber:wei
                        numberStyle:NSNumberFormatterNoStyle];
    return [NSString stringWithFormat:@"0x%@", [weiStr hexFromDec]];
}
+(NSString *)hexWeiFromWei:(NSString *)_wei
{
    if ([_wei isEqualToString:@""] || [_wei isEqualToString:@"0"]) {
        return @"";
    }
    NSDecimalNumber *wei = [NSDecimalNumber decimalNumberWithString:[_wei stringByReplacingOccurrencesOfString:@"," withString:@""]];
    NSString *weiStr = [NSNumberFormatter
                        localizedStringFromNumber:wei
                        numberStyle:NSNumberFormatterNoStyle];
    return [NSString stringWithFormat:@"0x%@", [weiStr hexFromDec]];
}
+(NSString *)hexWeiFromEth:(NSString *)_eth
{
    if ([_eth isEqualToString:@""] || [_eth isEqualToString:@"0"]) {
        return @"";
    }
    NSDecimalNumber *eth = [NSDecimalNumber decimalNumberWithString:[_eth stringByReplacingOccurrencesOfString:@"," withString:@""]];
    NSDecimalNumber *wei = [eth decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:ETH_WEI]];
    NSString *weiStr = [NSNumberFormatter
                        localizedStringFromNumber:wei
                        numberStyle:NSNumberFormatterNoStyle];
    return [NSString stringWithFormat:@"0x%@", [weiStr hexFromDec]];
}
+(NSString *)hexWeiFromToken:(NSString *)_token Decimals:(int)_decimals
{
    if ([_token isEqualToString:@""] || [_token isEqualToString:@"0"]) {
        return @"";
    }
    NSDecimalNumber *token = [NSDecimalNumber decimalNumberWithString:[_token stringByReplacingOccurrencesOfString:@"," withString:@""]];
    NSString *multiplyby = @"1";
    for (int i=0; i<_decimals; i++) {
        multiplyby = [NSString stringWithFormat:@"%@0", multiplyby];
    }
    NSDecimalNumber *wei = [token decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:multiplyby]];
    NSString *weiStr = [NSNumberFormatter
                        localizedStringFromNumber:wei
                        numberStyle:NSNumberFormatterNoStyle];
    return [NSString stringWithFormat:@"0x%@", [weiStr hexFromDec]];
}
//+(NSData *) hashPersonalMessage:(NSData *)message {
//    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:0];
//    NSString *prefix = [NSString stringWithFormat:ETH_MESSAGE_FORMAT, message.length];
//    [data appendData:[prefix dataUsingEncoding:NSASCIIStringEncoding]];
//    [data appendData:message];
//    
//    uint8_t *digest = malloc(sizeof(uint8_t) * SHA3_256_DIGEST_LENGTH);
//    
//    keccak_256(data.bytes, data.length, digest);
//    NSData *hash = [NSData dataWithBytes:digest length:SHA3_256_DIGEST_LENGTH];
//    
//    memset(digest, 0, sizeof(uint8_t) * SHA3_256_DIGEST_LENGTH);
//    free(digest);
//    return hash;
//}
+(NSString *)decimalpadding:(NSString *)_rearDecimalPoint Decimals:(int)_decimals
{
    NSString *argument = [NSString stringWithFormat:@"%@000000000000000000", _rearDecimalPoint];
    argument = [argument substringWithRange:NSMakeRange(0, _decimals)];
    NSString *retVal = [NSString stringWithFormat:@".%@", argument];
    return retVal;
}
@end
