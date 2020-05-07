//
//  NSData+CVETH.h
//  CVETHWallet
//
//  Created by coin on 03/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (CVETH)
-(NSString *)dataDirectString;
-(NSData *)keccak256;
-(NSData *)sha256;
-(NSString *)base58;
@end

NS_ASSUME_NONNULL_END
