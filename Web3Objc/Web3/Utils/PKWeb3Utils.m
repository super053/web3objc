//
//  PKWeb3Utils.m
//  Web3Objc
//
//  Created by coin on 07/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import "PKWeb3Utils.h"
#import "CVETH.h"
#define UNIT_MAP @{ @"noether": @"0", @"wei": @"1", @"kwei": @"1000", @"Kwei": @"1000", @"babbage": @"1000", @"femtoether": @"1000", @"mwei": @"1000000", @"Mwei": @"1000000", @"lovelace": @"1000000", @"picoether": @"1000000", @"gwei": @"1000000000", @"Gwei": @"1000000000", @"shannon": @"1000000000", @"nanoether": @"1000000000", @"nano": @"1000000000", @"szabo": @"1000000000000", @"microether": @"1000000000000", @"micro": @"1000000000000", @"finney": @"1000000000000000", @"milliether": @"1000000000000000", @"milli": @"1000000000000000", @"ether": @"1000000000000000000", @"kether": @"1000000000000000000000", @"grand": @"1000000000000000000000", @"mether": @"1000000000000000000000000", @"gether": @"1000000000000000000000000000", @"tether": @"1000000000000000000000000000000"}

@implementation PKWeb3Utils
-(NSString *)randomHex:(NSInteger)_size
{
    return [[CVETHWallet getRandomKeyByBytes:_size] addPrefix0x];
}
-(NSString *)sha3:(NSString *)_string
{
    return [[_string keccak256HashString] addPrefix0x];
}
-(NSString *)keccak256:(NSString *)_string
{
    return [[_string keccak256HashString] addPrefix0x];
}
-(NSString *)toChecksumAddress:(NSString *)_address
{
    return [CVETHWallet getCheckSumAddress:_address];
}
-(BOOL)checkAddressChecksum:(NSString *)_address
{
    return [CVETHWallet checkAddressCheckSum:[_address addPrefix0x]];
}
-(NSString *)numberToHex:(NSString *)_numberString
{
    return [CVETH hexWeiFromWei:_numberString];
}
-(NSString *)hexToNumber:(NSString *)_hex
{
    if ([_hex isEqualToString:@""] || [_hex isEqualToString:@"0x"]) {
        return @"0";
    }
    return [_hex decimalNumberFromHexStr];
}
-(NSString *)utf8ToHex:(NSString *)_String
{
    return [[[_String dataUsingEncoding:NSUTF8StringEncoding] dataDirectString] addPrefix0x];
}
-(NSString *)hexToUtf8:(NSString *)_hex
{
    NSString *retVal = [[NSString alloc] initWithData:[[_hex removePrefix0x] parseHexData] encoding:NSUTF8StringEncoding];
    return retVal;
}
-(NSString *)toWei:(NSString *)_number WithUnit:(nullable NSString *)_unit
{
    NSString *multiplyby = [UNIT_MAP valueForKey:@"ether"];
    if (_unit != nil) {
        multiplyby = [UNIT_MAP valueForKey:_unit];
    }
    if (multiplyby == nil || [multiplyby isEqualToString:@""] || [multiplyby isEqualToString:@"0"]) {
        return @"0";
    }
    NSDecimalNumber *wei = [[NSDecimalNumber decimalNumberWithString:_number] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:multiplyby]];
    return [NSNumberFormatter
            localizedStringFromNumber:wei
            numberStyle:NSNumberFormatterNoStyle];
    
}
-(NSString *)fromWei:(NSString *)_number WithUnit:(nullable NSString *)_unit
{
    NSString *weiStr = [NSString stringWithFormat:@"000000000000000000000000000000%@", _number];
    int _decimals = 18;
    if (_unit != nil) {
        if ([_unit isEqualToString:@"noether"]) {
            return @"0";
        } else if ([_unit isEqualToString:@"wei"]) {
            return _number;
        }
        _decimals = (int)[(NSString *)[UNIT_MAP valueForKey:_unit] length] - 1;
    }
    
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
@end
