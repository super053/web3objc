//
//  CVETHKeyStore.m
//  CVETHWallet
//
//  Created by coin on 20/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import "CVETHKeyStore.h"

#include "crypto_scrypt.h"
#import "TrezorCrypto.h"

#import "CVETHWallet.h"
#import "NSString+CVETH.h"
#import "NSData+CVETH.h"

@implementation CVETHKeyStore
+ (NSDictionary *)encryptToKeyStoreWithPrivKey:(NSString *)_privKey Password:(NSString *)_password
{
    /*json-version, address, id*/
    NSInteger version = 3;
    NSString *address = [[[CVETHWallet getWalletAddressFromPrivateKey:_privKey] removePrefix0x] lowercaseString];
    NSString *_id = [[[NSUUID UUID] UUIDString] lowercaseString];
    
    /*json-crypto*/
    NSString *ciphertext = @"";
    
    NSString *iv = [CVETHWallet getRandomKeyByBytes:16];
    NSDictionary *cipherparams = @{@"iv":iv};
    
    NSString *cipher = @"aes-128-ctr";
    NSString *kdf = @"scrypt";
    
    NSInteger dklen = 32;
    NSString *salt = [CVETHWallet getRandomKeyByBytes:32];
//    int n = 262144;
    int n = 4096;
    int r = 8;
    int p = 1;
    NSDictionary *kdfparams = @{@"dklen":[NSNumber numberWithInteger:dklen], @"salt":salt, @"n":[NSNumber numberWithInteger:n], @"r":[NSNumber numberWithInteger:r], @"p":[NSNumber numberWithInteger:p]};
    
    NSString *mac = @"";
    
    
    /*convert password*/
    NSData *passwordData = [[_password precomposedStringWithCompatibilityMapping] dataUsingEncoding:NSUTF8StringEncoding];
    const uint8_t *passwordBytes = [passwordData bytes];
    
    char stop = 0; //acync stop flag
    uint8_t *digest = malloc(sizeof(uint8_t) * 64);
    int status = crypto_scrypt(passwordBytes, (int)passwordData.length, [salt parseHexData].bytes, [salt parseHexData].length, n, r, p, digest, 64, &stop);
    NSData *derivedKey = [NSData dataWithBytes:digest length:64];
    //status != 0 error
    if (status) {
        return nil;
    }
    
    /*get ciphertext*/
    uint8_t *ciphertextData = malloc(sizeof(uint8_t) * 32);
    NSData *encryptKey = [derivedKey subdataWithRange:NSMakeRange(0, 16)];
    
    unsigned char counter[16];
    memcpy(counter, [iv parseHexData].bytes, MIN([iv parseHexData].length, sizeof(counter)));
    
    aes_encrypt_ctx context;
    aes_encrypt_key128(encryptKey.bytes, &context);
    AES_RETURN aesStatus = aes_ctr_encrypt([_privKey parseHexData].bytes,
                                           ciphertextData,
                                           32, //[_privKey parseHexData].length
                                           counter,
                                           &aes_ctr_cbuf_inc,
                                           &context);
    if (aesStatus != EXIT_SUCCESS) {
        return nil;
    }
    ciphertext = [[NSData dataWithBytes:ciphertextData length:32] dataDirectString];
    
    /*get mac*/
    NSMutableData *macCheck = [[NSMutableData alloc] initWithData:[derivedKey subdataWithRange:NSMakeRange(16, 16)]];
    [macCheck appendData:[ciphertext parseHexData]];
    mac = [[macCheck keccak256] dataDirectString];
    
    /*result data*/
    NSDictionary *crypto = @{@"ciphertext":ciphertext, @"cipherparams":cipherparams, @"cipher":cipher, @"kdf":kdf, @"kdfparams":kdfparams, @"mac":mac};
    NSDictionary *keystore = @{@"version":[NSNumber numberWithInteger:version], @"id":_id, @"address":address, @"crypto":crypto};
    
    return keystore;
}
+ (NSString *)decryptKeyStore:(NSDictionary *)_keystore Password:(NSString *)_password
{
    //check json data
    
    NSString *privKey = @"";
    NSInteger version = [[_keystore valueForKey:@"version"] integerValue];
    //check version
    if (version != 3) {
        return nil;
    }
    
    //NSString *_id = [_keystore valueForKey:@"id"]; //not used in descrypt
    NSString *address = [[_keystore valueForKey:@"address"] removePrefix0x];
    //check invalid address
    if (address.length != 40) {
        return nil;
    }
    
    NSDictionary *crypto = [_keystore valueForKey:@"crypto"];
    NSString *ciphertext = [crypto valueForKey:@"ciphertext"];
    NSString *iv = [[crypto valueForKey:@"cipherparams"] valueForKey:@"iv"];
    NSString *cipher = [crypto valueForKey:@"cipher"];
    NSString *kdf = [crypto valueForKey:@"kdf"];
    NSString *mac = [crypto valueForKey:@"mac"];
    //check cipher == 'aes-128-ctr', iv length, cipherText length
    if (![cipher isEqualToString:@"aes-128-ctr"] || iv.length != 32 || ciphertext.length != 64) {
        return nil;
    }
    
    //check mac length
    if (mac.length != 64) {
        return nil;
    }
    
    NSDictionary *kdfparams = [crypto valueForKey:@"kdfparams"];
    NSData *salt = [[kdfparams valueForKey:@"salt"] parseHexData];
    NSInteger dklen = [[kdfparams valueForKey:@"dklen"] integerValue];
    
    //check kdf == 'scrypt', kdf == 'pbkdf2', salt length, n, r, p, dklen length
    if (!([kdf isEqualToString:@"scrypt"] || [kdf isEqualToString:@"pbkdf2"]) || salt.length == 0 || dklen != 32) {
        return nil;
    }
    
    /*convert password*/
    NSData *passwordData = [[_password precomposedStringWithCompatibilityMapping] dataUsingEncoding:NSUTF8StringEncoding];
    const uint8_t *passwordBytes = [passwordData bytes];
    
    
    uint8_t *digest = malloc(sizeof(uint8_t) * 64);
    
    if ([kdf isEqualToString:@"scrypt"]) {
        int n = [[kdfparams valueForKey:@"n"] intValue];
        int r = [[kdfparams valueForKey:@"r"] intValue];
        int p = [[kdfparams valueForKey:@"p"] intValue];
        
        char stop = 0; //acync stop flag
        int status = crypto_scrypt(passwordBytes, (int)passwordData.length, salt.bytes, salt.length, n, r, p, digest, 64, &stop);
        //status != 0 error
        if (status) {
            if (status == -2) {
                //cancelled
                return nil;
            }
            //invalid scrypt parameter
            return nil;
        }
    } else if ([kdf isEqualToString:@"pbkdf2"]) {
        int c = [[kdfparams valueForKey:@"c"] intValue];
        NSString *prf = [kdfparams valueForKey:@"prf"];
        if (![prf isEqualToString:@"hmac-sha256"]) {
            return nil;
        }
        pbkdf2_hmac_sha256(passwordBytes, (int)passwordData.length, salt.bytes, (int)salt.length, c, digest, 64);
    }
    
    NSData *derivedKey = [NSData dataWithBytes:digest length:64];
    
    /*check mac*/
    NSMutableData *macCheck = [[NSMutableData alloc] initWithData:[derivedKey subdataWithRange:NSMakeRange(16, 16)]];
    [macCheck appendData:[ciphertext parseHexData]];
    if (![[[macCheck keccak256] dataDirectString] isEqualToString:mac]) {
        return nil;
    }
    
    /*get priv key*/
    uint8_t *privKeyData = malloc(sizeof(uint8_t) * 32);
    NSData *encryptKey = [derivedKey subdataWithRange:NSMakeRange(0, 16)];
    unsigned char counter[16];
    [[iv parseHexData] getBytes:counter length:[iv parseHexData].length];
    
    aes_encrypt_ctx context;
    aes_encrypt_key128(encryptKey.bytes, &context);
    AES_RETURN aesStatus = aes_ctr_decrypt([ciphertext parseHexData].bytes,
                                           privKeyData,
                                           32,
                                           counter,
                                           &aes_ctr_cbuf_inc,
                                           &context);
    if (aesStatus != EXIT_SUCCESS) {
        return nil;
    }
    privKey = [[NSData dataWithBytes:privKeyData length:32] dataDirectString];
    
    /*check address*/
    if (![[[[CVETHWallet getWalletAddressFromPrivateKey:privKey] removePrefix0x] lowercaseString] isEqualToString:[[address removePrefix0x] lowercaseString]]) {
        return nil;
    }
    
    /*check mnemonic*/
    
    return privKey;
}
@end
