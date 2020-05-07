//
//  NSData+SECP256K1.h
//  CVETHWallet
//
//  Created by coin on 29/08/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (SECP256K1)
- (NSData *) signWithPrivateKeyData:(NSData *)privateKeyData;
- (NSData *) getPubKeyDataFromMessageWithSig:(NSData *)_sig;
//- (int)verifySigningWithPublicKeyData:(NSData *)publicKeyData;
@end

NS_ASSUME_NONNULL_END
