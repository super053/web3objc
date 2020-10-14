//
//  PKWeb3EthAccounts.m
//  Web3Objc
//
//  Created by coin on 07/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import "PKWeb3EthAccounts.h"
#import "CVETH.h"
#import "rlp.h"


static NSString *const HASH_MESSAGE_PREFIX = @"\x19""Ethereum Signed Message:\n";

@implementation PKWeb3EthAccounts
-(NSDictionary *)create
{
    NSString *privateKey = [[CVETHWallet getRandomKeyByBytes:32] addPrefix0x];
    NSString *address = [CVETHWallet getWalletAddressFromPrivateKey:[privateKey removePrefix0x]];
    return @{@"privateKey":privateKey,@"address":address};
}
-(NSString *)privateKeyToAccount:(NSString *)_privateKey
{
    return [CVETHWallet getWalletAddressFromPrivateKey:[_privateKey removePrefix0x]];
}
-(NSDictionary *)signTransaction:(CVETHTransaction *)_tx WithPrivateKey:(NSString *)_privateKey
{
    NSString *messageHash = [[[_tx hashForSign] dataDirectString] addPrefix0x];
    NSString *rawTransaction = [_tx getSignTX:[_privateKey removePrefix0x]];
    NSString *transactionHash = [[[[rawTransaction parseHexData] keccak256] dataDirectString] addPrefix0x];
    NSString *v = [[[_tx getSignedV] dataDirectString] addPrefix0x];
    NSString *r = [[[_tx getSignedR] dataDirectString] addPrefix0x];
    NSString *s = [[[_tx getSignedS] dataDirectString] addPrefix0x];
    return @{@"messageHash":messageHash, @"v":v, @"r":r, @"s":s, @"rawTransaction":rawTransaction, @"transactionHash":transactionHash};
}
-(NSString *)recoverTransaction:(NSString *)_rawTx
{
    NSData *encoded = [[_rawTx removePrefix0x] parseHexData];
    NSArray *decodedArr = rlp_decode(encoded);
    if (decodedArr == nil || decodedArr.count != 9) {
        return nil;
    }
    NSData *sign_v = [decodedArr objectAtIndex:6];
    NSData *sign_r = [decodedArr objectAtIndex:7];
    NSData *sign_s = [decodedArr objectAtIndex:8];
    CVETHTransaction *tx = [[CVETHTransaction alloc] init];
    tx.nonce = [[decodedArr objectAtIndex:0] dataDirectString];
    tx.gasPrice = [[decodedArr objectAtIndex:1] dataDirectString];
    tx.gasLimit = [[decodedArr objectAtIndex:2] dataDirectString];
    tx.to = [[decodedArr objectAtIndex:3] dataDirectString];
    tx.value = [[decodedArr objectAtIndex:4] dataDirectString];
    tx.data = [[decodedArr objectAtIndex:5] dataDirectString];
    
    NSDecimalNumber *tmpv = [NSDecimalNumber decimalNumberWithString:[[sign_v dataDirectString] decFromHex]];
    tmpv = [tmpv decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:@"35"]];
    
    NSData *recoverId = [[[NSNumberFormatter
                           localizedStringFromNumber: [tmpv decimalNumberByModBy:[NSDecimalNumber decimalNumberWithString:@"2"]]
                           numberStyle:NSNumberFormatterNoStyle] hexFromDec] parseHexData];
    
    tmpv = [tmpv decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"2"]];
    NSString *vStr = [NSNumberFormatter
                      localizedStringFromNumber:tmpv
                      numberStyle:NSNumberFormatterNoStyle];
    tx.v = vStr;
    [tx setTransactionChainID:vStr];
    
    NSData *txHashForSign = [tx hashForSign];
    NSMutableData *signOfTxHash = [[NSMutableData alloc] initWithData:sign_r];
    [signOfTxHash appendData:sign_s];
    [signOfTxHash appendData:recoverId];
    if (recoverId.length == 0) {
        unsigned char v = 0;
        [signOfTxHash appendBytes:&v length:sizeof(unsigned char)];
    }
    NSData *pubKey = [txHashForSign getPubKeyDataFromMessageWithSig:signOfTxHash];
    
    return [CVETHWallet getWalletAddressFromPublicKey:pubKey];
}
-(NSString *)hashMessage:(NSString *)_string
{
    NSString *message = [NSString stringWithFormat:@"%@%lu%@", HASH_MESSAGE_PREFIX, (unsigned long)_string.length, _string];
    return [[message keccak256HashString] addPrefix0x];
}
-(NSDictionary *)sign:(NSString *)_message WithPrivateKey:(NSString *)_privateKey
{
    NSString *hashMessage = [self hashMessage:_message];
    NSData *tempSignatureData = [[hashMessage parseHexData] signWithPrivateKeyData:[_privateKey parseHexData]];
    
    NSData *tmpv = [NSData dataWithBytes:&tempSignatureData.bytes[64] length:1];
    int value = *(int*)([tmpv bytes]);
    NSDecimalNumber *vNum = (NSDecimalNumber *)[NSDecimalNumber numberWithInt:value + 27];
    NSString *vStr = [NSNumberFormatter
                      localizedStringFromNumber:vNum
                      numberStyle:NSNumberFormatterNoStyle];
    vStr = [vStr hexFromDec];
    vStr = [vStr hexUp];
    vStr = [vStr hexTrim];
    
    NSString *rStr = [[NSData dataWithBytes:&tempSignatureData.bytes[0] length:32] dataDirectString];
    rStr = [rStr hexTrim];
    NSString *sStr = [[NSData dataWithBytes:&tempSignatureData.bytes[32] length:32] dataDirectString];
    sStr = [sStr hexTrim];
    
    NSString *signature = [NSString stringWithFormat:@"%@%@%@", rStr, sStr, vStr];
    return @{@"message":_message, @"messageHash":hashMessage, @"signature":[signature addPrefix0x], @"v":[vStr addPrefix0x], @"r":[rStr addPrefix0x], @"s":[sStr addPrefix0x]};
}
-(NSString *)recover:(NSString *)_message WithSignature:(NSString *)_signature
{
    NSString *hashMessage = [self hashMessage:_message];
    NSMutableData *sig = [[NSMutableData alloc] init];
    [sig appendBytes:[_signature parseHexData].bytes length:64];
    NSData *tmpv = [NSData dataWithBytes:&[_signature parseHexData].bytes[64] length:1];
    int value = *(int*)([tmpv bytes]);
    if (value >= 27) {
        value -= 27;
    }
    [sig appendBytes:&value length:sizeof(value)];
    
    NSData *pubKey = [[hashMessage parseHexData] getPubKeyDataFromMessageWithSig:sig];
    return [CVETHWallet getWalletAddressFromPublicKey:pubKey];
}
-(NSDictionary *)encrypt:(NSString *)_privateKey WithPassword:(NSString *)_password
{
    return [CVETHKeyStore encryptToKeyStoreWithPrivKey:[_privateKey removePrefix0x] Password:_password];
}
-(NSDictionary *)decrypt:(NSDictionary *)_jsonDic WithPassword:(NSString *)_password
{
    NSString *privKey = [[CVETHKeyStore decryptKeyStore:_jsonDic Password:_password] addPrefix0x];
    NSString *address = [self privateKeyToAccount:privKey];
    return @{@"address":address, @"privateKey":privKey};
}
@end
