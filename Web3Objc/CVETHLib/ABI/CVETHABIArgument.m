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
+(NSString *)argumentFromString:(NSString *)_stringArg
{
    NSData *argData = [_stringArg dataUsingEncoding:NSUTF8StringEncoding];
    NSString *retStr = [self argumentWithPadding:@"20"]; //32 hex
    NSString *argDataLength = [[[NSString stringWithFormat:@"%lu", (unsigned long)argData.length] hexFromDec] removePrefix0x];
    retStr = [NSString stringWithFormat:@"%@%@", retStr, [self argumentWithPadding:argDataLength]];
    if (argData.length > 32) {
        int i=0;
        while ((i + 1) * 32 < argData.length) {
            NSData *argSubData = [argData subdataWithRange:NSMakeRange(i * 32, 32)];
            retStr = [NSString stringWithFormat:@"%@%@", retStr, [argSubData dataDirectString]];
            i++;
        }
        NSData *argSubData = [argData subdataWithRange:NSMakeRange(i * 32, argData.length - (i * 32))];
        retStr = [NSString stringWithFormat:@"%@%@", retStr, [self argumentWithRearPadding:[argSubData dataDirectString]]];
        
    } else {
        retStr = [NSString stringWithFormat:@"%@%@", retStr, [self argumentWithRearPadding:[argData dataDirectString]]];
    }
    
    
    return retStr;
}
+(NSString *)stringFromArgument:(NSString *)_resultArg
{
    NSData *resultData = [_resultArg parseHexData];
    if (resultData.length < 64) {
        return @"";
    }
    NSData *stringLength = [NSData dataWithBytes:&resultData.bytes[32] length:32];
    NSData *stringData = [NSData dataWithBytes:&resultData.bytes[64] length:[[[stringLength dataDirectString] decFromHex] intValue]];
    NSString *argStr = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    
    return argStr;
}
@end
