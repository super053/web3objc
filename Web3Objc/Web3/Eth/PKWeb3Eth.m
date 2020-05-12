//
//  PKWeb3Eth.m
//  Web3Objc
//
//  Created by coin on 07/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import "PKWeb3Eth.h"
#import "CVETH.h"

#import "PKWeb3Objc.h"

@implementation PKWeb3Eth
-(id)init
{
    self = [super init];
    if (self) {
        self.contract = [[PKWeb3EthContract alloc] init];
        self.accounts = [[PKWeb3EthAccounts alloc] init];
    }
    return self;
}
-(NSString *)getGasPrice
{
    NSString *result = [[CVETHJsonRPC getGasPrice] valueForKey:@"result"];
    PKWeb3Objc *web3 = [PKWeb3Objc sharedInstance];
    if (result == nil || [result isEqualToString:@""]) {
        return [web3.utils toWei:@"1" WithUnit:@"gwei"];
    }
    return [result decFromHex];
}
-(NSString *)getBlockNumber
{
    NSString *result = [[CVETHJsonRPC getJsonRPCData:@"eth_blockNumber" WithParams:@[]] valueForKey:@"result"];
    if (result == nil || [result isEqualToString:@""]) {
        return nil;
    }
    return [result decFromHex];
}
-(NSString *)getBalance:(NSString *)_address
{
    NSString *result = [[CVETHJsonRPC getBalanceAddress:[_address addPrefix0x]] valueForKey:@"result"];
    if (result == nil || [result isEqualToString:@""]) {
        return nil;
    }
    return [result decFromHex];
}
-(NSString *)getTranactionCount:(NSString *)_address
{
    NSString *result = [[CVETHJsonRPC getTransactionCount:[_address addPrefix0x]] valueForKey:@"result"];
    if (result == nil || [result isEqualToString:@""]) {
        return nil;
    }
    return [result decFromHex];
}
-(NSString *)sendSignedTransaction:(NSString *)_signedTx
{
    NSString *result = [[CVETHJsonRPC sendRawTransaction:[_signedTx addPrefix0x]] valueForKey:@"result"];
    if (result == nil || [result isEqualToString:@""]) {
        return nil;
    }
    return result;
}
-(NSDictionary *)signedTransaction:(CVETHTransaction *)_tx WithPrivateKey:(NSString *)_privateKey
{
//    NSString *messageHash = [[[_tx hashForSign] dataDirectString] addPrefix0x];
    NSString *rawTransaction = [_tx getSignTX:[_privateKey removePrefix0x]];
    NSString *transactionHash = [[rawTransaction keccak256HashString] addPrefix0x];
    NSString *v = [[[_tx getSignedV] dataDirectString] addPrefix0x];
    NSString *r = [[[_tx getSignedR] dataDirectString] addPrefix0x];
    NSString *s = [[[_tx getSignedS] dataDirectString] addPrefix0x];
    return @{@"raw":rawTransaction,
             @"tx":@{@"nonce":[_tx.nonce addPrefix0x],
                     @"gasPrice":[_tx.gasPrice addPrefix0x],
                     @"gas":[_tx.gasLimit addPrefix0x],
                     @"to":[_tx.to addPrefix0x],
                     @"value":[_tx.value addPrefix0x],
                     @"input":[_tx.data addPrefix0x],
                     @"v":v,
                     @"r":r,
                     @"s":s,
                     @"hash":transactionHash
             }};
}
-(NSString *)call:(CVETHTransaction *)_tx
{
    NSString *result = [[CVETHJsonRPC ethCallFrom:@"" To:[_tx.to addPrefix0x] Gas:@"" GasPrice:@"" Value:@"" Data:[_tx.data addPrefix0x]] valueForKey:@"result"];
    if (result == nil || [result isEqualToString:@""]) {
        return nil;
    }
    return result;
}
-(NSString *)estimateGasFrom:(NSString *)_from TX:(CVETHTransaction *)_tx;
{
    NSString *result = [[CVETHJsonRPC estimateGasFrom:[_from addPrefix0x] To:[_tx.to addPrefix0x] GasPrice:[_tx.gasPrice addPrefix0x] Amount:[_tx.value addPrefix0x] Data:[_tx.data addPrefix0x]] valueForKey:@"result"];
    if (result == nil || [result isEqualToString:@""]) {
        return nil;
    }
    return [result decFromHex];
}
-(NSString *)getChainId
{
    NSString *result = [[CVETHJsonRPC getJsonRPCData:@"eth_chainId" WithParams:@[]] valueForKey:@"result"];
    if (result == nil || [result isEqualToString:@""]) {
        return nil;
    }
    return [result decFromHex];
}
@end
