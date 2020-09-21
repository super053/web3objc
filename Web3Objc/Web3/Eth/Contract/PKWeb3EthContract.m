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
    NSArray *outputArr = [[abiDic objectForKey:functionSelector] objectForKey:@"outputs"];
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
    return [self getDecodeData:result WithOutput:outputArr];
}
-(id)getDecodeData:(NSString *)result WithOutput:(NSArray *)outputArr {
    if (outputArr.count == 1) {
        NSDictionary *argType = [outputArr objectAtIndex:0];
        NSString *argTypeStr = [argType valueForKey:@"type"];
        if ([argTypeStr hasSuffix:@"[]"]) {
            if (result.length < 128) {
                return nil;
            }
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            int arrCount = [[[result substringWithRange:NSMakeRange(64, 64)] decFromHex] intValue];
            NSString *arrResult = [result substringWithRange:NSMakeRange(128, result.length - 128)];
            
            for (int i=0; i<arrCount; i++) {
                NSString *argData = [arrResult substringWithRange:NSMakeRange(64 * i, 64)];
                if ([argTypeStr hasPrefix:@"int"] || [argTypeStr hasPrefix:@"uint"]) {
                    [arr addObject:[CVETHABIArgument toInt:argData]];
                } else if ([argTypeStr hasPrefix:@"address"]) {
                    [arr addObject:[CVETHABIArgument toAddress:argData]];
                } else if ([argTypeStr hasPrefix:@"bool"]) {
                    [arr addObject:[NSNumber numberWithBool:[CVETHABIArgument toBool:argData]]];
                } else if ([argTypeStr isEqualToString:@"bytes"] || [argTypeStr hasPrefix:@"string"]) {
                    NSInteger location = [[argData decFromHex] integerValue] * 2;
                    NSString *pointerData = [arrResult substringWithRange:NSMakeRange(location, arrResult.length - location)];
                    
                    if ([argTypeStr isEqualToString:@"bytes"]) {
                        [arr addObject:[CVETHABIArgument toBytes:pointerData]];
                    } else if ([argTypeStr hasPrefix:@"string"]) {
                        [arr addObject:[CVETHABIArgument toString:pointerData]];
                    }
                } else if ([argTypeStr hasPrefix:@"bytes"]) { //bytes32, 24 etc..
                    [arr addObject:[CVETHABIArgument toBytes:argData]];
                } else {
                    return nil;
                }
            }
            
            return arr;
        } else {
            if ([argTypeStr hasPrefix:@"int"] || [argTypeStr hasPrefix:@"uint"]) {
                return [CVETHABIArgument toInt:result];
            } else if ([argTypeStr hasPrefix:@"address"]) {
                return [CVETHABIArgument toAddress:result];
            } else if ([argTypeStr hasPrefix:@"bool"]) {
                return [NSNumber numberWithBool:[CVETHABIArgument toBool:result]];
            } else if ([argTypeStr isEqualToString:@"bytes"]) {
                return [CVETHABIArgument toBytes:[result substringWithRange:NSMakeRange(64, result.length - 64)]];
            } else if ([argTypeStr hasPrefix:@"string"]) {
                return [CVETHABIArgument toString:[result substringWithRange:NSMakeRange(64, result.length - 64)]];
            } else if ([argTypeStr hasPrefix:@"bytes"]) { //bytes32, 24 etc..
                return [CVETHABIArgument toBytes:result];
            } else {
                return nil;
            }
        }
    }
    
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    for (int i=0;i<outputArr.count;i++) {
        NSDictionary *argType = [outputArr objectAtIndex:i];
        NSString *argTypeStr = [argType valueForKey:@"type"];
        NSString *argnameStr = [argType valueForKey:@"name"];
        if (argnameStr == nil || [argnameStr isEqualToString:@""]) {
            argnameStr = [NSString stringWithFormat:@"output_%d", i];
        }
        NSString *argData = [result substringWithRange:NSMakeRange(64 * i, 64)];
        if ([argTypeStr hasSuffix:@"[]"]) {
            NSInteger location = [[argData decFromHex] integerValue] * 2;
            NSString *pointerData = [result substringWithRange:NSMakeRange(location, result.length - location)];
            if (pointerData.length < 64) {
                return nil;
            }
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            int arrCount = [[[pointerData substringWithRange:NSMakeRange(0, 64)] decFromHex] intValue];
            NSString *arrResult = [pointerData substringWithRange:NSMakeRange(64, pointerData.length - 64)];
            
            for (int j=0; j<arrCount; j++) {
                NSString *argData_in = [arrResult substringWithRange:NSMakeRange(64 * j, 64)];
                if ([argTypeStr hasPrefix:@"int"] || [argTypeStr hasPrefix:@"uint"]) {
                    [arr addObject:[CVETHABIArgument toInt:argData_in]];
                } else if ([argTypeStr hasPrefix:@"address"]) {
                    [arr addObject:[CVETHABIArgument toAddress:argData_in]];
                } else if ([argTypeStr hasPrefix:@"bool"]) {
                    [arr addObject:[NSNumber numberWithBool:[CVETHABIArgument toBool:argData_in]]];
                } else if ([argTypeStr isEqualToString:@"bytes"] || [argTypeStr hasPrefix:@"string"]) {
                    NSInteger location_in = [[argData_in decFromHex] integerValue] * 2;
                    NSString *pointerData_in = [arrResult substringWithRange:NSMakeRange(location_in, arrResult.length - location_in)];
                    
                    if ([argTypeStr isEqualToString:@"bytes"]) {
                        [arr addObject:[CVETHABIArgument toBytes:pointerData_in]];
                    } else if ([argTypeStr hasPrefix:@"string"]) {
                        [arr addObject:[CVETHABIArgument toString:pointerData_in]];
                    }
                } else if ([argTypeStr hasPrefix:@"bytes"]) { //bytes32, 24 etc..
                    [arr addObject:[CVETHABIArgument toBytes:argData_in]];
                } else {
                    return nil;
                }
            }
            
            [retDic setValue:arr forKey:argnameStr];
        } else {
            if ([argTypeStr hasPrefix:@"int"] || [argTypeStr hasPrefix:@"uint"]) {
                [retDic setValue:[CVETHABIArgument toInt:argData] forKey:argnameStr];
            } else if ([argTypeStr hasPrefix:@"address"]) {
                [retDic setValue:[CVETHABIArgument toAddress:argData] forKey:argnameStr];
            } else if ([argTypeStr hasPrefix:@"bool"]) {
                [retDic setValue:[NSNumber numberWithBool:[CVETHABIArgument toBool:argData]] forKey:argnameStr];
            } else if ([argTypeStr isEqualToString:@"bytes"] || [argTypeStr hasPrefix:@"string"]) {
                NSInteger location = [[argData decFromHex] integerValue] * 2;
                NSString *pointerData = [result substringWithRange:NSMakeRange(location, result.length - location)];
                if ([argTypeStr isEqualToString:@"bytes"]) {
                    [retDic setValue:[CVETHABIArgument toBytes:pointerData] forKey:argnameStr];
                } else if ([argTypeStr hasPrefix:@"string"]) {
                    [retDic setValue:[CVETHABIArgument toString:pointerData] forKey:argnameStr];
                }
            } else if ([argTypeStr hasPrefix:@"bytes"]) { //bytes32, 24 etc..
                [retDic setValue:[CVETHABIArgument toBytes:argData] forKey:argnameStr];
            } else {
                [retDic setValue:argData forKey:argnameStr];
            }
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
        if ([argTypeStr hasSuffix:@"[]"]) {
            NSArray *argDataArr = [_arguments objectAtIndex:i];
            NSString *location = [[NSString stringWithFormat:@"%lu", (argArr.count * 32) + (pointerString.length / 2)] hexFromDec];
            encodeString = [NSString stringWithFormat:@"%@%@", encodeString, [CVETHABIArgument argumentWithPadding:location]];
            pointerString = [NSString stringWithFormat:@"%@%@", pointerString, [CVETHABIArgument fromInt:[NSString stringWithFormat:@"%lu", (unsigned long)argDataArr.count]]];
            
            NSString *encodeString_in = @"";
            NSString *pointerString_in = @"";
            
            for (int j=0;j<argDataArr.count;j++) {
                NSString *argData = [argDataArr objectAtIndex:j];
                if ([argTypeStr hasPrefix:@"int"] || [argTypeStr hasPrefix:@"uint"]) {
                    pointerString = [NSString stringWithFormat:@"%@%@", pointerString, [CVETHABIArgument fromInt:argData]];
                } else if ([argTypeStr hasPrefix:@"address"]) {
                    pointerString = [NSString stringWithFormat:@"%@%@", pointerString, [CVETHABIArgument fromAddress:argData]];
                } else if ([argTypeStr hasPrefix:@"bool"]) {
                    pointerString = [NSString stringWithFormat:@"%@%@", pointerString, [CVETHABIArgument fromBool:argData]];
                } else if ([argTypeStr isEqualToString:@"bytes"] || [argTypeStr hasPrefix:@"string"]) {
                    NSString *location_in = [[NSString stringWithFormat:@"%lu", (argDataArr.count * 32) + (pointerString_in.length / 2)] hexFromDec];
                    encodeString_in = [NSString stringWithFormat:@"%@%@", encodeString_in, [CVETHABIArgument argumentWithPadding:location_in]];
                    if ([argTypeStr isEqualToString:@"bytes"]) {
                        pointerString_in = [NSString stringWithFormat:@"%@%@", pointerString_in, [CVETHABIArgument fromBytes:[argData removePrefix0x]]];
                    } else {
                        pointerString_in = [NSString stringWithFormat:@"%@%@", pointerString_in, [CVETHABIArgument fromString:argData]];
                    }
                } else if ([argTypeStr hasPrefix:@"bytes"]) { //bytes32, 24 etc..
                    pointerString = [NSString stringWithFormat:@"%@%@", encodeString, [CVETHABIArgument  fromDataNoLength:[[argData removePrefix0x] parseHexData]]];
                } else {
                    return nil;
                }
            }
            pointerString = [NSString stringWithFormat:@"%@%@%@", pointerString, encodeString_in, pointerString_in];
        } else {
            NSString *argData = [_arguments objectAtIndex:i];
            
            if ([argTypeStr hasPrefix:@"int"] || [argTypeStr hasPrefix:@"uint"]) {
                encodeString = [NSString stringWithFormat:@"%@%@", encodeString, [CVETHABIArgument fromInt:argData]];
            } else if ([argTypeStr hasPrefix:@"address"]) {
                encodeString = [NSString stringWithFormat:@"%@%@", encodeString, [CVETHABIArgument fromAddress:argData]];
            } else if ([argTypeStr hasPrefix:@"bool"]) {
                encodeString = [NSString stringWithFormat:@"%@%@", encodeString, [CVETHABIArgument fromBool:argData]];
            } else if ([argTypeStr isEqualToString:@"bytes"] || [argTypeStr hasPrefix:@"string"]) {
                NSString *location = [[NSString stringWithFormat:@"%lu", (argArr.count * 32) + (pointerString.length / 2)] hexFromDec];
                encodeString = [NSString stringWithFormat:@"%@%@", encodeString, [CVETHABIArgument argumentWithPadding:location]];
                if ([argTypeStr isEqualToString:@"bytes"]) {
                    pointerString = [NSString stringWithFormat:@"%@%@", pointerString, [CVETHABIArgument fromBytes:[argData removePrefix0x]]];
                } else {
                    pointerString = [NSString stringWithFormat:@"%@%@", pointerString, [CVETHABIArgument fromString:argData]];
                }
            } else if ([argTypeStr hasPrefix:@"bytes"]) { //bytes32, 24 etc..
                encodeString = [NSString stringWithFormat:@"%@%@", encodeString, [CVETHABIArgument fromDataNoLength:[[argData removePrefix0x] parseHexData]]];
            } else {
                return nil;
            }
        }
    }
    return [[NSString stringWithFormat:@"%@%@%@", functionSelector, encodeString, pointerString] addPrefix0x];
}
@end
