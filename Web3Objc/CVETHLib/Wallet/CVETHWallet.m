//
//  CVETHWallet.m
//  CVETHWallet
//
//  Created by coin on 03/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import "CVETHWallet.h"
#import "TrezorCrypto.h"
#import "NSString+CVETH.h"
#import "NSData+CVETH.h"


@implementation CVETHWallet
+(NSString *)getRandomKeyByLength:(NSInteger)_length
{
    NSString *randomKey = @"";
    for (int i=0; i < _length; i++) {
        srand48(time(0));             // seed
        u_int8_t value = arc4random();
        randomKey = [randomKey stringByAppendingString:[NSString stringWithFormat:@"%x",  value % 16]];
    }
    return randomKey;
}
+(NSString *)getRandomKeyByBytes:(NSInteger)_bytes
{
    return [self getRandomKeyByLength:_bytes * 2];
}
+(NSString *)getWalletAddress:(NSString *)_privKey;
{
    if (_privKey.length != 64) {
        NSLog(@"Invalid Key");
        return nil;
    }
    //공개키 생성
    NSData *pubKeyData = [self _publicKeyFromPrivateKey:[_privKey parseHexData]];
    //    NSLog(@"publicKey : %@", [self dataDirectString:pubKeyData]);
    //공개키 생성 완료 (04 + X-coordinate (32 bytes/64 hex) + Y-coordinate (32 bytes/64 hex))
    
    //주소 가져오기
    NSData *pubKeyData_remove_prefix = [pubKeyData subdataWithRange:NSMakeRange(1, 64)];
    //    NSLog(@"pubKeyData_remove_prefix : %@", pubKeyData_remove_prefix);
//    uint8_t *digest = malloc(sizeof(uint8_t) * SHA3_256_DIGEST_LENGTH);
//    keccak_256(pubKeyData_remove_prefix.bytes, pubKeyData_remove_prefix.length, digest);
//    NSData *hash = [NSData dataWithBytes:digest length:SHA3_256_DIGEST_LENGTH];
    NSData *hash = [pubKeyData_remove_prefix keccak256];
    NSData *address = [hash subdataWithRange:NSMakeRange(hash.length - 20, 20)];
    //    NSLog(@"address : 0x%@", [self dataDirectString:address]);
    //주소 가져오기 끝
    
    //주소 체크섬
    
    
    return [self getCheckSumAddress:[address dataDirectString]];
    //주소 체크섬 끝
}
+(NSString *)getCheckSumAddress:(NSString *)_address
{
    NSString *address_checkSum = [[_address lowercaseString] removePrefix0x];
    NSString *hash_address = [address_checkSum keccak256HashString];
    
    for (int i=0; i<address_checkSum.length; i++) {
        NSString *str = [hash_address substringWithRange:NSMakeRange(i, 1)];
        unsigned hexstr;
        [[NSScanner scannerWithString:str] scanHexInt:&hexstr];
        if (hexstr >= 8) {
            NSString *upperStr = [[address_checkSum substringWithRange:NSMakeRange(i, 1)] uppercaseString];
            address_checkSum = [address_checkSum stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:upperStr];
        }
    }
    //    NSLog(@"checkSum  : %@", address_checkSum);
    return [NSString stringWithFormat:@"0x%@", address_checkSum];
}
+(BOOL)checkAddressCheckSum:(NSString *)_address
{
    return [_address isEqualToString:[self getCheckSumAddress:_address]];
}
+ (NSData *) _publicKeyFromPrivateKey:(NSData *)privateKey {
    uint8_t *publicKey = malloc(sizeof(uint8_t) * 65);
    ecdsa_get_public_key65(&secp256k1, privateKey.bytes, publicKey);
    NSData *publicKeyData = [NSData dataWithBytes:publicKey length:sizeof(uint8_t) * 65];
    memset(publicKey, 0, sizeof(uint8_t) * 65);
    free(publicKey);
    return publicKeyData;
}
+(NSDictionary *)encryptMessage:(NSData *)_message WithPubKey:(NSData *)_pubkey
{
    NSData *ephemPrivateKeyData = [[self getRandomKeyByBytes:32] parseHexData];
    return [self encryptMessage:_message WithPubKey:_pubkey WithSigner:ephemPrivateKeyData];
}
+(NSDictionary *)encryptMessage:(NSData *)_message WithPubKey:(NSData *)_pubkey WithSigner:(NSData *)_m_privkey;
{
    if ([_message length] == 0) {
      return nil;
    }
    NSData *ephemPrivateKeyData = nil;
    NSData *encryptionKey = nil;
    NSData *macKey = nil;
    
    /* Public data */
    NSData *ivData = nil;
    NSData *ephemPublicKeyData = nil;
    NSData *cipherData = nil;
    NSData *macData = nil;
    
    //Preparing ephem keypair
//    ephemPrivateKeyData = [[self getRandomKeyByBytes:32] parseHexData];  //test another pub key
    ephemPrivateKeyData = _m_privkey;
    ephemPublicKeyData = [self _publicKeyFromPrivateKey:ephemPrivateKeyData];
    
    //Preparing initialization vector
    ivData = [[self getRandomKeyByBytes:AES_BLOCK_SIZE] parseHexData];
    
    //Preparing encryption key & mac key
    
    uint8_t *sessionKey = malloc(sizeof(uint8_t) * 65);
    
    /* ECDH */
    ecdh_multiply(&secp256k1, ephemPrivateKeyData.bytes, _pubkey.bytes, sessionKey);
    NSData *px = [NSData dataWithBytes:&(sessionKey[1]) length:SHA256_DIGEST_LENGTH];
    
    memset(sessionKey, 0, sizeof(uint8_t) * 65);
    free(sessionKey);
    
    /* SHA512 */
    uint8_t *digest = malloc(sizeof(uint8_t) * SHA512_DIGEST_LENGTH);
    sha512_Raw(px.bytes, sizeof(uint8_t) * SHA256_DIGEST_LENGTH, digest);
    NSData *sha512Data = [NSData dataWithBytes:digest length:sizeof(uint8_t) * SHA512_DIGEST_LENGTH];
    memset(digest, 0, sizeof(uint8_t) * SHA512_DIGEST_LENGTH);
    free(digest);
    
    /* Keys */
    encryptionKey = [sha512Data subdataWithRange:NSMakeRange(0, SHA512_DIGEST_LENGTH / 2)];
    macKey = [sha512Data subdataWithRange:NSMakeRange(SHA512_DIGEST_LENGTH / 2, SHA512_DIGEST_LENGTH / 2)];
    
    //Encryption
    /* Checking message alignment */
    NSData *messageData = [self _addPaddingIfNeeded:_message blockSize:AES_BLOCK_SIZE];
    
    //buffers
    uint8_t *buffer = malloc(sizeof(uint8_t) * [messageData length]);
    uint8_t *iv = malloc(sizeof(uint8_t) * AES_BLOCK_SIZE);
    memcpy(iv, ivData.bytes, sizeof(uint8_t) * [ivData length]);
    
    /* AES-256-CBC */
    aes_encrypt_ctx context;
    aes_encrypt_key256(encryptionKey.bytes, &context);
    aes_cbc_encrypt(messageData.bytes, buffer, (int)[messageData length], iv, &context);
    
    cipherData = [NSData dataWithBytes:buffer length:[messageData length]];
    
    memset(buffer, 0, sizeof(uint8_t) * [messageData length]);
    memset(iv, 0, sizeof(uint8_t) * AES_BLOCK_SIZE);
    
    free(buffer);
    free(iv);
    
    //Preparing mac
    NSMutableData *dataToMac = [[NSMutableData alloc] init];
    [dataToMac appendData:ivData];
    [dataToMac appendData:ephemPublicKeyData];
//    [dataToMac appendData:[self _publicKeyFromPrivateKey:_m_privkey]]; //test another pub key
    [dataToMac appendData:cipherData];
    
    uint8_t *hmac = malloc(sizeof(uint8_t) * SHA256_DIGEST_LENGTH);
    hmac_sha256(macKey.bytes, (int)[macKey length], dataToMac.bytes, (int)[dataToMac length], hmac);
    
    /* HMAC */
    macData = [NSData dataWithBytes:hmac length:sizeof(uint8_t) * SHA256_DIGEST_LENGTH];
    
    memset(hmac, 0, sizeof(uint8_t) * SHA256_DIGEST_LENGTH);
    free(hmac);
    
    NSDictionary *cryptoMessage = @{@"iv":ivData,@"ephemPublicKey":ephemPublicKeyData, @"cipher":cipherData, @"mac":macData};
    return cryptoMessage;
    
}
+(NSData *)decryptMessage:(NSDictionary *)_encMessage WithPrivKey:(NSData *)_privkey
{
    
    if ([(NSData *)[_encMessage valueForKey:@"ephemPublicKey"] length] != 65 ||
        [(NSData *)[_encMessage valueForKey:@"iv"] length] != AES_BLOCK_SIZE ||
        [(NSData *)[_encMessage valueForKey:@"mac"] length] != SHA256_DIGEST_LENGTH ||
        [(NSData *)[_encMessage valueForKey:@"cipher"] length] == 0) {
      return nil;
    }
    NSData *encMessage_ephemPublicKey = [_encMessage valueForKey:@"ephemPublicKey"];
    NSData *encMessage_iv = [_encMessage valueForKey:@"iv"];
    NSData *encMessage_mac = [_encMessage valueForKey:@"mac"];
    NSData *encMessage_cipher = [_encMessage valueForKey:@"cipher"];
    
    NSData *decryptedData = nil;
    NSData *encryptionKey = nil;
    NSData *macKey = nil;
    
    //Preparing encryption key & mac key
    
    uint8_t *sessionKey = malloc(sizeof(uint8_t) * 65);
    
    /* ECDH */
    ecdh_multiply(&secp256k1, _privkey.bytes, encMessage_ephemPublicKey.bytes, sessionKey);
    NSData *px = [NSData dataWithBytes:&(sessionKey[1]) length:SHA256_DIGEST_LENGTH];
    
    memset(sessionKey, 0, sizeof(uint8_t) * 65);
    free(sessionKey);
    
    /* SHA512 */
    uint8_t *digest = malloc(sizeof(uint8_t) * SHA512_DIGEST_LENGTH);
    sha512_Raw(px.bytes, sizeof(uint8_t) * SHA256_DIGEST_LENGTH, digest);
    NSData *sha512Data = [NSData dataWithBytes:digest length:sizeof(uint8_t) * SHA512_DIGEST_LENGTH];
    memset(digest, 0, sizeof(uint8_t) * SHA512_DIGEST_LENGTH);
    free(digest);
    
    /* Keys */
    encryptionKey = [sha512Data subdataWithRange:NSMakeRange(0, SHA512_DIGEST_LENGTH / 2)];
    macKey = [sha512Data subdataWithRange:NSMakeRange(SHA512_DIGEST_LENGTH / 2, SHA512_DIGEST_LENGTH / 2)];
    
    //Checking mac
    NSMutableData *dataToMac = [[NSMutableData alloc] init];
    [dataToMac appendData:encMessage_iv];
    [dataToMac appendData:encMessage_ephemPublicKey];
    [dataToMac appendData:encMessage_cipher];
    
    uint8_t *hmac = malloc(sizeof(uint8_t) * SHA256_DIGEST_LENGTH);
    hmac_sha256(macKey.bytes, (int)[macKey length], dataToMac.bytes, (int)[dataToMac length], hmac);
    
    /* HMAC */
    NSData *macData = [NSData dataWithBytes:hmac length:sizeof(uint8_t) * SHA256_DIGEST_LENGTH];
    memset(hmac, 0, sizeof(uint8_t) * SHA256_DIGEST_LENGTH);
    free(hmac);
    
    //Compare two buffers in constant time to prevent timing attacks.
    if (![macData isEqualToData:encMessage_mac]) {
      return nil;
    }
    
    //Decryption
    aes_decrypt_ctx context;
    aes_decrypt_key256(encryptionKey.bytes, &context);
    
    //buffers
    uint8_t *buffer = malloc(sizeof(uint8_t) * encMessage_cipher.length);
    uint8_t *iv = malloc(sizeof(uint8_t) * AES_BLOCK_SIZE);
    memcpy(iv, encMessage_iv.bytes, sizeof(uint8_t) * encMessage_iv.length);
    
    /* AES-256-CBC */
    aes_cbc_decrypt(encMessage_cipher.bytes, buffer, (int)encMessage_cipher.length, iv, &context);
    
    memset(iv, 0, sizeof(uint8_t) * AES_BLOCK_SIZE);
    free(iv);
    
    decryptedData = [NSData dataWithBytes:buffer length:encMessage_cipher.length];
    memset(buffer, 0, sizeof(uint8_t) * encMessage_cipher.length);
    free(buffer);
    
    /* Removing alignment */
    decryptedData = [self _removePaddingIfNeeded:decryptedData blockSize:AES_BLOCK_SIZE];
    
    return decryptedData;
}
+ (NSData *) _addPaddingIfNeeded:(NSData *)data blockSize:(NSUInteger)blockSize {
  NSMutableData *mutableData = [data mutableCopy];
  
  uint8_t padding = blockSize - ([mutableData length] % blockSize);
  if (padding == 0) {
    padding = blockSize;
  }
  for (short i = 0; i < padding; ++i) {
    [mutableData appendBytes:&padding length:sizeof(uint8_t)];
  }
  return [mutableData copy];
}
+ (NSData *) _removePaddingIfNeeded:(NSData *)data blockSize:(NSUInteger)blockSize {
  NSData *clearData = data;
  
  /* Removing alignment */
  uint8_t lastByte;
  [data getBytes:&lastByte range:NSMakeRange([data length] - 1, 1)];
  if (lastByte <= blockSize && [data length] > lastByte) {
    BOOL cutPadding = YES;
    uint8_t *lastBytes = malloc(sizeof(uint8_t) * lastByte);
    [data getBytes:lastBytes range:NSMakeRange([data length] - lastByte, lastByte)];
    for (short i = 0; i < lastByte && cutPadding; ++i) {
      cutPadding = cutPadding && (lastBytes[i] == lastByte);
    }
    if (cutPadding) {
      clearData = [data subdataWithRange:NSMakeRange(0, [data length] - lastByte)];
    }
    memset(lastBytes, 0, sizeof(uint8_t) * lastByte);
    free(lastBytes);
  }
  return clearData;
}
@end
