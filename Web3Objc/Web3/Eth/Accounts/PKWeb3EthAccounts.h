//
//  PKWeb3EthAccounts.h
//  Web3Objc
//
//  Created by coin on 07/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CVETHTransaction.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKWeb3EthAccounts : NSObject

-(NSDictionary *)create;
-(NSString *)privateKeyToAccount:(NSString *)_privateKey;
-(NSDictionary *)signTransaction:(CVETHTransaction *)_tx WithPrivateKey:(NSString *)_privateKey;
-(NSString *)recoverTransaction:(NSString *)_rawTx;
-(NSString *)hashMessage:(NSString *)_string;
-(NSDictionary *)sign:(NSString *)_message WithPrivateKey:(NSString *)_privateKey;
-(NSString *)recover:(NSString *)_message WithSignature:(NSString *)_signature;
-(NSDictionary *)encrypt:(NSString *)_privateKey WithPassword:(NSString *)_password;
-(NSDictionary *)decrypt:(NSDictionary *)_jsonDic WithPassword:(NSString *)_password;

@end

NS_ASSUME_NONNULL_END
