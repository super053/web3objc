//
//  CVETHABIArgument.h
//  CVETHWallet
//
//  Created by coin on 06/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CVETHABIArgument : NSObject

+(NSString *)functionsSelectorHash:(NSString *)_function;
+(NSString *)argumentWithPadding:(NSString *)_arg;
+(NSString *)argumentWithRearPadding:(NSString *)_arg;
+(NSString *)argumentFromString:(NSString *)_stringArg;
+(NSString *)stringFromArgument:(NSString *)_resultArg;
@end

NS_ASSUME_NONNULL_END
