//
//  PKWeb3Objc.m
//  Web3Objc
//
//  Created by coin on 07/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import "PKWeb3Objc.h"

@implementation PKWeb3Objc
+ (instancetype)sharedInstance {
    static PKWeb3Objc *shared = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PKWeb3Objc alloc] init];
    });

    return shared;
}
-(id)init
{
    self = [super init];
    if (self) {
        self.eth = [[PKWeb3Eth alloc] init];
        self.utils = [[PKWeb3Utils alloc] init];
    }
    return self;
}
-(BOOL)setEndPoint:(NSString *)_endpoint AndChainID:(NSString *)_chainId
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL retVal = false;
    @synchronized (userDefault) {
        [userDefault setObject:_endpoint forKey:@"endpoint"];
        [userDefault setObject:_chainId forKey:@"chainid"];
        retVal = [userDefault synchronize];
    }
    return retVal;
}
@end
