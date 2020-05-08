//
//  CVETHABIArgument.h
//  CVETHWallet
//
//  Created by coin on 06/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

//https://solidity.readthedocs.io/en/v0.5.3/abi-spec.html

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CVETHABIArgument : NSObject

/**
 encode to bytes
 */
+(NSString *)functionsSelectorHash:(NSString *)_function;
+(NSString *)argumentWithPadding:(NSString *)_arg;
+(NSString *)argumentWithRearPadding:(NSString *)_arg;

+(NSString *)fromUint:(NSString *)_uintArg M:(NSInteger)_m;
+(NSString *)fromInt:(NSString *)_intArg M:(NSInteger)_m;
+(NSString *)fromAddress:(NSString *)_addressArg;
+(NSString *)fromUint:(NSString *)_uintArg;
+(NSString *)fromInt:(NSString *)_intArg;
+(NSString *)fromBool:(NSString *)_boolArg;
+(NSString *)fromBytes:(NSString *)_bytesArg M:(NSInteger)_m;
+(NSString *)fromBytes:(NSString *)_bytesArg;
+(NSString *)fromString:(NSString *)_stringArg;


/**
 decode from bytes
 */
+(NSString *)toString:(NSString *)_resultArg;
@end

NS_ASSUME_NONNULL_END
