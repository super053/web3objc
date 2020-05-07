//
//  CVETHTransaction.m
//  CVETHWallet
//
//  Created by coin on 03/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import "CVETHTransaction.h"
#import "NSString+CVETH.h"
#import "rlp.h"
#import "NSData+SECP256K1.h"
#import "NSData+CVETH.h"
#import "TrezorCrypto.h"

@implementation CVETHTransaction
-(id)init {
    self = [super init];
    if (self) {
        self.nonce = @"";
        self.gasPrice = @"";
        self.gasLimit = @"";
        self.to = @"";
        self.value = @"";
        self.data = @"";
        
        chainID = [[NSUserDefaults standardUserDefaults] objectForKey:@"chainid"];
        if (chainID == nil || [chainID isEqualToString:@""]) {
            NSLog(@"chainID : not set chainID. please set chainID Web3.");
            return nil;
        }
        
        NSString *chainIDHexStr = [[chainID hexFromDec] removePrefix0x];
        self.v = [chainIDHexStr hexUp];
        
        self.r = @"";
        self.s = @"";
        signature = nil;
    }
    return self;
}
-(NSString *)getSignTX:(NSString *)_privKey
{
    signature = [[self hashForSign] signWithPrivateKeyData:[_privKey parseHexData]];
    NSData *encoded = [self encodedDataTxWithSignature];
    NSLog(@"%@", rlp_decode(encoded));
    return [NSString stringWithFormat:@"0x%@", [encoded dataDirectString]];
}
/*1. init Transaction require: nonce(eth_getTransactionCount), gasPrice(input), gasLimit(eth_estimateGas), to(address), value(amount), v(chainID)*/
-(NSArray *)transactionForSign
{
    //nonce, gasPrice, gasLimit, to, value(amount), data, v(chainID), r, s
    return @[[self.nonce parseHexData], [self.gasPrice parseHexData], [self.gasLimit parseHexData], [self.to parseHexData], [self.value parseHexData], [self.data parseHexData], [self.v parseHexData], [self.r parseHexData], [self.s parseHexData]];
}

/*2. create hash for sign
 * encodeData = rlp_encode(txArr) -> hash = keccak_256(encodeData)
 */
-(NSData *)hashForSign
{
    NSData *encodedData = rlp_encode([self transactionForSign]);
//    uint8_t *digest = malloc(sizeof(uint8_t) * 32);
//    keccak_256(encodedData.bytes, encodedData.length, digest);
//    NSData *hash = [NSData dataWithBytes:digest length:32];
//    return hash;
    return [encodedData keccak256];
}

/*3. get signature
 * NSData+SECP256K1 : signWithPrivateKeyData
 * require setSignature([hash signWithPrivateKeyData:"privKey"])
 */

/*4. (require signature) get v, r, s from signature
 * v : signature check byte(0 or 1) + 35 + chainID + chainID
 * r : signature half of all bytes front
 * s : signature half of all bytes rear
 */
-(NSData *)getSignedV
{
    if (!signature) {
        return nil;
    }
    
    NSData *tmpv = [NSData dataWithBytes:&signature.bytes[64] length:1];
    //    int value = *(int*)([tmpv bytes]) + 35 + (1 * 2);
    int value = *(int*)([tmpv bytes]);
    NSDecimalNumber *vNum = (NSDecimalNumber *)[NSDecimalNumber numberWithInt:value];
    NSDecimalNumber *adding = [NSDecimalNumber decimalNumberWithString:chainID];
    adding = [adding decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"2"]];
    adding = [adding decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:@"35"]];
    vNum = [vNum decimalNumberByAdding:adding];
    NSString *vStr = [NSNumberFormatter
                      localizedStringFromNumber:vNum
                      numberStyle:NSNumberFormatterNoStyle];
    
    vStr = [vStr hexFromDec];
    vStr = [vStr hexUp];
    vStr = [vStr hexTrim];
    return [vStr parseHexData];
}
-(NSData *)getSignedR
{
    if (!signature) {
        return nil;
    }
    NSString *rStr = [[NSData dataWithBytes:&signature.bytes[0] length:32] dataDirectString];
    rStr = [rStr hexTrim];
    return [rStr parseHexData];
}
-(NSData *)getSignedS
{
    if (!signature) {
        return nil;
    }
//    return [NSData dataWithBytes:&signature.bytes[32] length:32];
    NSString *sStr = [[NSData dataWithBytes:&signature.bytes[32] length:32] dataDirectString];
    sStr = [sStr hexTrim];
    return [sStr parseHexData];
}

/*5. get signed transaction array
 */
-(NSArray *)transactionForRaw
{
    if (!signature) {
        return nil;
    }
    return @[[self.nonce parseHexData], [self.gasPrice parseHexData], [self.gasLimit parseHexData], [self.to parseHexData], [self.value parseHexData], [self.data parseHexData], [self getSignedV], [self getSignedR], [self getSignedS]];
}

/*6. rlp_encode(signed transaction array)
 */
-(NSData *)encodedDataTxWithSignature
{
    if (!signature) {
        return nil;
    }
    return rlp_encode([self transactionForRaw]);
}
@end
