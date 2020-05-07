//
//  NSDecimalNumber+MOD.h
//  CVETHWallet
//
//  Created by coin on 29/08/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDecimalNumber (MOD)

-(NSDecimalNumber *)decimalNumberByModBy:(NSDecimalNumber *)decimalNumber;

- (BOOL)isLessThan:(NSDecimalNumber *)decimalNumber;

- (BOOL)isLessThanOrEqualTo:(NSDecimalNumber *)decimalNumber;

- (BOOL)isGreaterThan:(NSDecimalNumber *)decimalNumber;

- (BOOL)isGreaterThanOrEqualTo:(NSDecimalNumber *)decimalNumber;

- (BOOL)isEqualToDecimalNumber:(NSDecimalNumber *)decimalNumber;
@end

NS_ASSUME_NONNULL_END
