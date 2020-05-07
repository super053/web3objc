//
//  CVWebAPI.m
//  bitcoinwallet
//
//  Created by coin on 2016. 2. 22..
//  Copyright © 2016년 coinvest. All rights reserved.
//

#import "CVWebAPI.h"
#import <objc/objc-sync.h>

@implementation CVWebAPI
+(NSData *)sendWebAPI:(NSString *)requestStr WithBody:(NSDictionary *)bodyDic WithImage:(UIImage *)image
{
    
    
    if (image != nil) {
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
            return nil;
        }
//        BOOL hasbody = bodyDic != nil ? YES : NO;
        NSMutableData *bodyData = [[NSMutableData alloc] init];
        NSData *imagedata = UIImageJPEGRepresentation(image, 0.6f);
#ifdef DEBUG
        NSLog(@"imagedata : %lu", imagedata.length);
        NSLog(@"width image body : %@", requestStr);
#endif
        
        /*multipart*/
        NSString *boundary = [NSString stringWithFormat:@"----WebKitFormBoundaryISYKjmtdekpPnD8b"];
        [bodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        for (int i=0;i<bodyDic.allKeys.count;i++) {
            NSString *key = [bodyDic.allKeys objectAtIndex:i];
            NSString *value = [bodyDic valueForKey:key];
            value = [value stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
            
            [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [bodyData appendData:[[NSString stringWithFormat:@"%@\r\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
        }

        [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"users.jpg\";\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[NSData dataWithData:imagedata]];
        [bodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        
        [bodyData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        

        NSData *httpbody = [NSData dataWithData:bodyData];
        
        
        NSMutableURLRequest *requestFriends = [[NSMutableURLRequest alloc] init];
        [requestFriends setURL:[NSURL URLWithString:requestStr]];
        [requestFriends setHTTPMethod:@"POST"];
        [requestFriends setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
        [requestFriends setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
        
        NSError *error = nil;

        NSData *retData = [self sendSynchronousRequest:requestFriends WithData:httpbody returningResponse:nil error:&error];

#ifdef DEBUG
        NSLog(@"%@ return data : %@", requestStr, [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding]);
#endif
        return retData;
        
    } else {
        return [self sendWebAPI:requestStr WithBody:bodyDic];
    }
}
+(NSData *)sendWebAPI:(NSString *)requestStr WithBody:(NSDictionary *)bodyDic
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        return nil;
    }
    BOOL hasbody = bodyDic != nil ? YES : NO;
    
#ifdef DEBUG
    NSLog(@"width body : %@", requestStr);
#endif
    NSString *aBody = @"";
    if (hasbody) {
        for (int i=0;i<bodyDic.allKeys.count;i++) {
            NSString *key = [bodyDic.allKeys objectAtIndex:i];
            NSString *value = [bodyDic valueForKey:key];
//            value = [value stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
            value = [value stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
            value = [value stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
            
            aBody = [aBody stringByAppendingString:[NSString stringWithFormat:@"%@=%@", key, value]];
            if (i < bodyDic.allKeys.count - 1) {
                aBody = [aBody stringByAppendingString:@"&"];
            }
        }
    }
    
    
    NSMutableURLRequest *requestFriends = [[NSMutableURLRequest alloc] init];
    [requestFriends setURL:[NSURL URLWithString:[[requestStr componentsSeparatedByString:@"?"] objectAtIndex:0]]];
    [requestFriends setHTTPMethod:@"POST"];
    [requestFriends setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    if (hasbody) {
        [requestFriends setHTTPBody:[aBody dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSError *error = nil;
    NSData *retData = [self sendSynchronousRequest:requestFriends returningResponse:nil error:&error];
#ifdef DEBUG
    NSLog(@"%@ return data : %@", requestStr, [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding]);
#endif
    return retData;
}
+(NSData *)sendWebAPI:(NSString *)requestStr
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"오류"
//                                                        message:@"API 서버에 연결 할 수 없습니다."
//                                                       delegate:self cancelButtonTitle:@"확인"
//                                              otherButtonTitles:nil];
//        [alert show];
        return nil;
    }
    BOOL hasbody = [[requestStr componentsSeparatedByString:@"?"] count] > 1 ? YES : NO;
#ifdef DEBUG
    NSLog(@"sendWebAPI : %@", requestStr);
#endif
    NSString *aBody;
    if (hasbody) {
        aBody = [[requestStr componentsSeparatedByString:@"?"] objectAtIndex:1];
    }
    
    if ([[requestStr componentsSeparatedByString:@"?"] count] > 2) {
        int i=2;
        while (i<[[requestStr componentsSeparatedByString:@"?"] count]) {
            aBody = [NSString stringWithFormat:@"%@?%@", aBody, [[requestStr componentsSeparatedByString:@"?"] objectAtIndex:i++]];
        }
    }
//    aBody = [aBody stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    
    
    
    NSMutableURLRequest *requestFriends = [[NSMutableURLRequest alloc] init];
    [requestFriends setURL:[NSURL URLWithString:[[requestStr componentsSeparatedByString:@"?"] objectAtIndex:0]]];
    [requestFriends setHTTPMethod:@"POST"];
    [requestFriends setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    if (hasbody) {
        [requestFriends setHTTPBody:[aBody dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSError *error = nil;
    NSData *retData = [self sendSynchronousRequest:requestFriends returningResponse:nil error:&error];
    
#ifdef DEBUG
    NSLog(@"%@ return data : %@", requestStr, [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding]);
#endif
    return retData;
    
    
    
}

/*미사용*/
+(NSData *)sendJSONRPC:(NSString *)_endPoint WithBody:(NSDictionary *)bodyDic
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        return nil;
    }
    BOOL hasbody = bodyDic != nil ? YES : NO;
    

    NSString *aBody = @"{";
    if (hasbody) {
        for (int i=0;i<bodyDic.allKeys.count;i++) {
            NSString *key = [bodyDic.allKeys objectAtIndex:i];
            NSString *value = [bodyDic valueForKey:key];
            if ([value isKindOfClass:[NSString class]] && ([value hasPrefix:@"["] || [value hasPrefix:@"{"])) {
                aBody = [aBody stringByAppendingString:[NSString stringWithFormat:@"\"%@\":%@", key, value]];
            } else {
                aBody = [aBody stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\"", key, value]];
            }
            
            if (i < bodyDic.allKeys.count - 1) {
                aBody = [aBody stringByAppendingString:@","];
            }
        }
    }
    aBody = [aBody stringByAppendingString:@"}"];
    
    NSMutableURLRequest *requestFriends = [[NSMutableURLRequest alloc] init];
    [requestFriends setURL:[NSURL URLWithString:_endPoint]];
    [requestFriends setHTTPMethod:@"POST"];
    [requestFriends setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (hasbody) {
        [requestFriends setHTTPBody:[aBody dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSError *error = nil;
    NSData *retData = [self sendSynchronousRequest:requestFriends returningResponse:nil error:&error];
#ifdef DEBUG
    NSLog(@"%@ return data : %@", _endPoint, [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding]);
#endif
    return retData;
}

/*사용*/
+(NSData *)sendJSONRPC:(NSString *)_endPoint WithBodyStr:(NSString *)bodyStr
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        return nil;
    }
    BOOL hasbody = ![bodyStr isEqualToString:@""];
    
    
    
    NSMutableURLRequest *requestFriends = [[NSMutableURLRequest alloc] init];
    [requestFriends setURL:[NSURL URLWithString:_endPoint]];
    [requestFriends setHTTPMethod:@"POST"];
    [requestFriends setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (hasbody) {
        [requestFriends setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSError *error = nil;
    NSData *retData = [self sendSynchronousRequest:requestFriends returningResponse:nil error:&error];
#ifdef DEBUG
//    NSLog(@"%@ return data : %@", _endPoint, [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding]);
#endif
    return retData;
}
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                             error:(__autoreleasing NSError **)errorPtr {
    dispatch_semaphore_t    sem;
    __block NSData *        result;
    
    result = nil;
    
    sem = dispatch_semaphore_create(0);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         if (errorPtr != NULL) {
                                             *errorPtr = error;
                                         }
                                         if (responsePtr != NULL) {
                                             *responsePtr = response;
                                         }
                                         if (error == nil) {
                                             result = data;
                                         }
                                         dispatch_semaphore_signal(sem);
                                     }] resume];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    return result;
}
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request WithData:(NSData *)data
                 returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                             error:(__autoreleasing NSError **)errorPtr {
    dispatch_semaphore_t    sem;
    __block NSData *        result;
    
    result = nil;
    
    sem = dispatch_semaphore_create(0);
    
//    [[[NSURLSession sharedSession] dataTaskWithRequest:request
//                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                         if (errorPtr != NULL) {
//                                             *errorPtr = error;
//                                         }
//                                         if (responsePtr != NULL) {
//                                             *responsePtr = response;
//                                         }
//                                         if (error == nil) {
//                                             result = data;
//                                         }
//                                         dispatch_semaphore_signal(sem);
//                                     }] resume];
    [[[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:data
                                      completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                          if (errorPtr != NULL) {
                                              *errorPtr = error;
                                          }
                                          if (responsePtr != NULL) {
                                              *responsePtr = response;
                                          }
                                          if (error == nil) {
                                              result = data;
                                          }
                                          dispatch_semaphore_signal(sem);
        
                                      }] resume];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    return result;
}
@end
