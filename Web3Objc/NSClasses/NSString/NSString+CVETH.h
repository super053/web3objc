//
//  NSString+CVETH.h
//  CVETHWallet
//
//  Created by coin on 03/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CVETH)
- (NSData *)  parseHexData;
-(NSString *)decFromHex;
-(NSString *)hexFromDec;
-(NSDecimalNumber *)decimalNumberFromHexStr;
-(NSString *)hexUp;
-(NSString *)hexTrim;
-(NSString *)removePrefix0x;
-(NSString *)addPrefix0x;
-(NSString *)keccak256HashString;
- (BOOL) isAllDigits;
-(NSString *)trim;
-(NSData *)base58ToData;
@end

NS_ASSUME_NONNULL_END
