//
//  NSMutableData+CVETH.h
//  CVETHWallet
//
//  Created by coin on 21/02/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
CFAllocatorRef SecureAllocator();

@interface NSMutableData (CVETH)
+ (NSMutableData *)secureDataWithCapacity:(NSUInteger)aNumItems;
@end

NS_ASSUME_NONNULL_END
