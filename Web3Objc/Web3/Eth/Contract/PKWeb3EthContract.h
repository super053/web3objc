//
//  PKWeb3EthContract.h
//  Web3Objc
//
//  Created by coin on 07/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKWeb3EthContract : NSObject

-(PKWeb3EthContract *)initWithAddress:(NSString *)_contractAddress;
-(NSDictionary *)call:(NSString *)_functionStr WithArgument:(NSDictionary *)_argument;

-(NSString *)encodeABI:(NSString *)_functionStr WithArgument:(NSDictionary *)_argument;
@end

NS_ASSUME_NONNULL_END
