//
//  CVETHABIArgument.m
//  CVETHWallet
//
//  Created by coin on 06/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import "CVETHABIArgument.h"
#import "NSString+CVETH.h"
#import "NSData+CVETH.h"

@implementation CVETHABIArgument
/**
encode to bytes
*/
+(NSString *)functionsSelectorHash:(NSString *)_function
{
    return [[_function keccak256HashString] substringToIndex:8];
}
+(NSString *)argumentWithPadding:(NSString *)_arg
{
    NSString *argument = [NSString stringWithFormat:@"0000000000000000000000000000000000000000000000000000000000000000%@", _arg];
    argument = [argument substringWithRange:NSMakeRange(argument.length - 64, 64)];
    return argument;
}
+(NSString *)argumentWithRearPadding:(NSString *)_arg
{
    NSString *argument = [NSString stringWithFormat:@"%@0000000000000000000000000000000000000000000000000000000000000000", _arg];
    argument = [argument substringWithRange:NSMakeRange(0, 64)];
    return argument;
}
+(NSString *)getLocationArgNum:(int)_num
{
    NSString *locPoint = [NSString stringWithFormat:@"%d", 32 * _num];
    return [self argumentWithPadding:[locPoint hexFromDec]];
}

+(NSString *)fromAddress:(NSString *)_addressArg
{
    return [self argumentWithPadding:[_addressArg removePrefix0x]];
}
+(NSString *)fromInt:(NSString *)_intArg
{
    return [self argumentWithPadding:[_intArg hexFromDec]];
}
+(NSString *)fromBool:(nullable NSString *)_boolArg
{
    if (_boolArg == nil || [_boolArg isEqualToString:@""] || [_boolArg isEqualToString:@"0"] || [_boolArg.lowercaseString isEqualToString:@"no"] || [_boolArg isEqualToString:@"false"]) {
        return [self argumentWithPadding:@"0"];
    }
    return [self argumentWithPadding:@"1"];
}
+(NSString *)fromBytes:(NSString *)_bytesArg
{
    NSData *argData = [[_bytesArg removePrefix0x] parseHexData];
    return [self fromData:argData];
}
+(NSString *)fromString:(NSString *)_stringArg
{
    NSData *argData = [_stringArg dataUsingEncoding:NSUTF8StringEncoding];
    return [self fromData:argData];
}

+(NSString *)fromData:(NSData *)_data
{
    NSString *argDataLength = [[[NSString stringWithFormat:@"%lu", (unsigned long)_data.length] hexFromDec] removePrefix0x];
    NSString *retStr = [NSString stringWithFormat:@"%@%@", retStr, [self argumentWithPadding:argDataLength]];
    if (_data.length > 32) {
        int i=0;
        while ((i + 1) * 32 < _data.length) {
            NSData *argSubData = [_data subdataWithRange:NSMakeRange(i * 32, 32)];
            retStr = [NSString stringWithFormat:@"%@%@", retStr, [argSubData dataDirectString]];
            i++;
        }
        NSData *argSubData = [_data subdataWithRange:NSMakeRange(i * 32, _data.length - (i * 32))];
        retStr = [NSString stringWithFormat:@"%@%@", retStr, [self argumentWithRearPadding:[argSubData dataDirectString]]];
        
    } else {
        retStr = [NSString stringWithFormat:@"%@%@", retStr, [self argumentWithRearPadding:[_data dataDirectString]]];
    }
    
    
    return retStr;
}
/**
 decode from bytes
 */
+(NSString *)toInt:(NSString *)_resultArg
{
    return [_resultArg decFromHex];
}
+(NSString *)toAddress:(NSString *)_resultArg
{
    return [[_resultArg substringWithRange:NSMakeRange(_resultArg.length - 40, 40)] addPrefix0x];
}
+(BOOL)toBool:(NSString *)_resultArg
{
    return [[_resultArg decFromHex] isEqualToString:@"1"];
}
+(NSString *)toBytes:(NSString *)_resultArg
{
    NSString *argBytes = [[self toData:_resultArg] dataDirectString];
    return [argBytes addPrefix0x];
}
+(NSString *)toString:(NSString *)_resultArg
{
    NSString *argStr = [[NSString alloc] initWithData:[self toData:_resultArg] encoding:NSUTF8StringEncoding];
    return argStr;
}
+(NSData *)toData:(NSString *)_resultArg
{
    NSData *resultData = [_resultArg parseHexData];
    if (resultData.length < 64) {
        return @"";
    }
    NSData *argLength = [NSData dataWithBytes:&resultData.bytes[0] length:32];
    NSData *argData = [NSData dataWithBytes:&resultData.bytes[32] length:[[[argLength dataDirectString] decFromHex] intValue]];
    return argData;
}
@end
