//
//  PKWeb3Eth.h
//  Web3Objc
//
//  Created by coin on 07/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKWeb3EthContract.h"
#import "PKWeb3EthAccounts.h"
#import "CVETHTransaction.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKWeb3Eth : NSObject

@property (nonatomic, retain) PKWeb3EthContract *contract;
@property (nonatomic, retain) PKWeb3EthAccounts *accounts;

-(NSString *)getGasPrice;
-(NSString *)getBlockNumber;
-(NSString *)getBalance:(NSString *)_address;
-(NSString *)getTranactionCount:(NSString *)_address;
-(NSString *)sendSignedTransaction:(NSString *)_signedTx;
-(NSDictionary *)signedTransaction:(CVETHTransaction *)_tx WithPrivateKey:(NSString *)_privateKey;
-(NSDictionary *)call:(CVETHTransaction *)_tx;
-(NSString *)estimateGas:(CVETHTransaction *)_tx;
-(NSString *)getChainId;

@end

NS_ASSUME_NONNULL_END
