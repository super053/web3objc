//
//  PKWeb3EthContract.m
//  Web3Objc
//
//  Created by coin on 07/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import "PKWeb3EthContract.h"
#import "SBJSON.h"
#import "CVETHABIArgument.h"
#import "NSString+CVETH.h"
#import "CVETHJsonRPC.h"

@implementation PKWeb3EthContract
-(id)initWithAddress:(NSString *)_contractAddress AbiJsonStr:(NSString *)_abistr
{
    SBJSON *sbjson = [SBJSON new];
    NSArray *_abiarr = [sbjson objectWithString:_abistr error:nil];
    return [self initWithAddress:_contractAddress Abi:_abiarr];
}
-(id)initWithAddress:(NSString *)_contractAddress Abi:(NSArray *)_abi
{
    self = [super init];
    if (self) {
        NSMutableDictionary *_abiDic = [[NSMutableDictionary alloc] init];
        for (NSDictionary *abi in _abi) {
            NSString *functionStr = [NSString stringWithFormat:@"%@(", [abi valueForKey:@"name"]];
            for (NSDictionary *input in [abi valueForKey:@"inputs"]) {
                functionStr = [NSString stringWithFormat:@"%@%@,", functionStr, [input valueForKey:@"type"]];
            }
            functionStr = [functionStr substringWithRange:NSMakeRange(0, functionStr.length - 1)];
            functionStr = [NSString stringWithFormat:@"%@)", functionStr];
            NSString *functionSelector = [CVETHABIArgument functionsSelectorHash:functionStr];
            [_abiDic setValue:abi forKey:functionSelector];
        }
        abiDic = [[NSDictionary alloc] initWithDictionary:_abiDic];
        contractAddress = _contractAddress;
    }
    return self;
}
-(id)call:(NSString *)_functionStr WithArgument:(NSArray *)_arguments
{
    NSString *functionSelector = [CVETHABIArgument functionsSelectorHash:_functionStr];
    NSArray *outputArr = [[abiDic objectForKey:functionSelector] objectForKey:@"inputs"];
    if (outputArr == nil || outputArr.count == 0) {
        return nil;
    }
    NSString *encodedData = [self encodeABI:_functionStr WithArgument:_arguments];
    if (encodedData == nil) {
        return nil;
    }
    NSString *result = [[CVETHJsonRPC ethCallFrom:@"" To:[contractAddress addPrefix0x] Gas:@"" GasPrice:@"" Value:@"" Data:encodedData] valueForKey:@"result"];
    if (result == nil || [result isEqualToString:@""]) {
        return nil;
    }
    result = [result removePrefix0x];
    if (outputArr.count == 1) {
        NSDictionary *argType = [outputArr objectAtIndex:0];
        NSString *argTypeStr = [argType valueForKey:@"type"];
        if ([argTypeStr hasPrefix:@"int"] || [argTypeStr hasPrefix:@"uint"]) {
            return [CVETHABIArgument toInt:result];
        } else if ([argTypeStr hasPrefix:@"address"]) {
            return [CVETHABIArgument toAddress:result];
        } else if ([argTypeStr hasPrefix:@"bool"]) {
            return [NSNumber numberWithBool:[CVETHABIArgument toBool:result]];
        } else if ([argTypeStr hasPrefix:@"bytes"]) {
            return [CVETHABIArgument toBytes:[result substringWithRange:NSMakeRange(64, result.length - 64)]];
        } else if ([argTypeStr hasPrefix:@"string"]) {
            return [CVETHABIArgument toString:[result substringWithRange:NSMakeRange(64, result.length - 64)]];
        } else {
            return nil;
        }
    }
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    for (int i=0;i<outputArr.count;i++) {
        NSDictionary *argType = [outputArr objectAtIndex:i];
        NSString *argTypeStr = [argType valueForKey:@"type"];
        NSString *argnameStr = [argType valueForKey:@"type"];
        NSString *argData = [result substringWithRange:NSMakeRange(64 * i, 64)];
        
        if ([argTypeStr hasPrefix:@"int"] || [argTypeStr hasPrefix:@"uint"]) {
            [retDic setValue:[CVETHABIArgument toInt:argData] forKey:argnameStr];
        } else if ([argTypeStr hasPrefix:@"address"]) {
            [retDic setValue:[CVETHABIArgument toAddress:argData] forKey:argnameStr];
        } else if ([argTypeStr hasPrefix:@"bool"]) {
            [retDic setValue:[NSNumber numberWithBool:[CVETHABIArgument toBool:argData]] forKey:argnameStr];
        } else if ([argTypeStr hasPrefix:@"bytes"] || [argTypeStr hasPrefix:@"string"]) {
            NSInteger location = [[argData decFromHex] integerValue] * 2;
            NSString *pointerData = [result substringWithRange:NSMakeRange(location, result.length - location)];
            if ([argTypeStr hasPrefix:@"bytes"]) {
                [retDic setValue:[CVETHABIArgument toBytes:pointerData] forKey:argnameStr];
            } else if ([argTypeStr hasPrefix:@"string"]) {
                [retDic setValue:[CVETHABIArgument toString:pointerData] forKey:argnameStr];
            }
        } else {
            [retDic setValue:argData forKey:argnameStr];
        }
    }
    return retDic;
}

-(NSString *)encodeABI:(NSString *)_functionStr WithArgument:(NSArray *)_arguments
{
    NSString *functionSelector = [CVETHABIArgument functionsSelectorHash:_functionStr];
    NSArray *argArr = [[abiDic objectForKey:functionSelector] objectForKey:@"inputs"];
    if ([argArr count] != [_arguments count]) {
        return nil;
    }
    NSString *encodeString = @"";
    NSString *pointerString = @"";
    for (int i=0;i<argArr.count;i++) {
        NSDictionary *argType = [argArr objectAtIndex:i];
        NSString *argTypeStr = [argType valueForKey:@"type"];
        NSString *argData = [_arguments objectAtIndex:i];
        
        if ([argTypeStr hasPrefix:@"int"] || [argTypeStr hasPrefix:@"uint"]) {
            encodeString = [NSString stringWithFormat:@"%@%@", encodeString, [CVETHABIArgument fromInt:argData]];
        } else if ([argTypeStr hasPrefix:@"address"]) {
            encodeString = [NSString stringWithFormat:@"%@%@", encodeString, [CVETHABIArgument fromAddress:argData]];
        } else if ([argTypeStr hasPrefix:@"bool"]) {
            encodeString = [NSString stringWithFormat:@"%@%@", encodeString, [CVETHABIArgument fromBool:argData]];
        } else if ([argTypeStr hasPrefix:@"bytes"] || [argTypeStr hasPrefix:@"string"]) {
            NSString *location = [[NSString stringWithFormat:@"%lu", (argArr.count * 32) + pointerString.length] hexFromDec];
            encodeString = [NSString stringWithFormat:@"%@%@", encodeString, [CVETHABIArgument argumentWithPadding:location]];
            if ([argTypeStr hasPrefix:@"bytes"]) {
                pointerString = [NSString stringWithFormat:@"%@%@", pointerString, [CVETHABIArgument fromBytes:[argData removePrefix0x]]];
            } else {
                pointerString = [NSString stringWithFormat:@"%@%@", pointerString, [CVETHABIArgument fromString:argData]];
            }
        } else {
            return nil;
        }
    }
    return [[NSString stringWithFormat:@"%@%@%@", functionSelector, encodeString, pointerString] addPrefix0x];
}
@end
