//
//  CVBTCWallet.m
//  Web3Objc
//
//  Created by coin on 06/07/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import "CVBTCWallet.h"
#import "TrezorCrypto.h"
#import "NSString+CVETH.h"
#import "NSData+CVETH.h"

#define BITCOIN_PUBKEY 0 //mainnet
//#define BITCOIN_PUBKEY 111 //test

@implementation CVBTCWallet
+(NSString *)wifToPrivateKey:(NSString *)_wif
{
    NSData *decoded = [_wif base58ToData];
    
    NSData *removedPrefixChecksum = [decoded subdataWithRange:NSMakeRange(1, decoded.length - 5)];
    
    return [removedPrefixChecksum dataDirectString];
}
+(BOOL)isWIF:(NSString *)_wif
{
    NSData *decoded = [_wif base58ToData];
    
    NSData *checksum = [decoded subdataWithRange:NSMakeRange(decoded.length - 4, 4)];
    NSData *removedChecksum = [decoded subdataWithRange:NSMakeRange(0, decoded.length - 4)];
    NSData *prefix = [decoded subdataWithRange:NSMakeRange(0, 1)];
    if (![[prefix dataDirectString] isEqualToString:@"80"]) {
        return false;
    }
    NSData *doubleSha256Data = [[removedChecksum sha256] sha256];
    NSData *doubleSha256DataChecksum = [doubleSha256Data subdataWithRange:NSMakeRange(0, 4)];
    
    return [checksum isEqualToData:doubleSha256DataChecksum];
}
+(BOOL)isWIFCompressed:(NSString *)_wifCompressed
{
    NSData *decoded = [_wifCompressed base58ToData];
    
    NSData *checksum = [decoded subdataWithRange:NSMakeRange(decoded.length - 4, 4)];
    NSData *removedChecksum = [decoded subdataWithRange:NSMakeRange(0, decoded.length - 4)];
    NSData *prefix = [decoded subdataWithRange:NSMakeRange(0, 1)];
    if (![[prefix dataDirectString] isEqualToString:@"80"]) {
        return false;
    }
    if (![[[removedChecksum subdataWithRange:NSMakeRange(removedChecksum.length - 1, 1)] dataDirectString] isEqualToString:@"01"]) {
        return false;
    }
    NSData *doubleSha256Data = [[removedChecksum sha256] sha256];
    NSData *doubleSha256DataChecksum = [doubleSha256Data subdataWithRange:NSMakeRange(0, 4)];
    
    return [checksum isEqualToData:doubleSha256DataChecksum];
}
+(NSString *)privateToWif:(NSString *)_privKey
{
    NSData *prefixAdded = [[NSString stringWithFormat:@"80%@", _privKey] parseHexData];
    
    NSData *doubleSha256Data = [[prefixAdded sha256] sha256];
    NSData *checksumData = [doubleSha256Data subdataWithRange:NSMakeRange(0, 4)];
    
    NSMutableData *addedChecksum = [NSMutableData dataWithData:prefixAdded];
    [addedChecksum appendData:checksumData];
    
    return [addedChecksum base58];
    
}
+(NSString *)getWalletAddress:(NSString *)_privKey
{
    if (_privKey.length != 64) {
        NSLog(@"Invalid Key");
        return nil;
    }
    //1. 공개키 생성
    NSData *pubKeyData = [self _publicKeyFromPrivateKey:[_privKey parseHexData]];
    
    //2. 공개키 -> sha256해싱
    NSData *hash = [pubKeyData sha256];
    
    //3. sha256해싱 -> ripemd160
    uint8_t *hash2ripemd160 = malloc(sizeof(uint8_t) * 20);
    ripemd160(hash.bytes, SHA3_256_DIGEST_LENGTH, hash2ripemd160);
    NSData *hash2ripemd160data = [NSData dataWithBytes:hash2ripemd160 length:sizeof(uint8_t) * 20];
    
    //4. 네트워크 prefix + ripemd160 = 메인넷 데이터
    //메인넷 prefix : 0x00(0)
    //테스트넷 : 0x6f(111)
    uint8_t *mainByte = malloc(sizeof(uint8_t));
    mainByte[0] = BITCOIN_PUBKEY;
    NSMutableData *mainnetData = [[NSMutableData alloc] initWithBytes:mainByte length:1];
    [mainnetData appendData:hash2ripemd160data];
    
    //5. sha256 두번 써서 체크섬 생성
    NSData *doubleSha256Data = [[mainnetData sha256] sha256];
    NSData *checksumData = [doubleSha256Data subdataWithRange:NSMakeRange(0, 4)];
    
   //6. 메인넷 데이터 + 체크섬 4바이트 = 주소(hex)
    NSMutableData *hexAddr = [NSMutableData dataWithData:mainnetData];
    [hexAddr appendData:checksumData];
    
    //7. 주소(hex) base58인코딩 -> 일반적인 비트코인 주소.
    NSString *addr = [hexAddr base58];
    
    return addr;
}
+ (NSData *) _publicKeyFromPrivateKey:(NSData *)privateKey
{
    uint8_t *publicKey = malloc(sizeof(uint8_t) * 33);
    ecdsa_get_public_key33(&secp256k1, privateKey.bytes, publicKey);
    NSData *publicKeyData = [NSData dataWithBytes:publicKey length:sizeof(uint8_t) * 33];
    memset(publicKey, 0, sizeof(uint8_t) * 33);
    free(publicKey);
    return publicKeyData;
}

@end
