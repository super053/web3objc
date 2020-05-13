//
//  PKWeb3Crypto.h
//  Web3Objc
//
//  Created by coin on 13/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKWeb3Crypto : NSObject

-(NSDictionary *)encrypt:(NSData *)_data PubKey:(NSData *)_pubkey;
-(NSData *)decrypt:(NSDictionary *)_encData PrivKey:(NSData *)_privkey;
-(NSData *)sign:(NSData *)_data PrivKey:(NSData *)_privKey;
-(NSString *)verify:(NSData *)_data Sig:(NSData *)_sig;
@end

NS_ASSUME_NONNULL_END
