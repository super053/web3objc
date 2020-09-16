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
{
    NSDictionary *abiDic;
    NSString *contractAddress;
}
-(id)initWithAddress:(NSString *)_contractAddress AbiJsonStr:(NSString *)_abistr;
-(id)initWithAddress:(NSString *)_contractAddress Abi:(NSArray *)_abi;
-(id)call:(NSString *)_functionStr WithArgument:(NSArray *)_arguments;

-(id)getDecodeData:(NSString *)result WithOutput:(NSArray *)outputArr;

-(NSString *)encodeABI:(NSString *)_functionStr WithArgument:(NSArray *)_arguments;
@end

NS_ASSUME_NONNULL_END
