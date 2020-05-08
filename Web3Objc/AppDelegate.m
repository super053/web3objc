//
//  AppDelegate.m
//  Web3Objc
//
//  Created by coin on 06/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import "AppDelegate.h"
#import "PKWeb3Objc.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /**test
     web3 init
     */
    PKWeb3Objc *web3 = [PKWeb3Objc sharedInstance];
    [web3 setEndPoint:@"https://ropsten.infura.io/v3/a9ef185dce6344ef8b18af3606320420" AndChainID:@"3"];
    
    /**test
    web3.utils
    */
    NSLog(@"randomHex 32 : %@", [web3.utils randomHex:32]);
    NSLog(@"sha3 : %@", [web3.utils sha3:@"hello world"]);
    NSLog(@"keccak256 : %@", [web3.utils keccak256:@"hello world"]);
    NSLog(@"toChecksumAddress : %@", [web3.utils toChecksumAddress:[@"0xbef705eE6a72Cd35C2ED6b657dD4aC2c0AAB82b6" lowercaseString]]);
    NSLog(@"checkAddressChecksum : %@", [web3.utils checkAddressChecksum:@"0xbef705eE6a72Cd35C2ED6b657dD4aC2c0AAB82b6"] ? @"true" : @"false");
    NSLog(@"numberToHex : %@", [web3.utils numberToHex:@"1000"]);
    NSLog(@"hexToNumber : %@", [web3.utils hexToNumber:@"0x123"]);
    NSLog(@"utf8ToHex : %@", [web3.utils utf8ToHex:@"hello world"]);
    NSLog(@"hexToUtf8 : %@", [web3.utils hexToUtf8:@"0x68656c6c6f20776f726c64"]);
    NSLog(@"toWei : %@", [web3.utils toWei:@"10" WithUnit:@"ether"]);
    NSLog(@"fromWei : %@", [web3.utils fromWei:@"1000000" WithUnit:@"ether"]);
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
