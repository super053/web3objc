//
//  PKWeb3Eth.m
//  Web3Objc
//
//  Created by coin on 07/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import "PKWeb3Eth.h"

@implementation PKWeb3Eth
-(id)init
{
    self = [super init];
    if (self) {
        self.contract = [[PKWeb3EthContract alloc] init];
        self.accounts = [[PKWeb3EthAccounts alloc] init];
    }
    return self;
}
@end
