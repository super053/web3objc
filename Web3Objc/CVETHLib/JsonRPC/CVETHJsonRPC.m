//
//  CVETHJsonRPC.m
//  CVETHWallet
//
//  Created by coin on 03/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import "CVETHJsonRPC.h"
#import "CVWebAPI.h"
#import "SBJSON.h"
#import "CVETHABIArgument.h"
#import "NSString+CVETH.h"
#import "NSData+CVETH.h"

@implementation CVETHJsonRPC
/*RPC*/

+(void)getBalanceAddress:(NSString *)_address UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion
{
    if (_useIndocator) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_START" object:nil userInfo:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSDictionary *successResult = [self getBalanceAddress:_address];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_useIndocator) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_STOP" object:nil userInfo:nil];
            }
            
            completion(successResult);
        });
    });
}
+(NSDictionary *)getBalanceAddress:(NSString *)_address
{
    return [self getJsonRPCData:@"eth_getBalance" WithParams:@[_address,@"latest"]];
}

+(void)getTransactionCount:(NSString *)_address UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion
{
    if (_useIndocator) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_START" object:nil userInfo:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSDictionary *successResult = [self getTransactionCount:_address];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_useIndocator) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_STOP" object:nil userInfo:nil];
            }
            
            completion(successResult);
        });
    });
}
+(NSDictionary *)getTransactionCount:(NSString *)_address
{
    return [self getJsonRPCData:@"eth_getTransactionCount" WithParams:@[_address,@"latest"]];
}

+(void)getGasPriceUseIndicator:(BOOL)_useIndocator Completion:(void (^)(NSDictionary *successResult))completion
{
    if (_useIndocator) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_START" object:nil userInfo:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSDictionary *successResult = [self getGasPrice];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_useIndocator) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_STOP" object:nil userInfo:nil];
            }
            
            completion(successResult);
        });
    });
}
+(NSDictionary *)getGasPrice
{
    return [self getJsonRPCData:@"eth_gasPrice" WithParams:@[]];
}

+(void)estimateGasFrom:(NSString *)_fromAddress To:(NSString *)_toAddress GasPrice:(NSString *)_gasPrice Amount:(NSString *)_amount Data:(NSString *)_data UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion
{
    if (_useIndocator) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_START" object:nil userInfo:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSDictionary *successResult = [self estimateGasFrom:_fromAddress To:_toAddress GasPrice:_gasPrice Amount:_amount Data:_data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_useIndocator) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_STOP" object:nil userInfo:nil];
            }
            
            completion(successResult);
        });
    });
}
+(NSDictionary *)estimateGasFrom:(NSString *)_fromAddress To:(NSString *)_toAddress GasPrice:(NSString *)_gasPrice Amount:(NSString *)_amount Data:(NSString *)_data
{
    NSDictionary *paramDic = @{@"data":_data,@"from":_fromAddress,@"gasPrice":_gasPrice,@"to":_toAddress,@"value":_amount};
    return [self getJsonRPCData:@"eth_estimateGas" WithParams:@[paramDic]];
}

+(void)sendRawTransaction:(NSString *)_hash UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion
{
    if (_useIndocator) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_START" object:nil userInfo:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSDictionary *successResult = [self sendRawTransaction:_hash];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_useIndocator) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_STOP" object:nil userInfo:nil];
            }
            
            completion(successResult);
        });
    });
}
+(NSDictionary *)sendRawTransaction:(NSString *)_hash
{
    return [self getJsonRPCData:@"eth_sendRawTransaction" WithParams:@[_hash]];
}

+(void)getTransactionByHash:(NSString *)_txHash UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion
{
    if (_useIndocator) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_START" object:nil userInfo:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSDictionary *successResult = [self getTransactionByHash:_txHash];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_useIndocator) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_STOP" object:nil userInfo:nil];
            }
            
            completion(successResult);
        });
    });
}
+(NSDictionary *)getTransactionByHash:(NSString *)_txHash
{
    return [self getJsonRPCData:@"eth_getTransactionByHash" WithParams:@[_txHash]];
}

+(void)getTransactionReceipt:(NSString *)_txHash UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion
{
    if (_useIndocator) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_START" object:nil userInfo:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSDictionary *successResult = [self getTransactionReceipt:_txHash];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_useIndocator) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_STOP" object:nil userInfo:nil];
            }
            
            completion(successResult);
        });
    });
}
+(NSDictionary *)getTransactionReceipt:(NSString *)_txHash
{
    return [self getJsonRPCData:@"eth_getTransactionReceipt" WithParams:@[_txHash]];
}

+(void)getTokenInfo:(NSString *)_contractAddress UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *infoDic))completion
{
    if (_useIndocator) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_START" object:nil userInfo:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSDictionary *successResult = [self getTokenInfo:_contractAddress];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_useIndocator) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_STOP" object:nil userInfo:nil];
            }
            
            completion(successResult);
        });
    });
}
+(NSDictionary *)getTokenInfo:(NSString *)_contractAddress
{
    NSString *nameSelector = [NSString stringWithFormat:@"0x%@", [CVETHABIArgument functionsSelectorHash:@"name()"]];
    NSString *symbolSelector = [NSString stringWithFormat:@"0x%@", [CVETHABIArgument functionsSelectorHash:@"symbol()"]];
    NSString *decimalSelector = [NSString stringWithFormat:@"0x%@", [CVETHABIArgument functionsSelectorHash:@"decimals()"]];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setValue:@"" forKey:@"name"];
    [info setValue:@"" forKey:@"symbol"];
    [info setValue:@"" forKey:@"decimal"];
    NSDictionary *nameDic = [self ethCallFrom:@"" To:_contractAddress Gas:@"" GasPrice:@"" Value:@"" Data:nameSelector];
    if ([nameDic valueForKey:@"result"]) {
        NSString *nameStr = [CVETHABIArgument stringFromArgument:[nameDic valueForKey:@"result"]];
        [info setValue:nameStr forKey:@"name"];
    }
    
    
    NSDictionary *symbolDic = [self ethCallFrom:@"" To:_contractAddress Gas:@"" GasPrice:@"" Value:@"" Data:symbolSelector];
    if ([symbolDic valueForKey:@"result"]) {
        NSString *sumbolStr = [CVETHABIArgument stringFromArgument:[symbolDic valueForKey:@"result"]];
        [info setValue:sumbolStr forKey:@"symbol"];
    }
    
    NSDictionary *decimalDic = [self ethCallFrom:@"" To:_contractAddress Gas:@"" GasPrice:@"" Value:@"" Data:decimalSelector];
    if ([decimalDic valueForKey:@"result"]) {
        NSString *decimalStr = [[decimalDic valueForKey:@"result"] decFromHex];
        [info setValue:decimalStr forKey:@"decimal"];
    }
    return info;
}
+(void)getTokenDecimals:(NSString *)_contractAddress UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *infoDic))completion
{
    if (_useIndocator) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_START" object:nil userInfo:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSDictionary *successResult = [self getTokenDecimals:_contractAddress];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_useIndocator) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_STOP" object:nil userInfo:nil];
            }
            
            completion(successResult);
        });
    });
}
+(NSDictionary *)getTokenDecimals:(NSString *)_contractAddress
{
    NSString *decimalSelector = [NSString stringWithFormat:@"0x%@", [CVETHABIArgument functionsSelectorHash:@"decimals()"]];
    return [self ethCallFrom:@"" To:_contractAddress Gas:@"" GasPrice:@"" Value:@"" Data:decimalSelector];
}
+(void)getBalanceToken:(NSString *)_contract Address:(NSString *)_address UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion
{
    if (_useIndocator) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_START" object:nil userInfo:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSDictionary *successResult = [self getBalanceToken:_contract Address:_address];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_useIndocator) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_STOP" object:nil userInfo:nil];
            }
            
            completion(successResult);
        });
    });
}
+(NSDictionary *)getBalanceToken:(NSString *)_contract Address:(NSString *)_address
{
    NSString *funcStr = @"balanceOf(address)";
    
    NSString *funcSelector = [CVETHABIArgument functionsSelectorHash:funcStr];
    NSString *addressArgument = [CVETHABIArgument argumentWithPadding:[_address removePrefix0x]];
    NSString *_data = [NSString stringWithFormat:@"0x%@%@", funcSelector, addressArgument];
    
    return [self ethCallFrom:@"" To:_contract Gas:@"" GasPrice:@"" Value:@"" Data:_data];
}
+(NSString *)transferDataStringAddress:(NSString *)_address Amount:(NSString *)_amount
{
    NSString *funcStr = @"transfer(address,uint256)";
    
    NSString *funcSelector = [CVETHABIArgument functionsSelectorHash:funcStr];
    NSString *addressArgument = [CVETHABIArgument argumentWithPadding:[_address removePrefix0x]];
    NSString *amountArgument = [CVETHABIArgument argumentWithPadding:[_amount removePrefix0x]];
    NSString *_data = [NSString stringWithFormat:@"0x%@%@%@", funcSelector, addressArgument, amountArgument];
    return _data;
}
+(void)ethCallFrom:(NSString *)_fromAddress To:(NSString *)_toAddress Gas:(NSString *)_gas GasPrice:(NSString *)_gasPrice Value:(NSString *)_value Data:(NSString *)_data UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion
{
    if (_useIndocator) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_START" object:nil userInfo:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSDictionary *successResult = [self ethCallFrom:_fromAddress To:_toAddress Gas:_gas GasPrice:_gasPrice Value:_value Data:_data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_useIndocator) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTIVITY_INDICATOR_STOP" object:nil userInfo:nil];
            }
            
            completion(successResult);
        });
    });
}
+(NSDictionary *)ethCallFrom:(NSString *)_fromAddress To:(NSString *)_toAddress Gas:(NSString *)_gas GasPrice:(NSString *)_gasPrice Value:(NSString *)_value Data:(NSString *)_data
{
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    if (_fromAddress != nil && ![_fromAddress isEqualToString:@""]) {
        [paramDic setValue:_fromAddress forKey:@"from"];
    }
    if (_toAddress != nil && ![_toAddress isEqualToString:@""]) {
        [paramDic setValue:_toAddress forKey:@"to"];
    }
    if (_gas != nil && ![_gas isEqualToString:@""]) {
        [paramDic setValue:_gas forKey:@"gas"];
    }
    if (_gasPrice != nil && ![_gasPrice isEqualToString:@""]) {
        [paramDic setValue:_gasPrice forKey:@"gasPrice"];
    }
    if (_value != nil && ![_value isEqualToString:@""]) {
        [paramDic setValue:_value forKey:@"value"];
    }
    if (_data != nil && ![_data isEqualToString:@""]) {
        [paramDic setValue:_data forKey:@"data"];
    }
    return [self getJsonRPCData:@"eth_call" WithParams:@[paramDic, @"latest"]];
}

+(NSDictionary *)getJsonRPCData:(NSString *)_method WithParams:(NSArray *)_params
{
    SBJSON *sbjson = [SBJSON new];
#ifdef DEBUG
//    NSLog(@"jsonrpc : %@", _method);
#endif
    
    NSString *requestURLStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"endpoint"];
    if (requestURLStr == nil || [requestURLStr isEqualToString:@""]) {
        return @{@"endpoint":@"not set endpoint. please set endpoint Web3."};
    }
    
    NSDictionary *requestBody = @{@"jsonrpc":@"2.0",@"method":_method,@"params":_params,@"id":@1};
    NSString *bodyStr = [sbjson stringWithObject:requestBody error:nil];
    NSData *jsonData = [CVWebAPI sendJSONRPC:requestURLStr WithBodyStr:bodyStr];
    NSString *tmp = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSDictionary *successResult = [sbjson objectWithString:tmp error:nil];
    if (successResult) {
        return successResult;
    } else {
        return @{@"rpcmessage":tmp};
    }
}
@end
