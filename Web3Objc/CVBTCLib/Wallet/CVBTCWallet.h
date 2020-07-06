//
//  CVBTCWallet.h
//  Web3Objc
//
//  Created by coin on 06/07/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CVBTCWallet : NSObject

+(NSString *)wifToPrivateKey:(NSString *)_wif;
+(BOOL)isWIF:(NSString *)_wif;
+(BOOL)isWIFCompressed:(NSString *)_wifCompressed;
+(NSString *)privateToWif:(NSString *)_privKey;
+(NSString *)getWalletAddress:(NSString *)_privKey;
+ (NSData *) _publicKeyFromPrivateKey:(NSData *)privateKey;
@end

NS_ASSUME_NONNULL_END
