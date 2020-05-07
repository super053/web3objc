//
//  CVETHWallet.h
//  CVETHWallet
//
//  Created by coin on 03/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CVETHWallet : NSObject
+(NSString *)getRandomKeyByLength:(NSInteger)_length;
+(NSString *)getRandomKeyByBytes:(NSInteger)_bytes;
+(NSString *)getWalletAddress:(NSString *)_privKey;
+(NSString *)getCheckSumAddress:(NSString *)_address;
+(BOOL)checkAddressCheckSum:(NSString *)_address;

+ (NSData *) _publicKeyFromPrivateKey:(NSData *)privateKey;
+(NSDictionary *)encryptMessage:(NSData *)_message WithPubKey:(NSData *)_pubkey;
+(NSDictionary *)encryptMessage:(NSData *)_message WithPubKey:(NSData *)_pubkey WithSigner:(NSData *)_m_privkey;
+(NSData *)decryptMessage:(NSDictionary *)_encMessage WithPrivKey:(NSData *)_privkey;
@end

NS_ASSUME_NONNULL_END
