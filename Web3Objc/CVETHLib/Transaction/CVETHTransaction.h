//
//  CVETHTransaction.h
//  CVETHWallet
//
//  Created by coin on 03/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CVETHTransaction : NSObject
{
    NSString *chainID;
    NSData *signature;
}
@property (nonatomic, retain) NSString *nonce;
@property (nonatomic, retain) NSString *gasPrice;
@property (nonatomic, retain) NSString *gasLimit;
@property (nonatomic, retain) NSString *to;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSString *data;
@property (nonatomic, retain) NSString *goversnance;
@property (nonatomic, retain) NSString *v;
@property (nonatomic, retain) NSString *r;
@property (nonatomic, retain) NSString *s;

-(NSString *)getSignTX:(NSString *)_privKey;
-(void)setTransactionChainID:(NSString *)_chainID;




/*1. init Transaction require: nonce(eth_getTransactionCount), gasPrice(input), gasLimit(eth_estimateGas), to(address), value(amount), v(chainID)*/
-(NSArray *)transactionForSign;

/*2. create hash for sign
 * encodeData = rlp_encode(txArr) -> hash = keccak_256(encodeData)
 */
-(NSData *)hashForSign;

/*3. get signature
 * NSData+SECP256K1 : signWithPrivateKeyData
 * require signature = [hash signWithPrivateKeyData:"privKey"]
 */

/*4. (require signature) get v, r, s from signature
 * v : signature check byte(0 or 1) + 35 + chainID + chainID
 * r : signature half of all bytes front
 * s : signature half of all bytes rear
 */
-(NSData *)getSignedV;
-(NSData *)getSignedR;
-(NSData *)getSignedS;

/*5. get signed transaction array
 */
-(NSArray *)transactionForRaw;

/*6. rlp_encode(signed transaction array)
 * raw = "0x" + [encodedDataTxWithSignature dataDirectString]
 */
-(NSData *)encodedDataTxWithSignature;
@end

NS_ASSUME_NONNULL_END
