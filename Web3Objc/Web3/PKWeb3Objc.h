//
//  PKWeb3Objc.h
//  Web3Objc
//
//  Created by coin on 07/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKWeb3Eth.h"
#import "PKWeb3Utils.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKWeb3Objc : NSObject

@property (nonatomic, retain) PKWeb3Eth *eth;
@property (nonatomic, retain) PKWeb3Utils *utils;

+ (PKWeb3Objc *)sharedInstance;
-(BOOL)setEndPoint:(NSString *)_endpoint AndChainID:(NSString *)_chainId;
@end

NS_ASSUME_NONNULL_END
