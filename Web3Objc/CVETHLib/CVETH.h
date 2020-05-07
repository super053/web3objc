//
//  CVETH.h
//  CVETHWallet
//
//  Created by coin on 27/08/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CVETHABIArgument.h"
#import "CVETHTransaction.h"
#import "CVETHJsonRPC.h"
#import "CVETHWallet.h"
#import "CVETHKeyStore.h"

#import "NSDecimalNumber+MOD.h"

#import "NSData+CVETH.h"
#import "NSData+SECP256K1.h"

#import "NSMutableData+CVETH.h"

#import "NSString+CVETH.h"

#import "NSObject+CVETH.h"



NS_ASSUME_NONNULL_BEGIN

@interface CVETH : NSObject



+(NSString *)ethFromHexWei:(NSString *)_hexWei;
+(NSString *)weiFromHexWei:(NSString *)_hexWei;
+(NSString *)gweiFromHexWei:(NSString *)_hexWei;
+(NSString *)tokenFromHexWei:(NSString *)_hexWei Decimals:(int)_decimals;
+(NSString *)weiFromGas:(NSString *)_gwei;
+(NSString *)hexWeiFromGwei:(NSString *)_gwei;
+(NSString *)hexWeiFromWei:(NSString *)_wei;
+(NSString *)hexWeiFromEth:(NSString *)_eth;
+(NSString *)hexWeiFromToken:(NSString *)_token Decimals:(int)_decimals;
//+ (NSData *) hashPersonalMessage:(NSData *)message;
+(NSString *)decimalpadding:(NSString *)_rearDecimalPoint Decimals:(int)_decimals;
@end

NS_ASSUME_NONNULL_END
