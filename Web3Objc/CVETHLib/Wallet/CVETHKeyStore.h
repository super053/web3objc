//
//  CVETHKeyStore.h
//  CVETHWallet
//
//  Created by coin on 20/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CVETHKeyStore : NSObject

+ (NSDictionary *)encryptToKeyStoreWithPrivKey:(NSString *)_privKey Password:(NSString *)_password;
+ (NSString *)decryptKeyStore:(NSDictionary *)_keystore Password:(NSString *)_password;

@end

NS_ASSUME_NONNULL_END
