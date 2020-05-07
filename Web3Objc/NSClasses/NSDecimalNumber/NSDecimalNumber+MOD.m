//
//  NSDecimalNumber+MOD.m
//  CVETHWallet
//
//  Created by coin on 29/08/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import "NSDecimalNumber+MOD.h"

@implementation NSDecimalNumber (MOD)
-(NSDecimalNumber *)decimalNumberByModBy:(NSDecimalNumber *)decimalNumber
{
    NSDecimalNumber *divid = [self decimalNumberByDividingBy:decimalNumber withBehavior:[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO]];
    NSDecimalNumber *multiply = [divid decimalNumberByMultiplyingBy:decimalNumber];
    return [self decimalNumberBySubtracting:multiply];
}
- (BOOL)isLessThan:(NSDecimalNumber *)decimalNumber
{
    return [self compare:decimalNumber] == NSOrderedAscending;
}

- (BOOL)isLessThanOrEqualTo:(NSDecimalNumber *)decimalNumber
{
    return [self compare:decimalNumber] != NSOrderedDescending;
}

- (BOOL)isGreaterThan:(NSDecimalNumber *)decimalNumber
{
    return [self compare:decimalNumber] == NSOrderedDescending;
}

- (BOOL)isGreaterThanOrEqualTo:(NSDecimalNumber *)decimalNumber
{
    return [self compare:decimalNumber] != NSOrderedAscending;
}

- (BOOL)isEqualToDecimalNumber:(NSDecimalNumber *)decimalNumber
{
    return [self compare:decimalNumber] == NSOrderedSame;
}
@end
