//
//  NSObject+CVETH.m
//  CVETHWallet
//
//  Created by coin on 26/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import "NSObject+CVETH.h"

@implementation NSObject (CVETH)
-(BOOL)nullCheck
{
    return (self && ![self isKindOfClass:[NSNull class]]);
}
@end
