//
//  CVWebAPI.h
//  bitcoinwallet
//
//  Created by coin on 2016. 2. 22..
//  Copyright © 2016년 coinvest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import <UIKit/UIKit.h>
@interface CVWebAPI : NSObject <NSURLSessionDelegate>

+(NSData *)sendWebAPI:(NSString *)requestStr;
+(NSData *)sendWebAPI:(NSString *)requestStr WithBody:(NSDictionary *)bodyDic;
+(NSData *)sendWebAPI:(NSString *)requestStr WithBody:(NSDictionary *)bodyDic WithImage:(UIImage *)image;

/*미사용*/
+(NSData *)sendJSONRPC:(NSString *)_endPoint WithBody:(NSDictionary *)bodyDic;

/*사용*/
+(NSData *)sendJSONRPC:(NSString *)_endPoint WithBodyStr:(NSString *)bodyStr;
@end
