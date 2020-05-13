//
//  PKWeb3Crypto.m
//  Web3Objc
//
//  Created by coin on 13/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import "PKWeb3Crypto.h"
#import "CVETHWallet.h"
#import "NSData+SECP256K1.h"

@implementation PKWeb3Crypto

-(NSDictionary *)encrypt:(NSData *)_data PubKey:(NSData *)_pubkey
{
    return [CVETHWallet encryptMessage:_data WithPubKey:_pubkey];
}
-(NSData *)decrypt:(NSDictionary *)_encData PrivKey:(NSData *)_privkey
{
    return [CVETHWallet decryptMessage:_encData WithPrivKey:_privkey];
}
-(NSData *)sign:(NSData *)_data PrivKey:(NSData *)_privKey
{
    return [_data signWithPrivateKeyData:_privKey];
}
-(NSString *)verify:(NSData *)_data Sig:(NSData *)_sig
{
    NSData *pubKey = [_data getPubKeyDataFromMessageWithSig:_sig];
    
    return [CVETHWallet getWalletAddressFromPublicKey:pubKey];
}
@end
