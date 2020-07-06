//
//  AppDelegate.m
//  Web3Objc
//
//  Created by coin on 06/05/2020.
//  Copyright © 2020 coin. All rights reserved.
//

#import "AppDelegate.h"
#import "PKWeb3Objc.h"

#import "rlp.h"
#import "CVETHWallet.h"

#import "CVBTCWallet.h"

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
    
    NSDictionary *jsonDic1 = @{@"version":@3,@"id":@"3c84d05b-e61b-1e57-c31a-5b799c3b6b70",@"address":@"015150a221f36bcbe4f03a57ddf299eb62f70e96",@"crypto":@{@"ciphertext":@"481b094db20720af3598bc5599ebc11dc7fd42724c8696fc345ac756d33995d3",@"cipherparams":@{@"iv":@"253229c3adb4854373b043fa7a83c65d"},@"cipher":@"aes-128-ctr",@"kdf":@"pbkdf2",@"kdfparams":@{@"dklen":@32,@"salt":@"c7f17e5dea5e945e38a598f8b69626b6c3f01443b8bfffa9d6f27e258dcc9644",@"c":@10240,@"prf":@"hmac-sha256"},@"mac":@"05f47f48dc4a3c951cc6ce2ca0a99f9c7a57ee9492d525c8e21fb5fdf6ea81e7"},@"name":@"",@"meta":@"{}"};
    
    NSLog(@"decrypt : %@", [web3.eth.accounts decrypt:jsonDic1 WithPassword:@")CFs=6~8mMzCxuPHkE+<j5rYV5/:E7NE"]);
    
    /**test
     test var
     */
    NSString *testString = @"hello world";
    NSString *testPrivateKey = @"0x97e416370613ca532c97bd84e4cc1d9aeb5d1e8e22cd6b660df3fa5823acfc71";
    NSString *testAddress1 = @"0xB5DFe4836cFEA73f8e77656F8E7a649EcF29A2A3"; //testPrivateKey -> address
    NSString *testAddress2 = @"0xa11cb28a6066684db968075101031d3151dc40ed";
    
    /**test
     web3.crypto
     */
    NSData *testStringData = [testString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *privKeyData = [[testPrivateKey removePrefix0x] parseHexData];
    NSData *pubKeyData = [CVETHWallet _publicKeyFromPrivateKey:privKeyData];
    NSDictionary *encrypted = [web3.crypto encrypt:testStringData PubKey:pubKeyData];
    NSLog(@"encrypt : %@", encrypted);
    NSData *decrypted = [web3.crypto decrypt:encrypted PrivKey:privKeyData];
    NSLog(@"decrypt : %@", [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding]);
    
    NSData *testSig = [web3.crypto sign:testStringData PrivKey:privKeyData];
    NSLog(@"sign (r + s + v) : %@", [[testSig dataDirectString] addPrefix0x]);
    NSLog(@"verify : %@", [web3.crypto verify:testStringData Sig:testSig]);
    
    NSLog(@"mac : %@", [[encrypted valueForKey:@"mac"] dataDirectString]);
    NSLog(@"cipher : %@", [[encrypted valueForKey:@"cipher"] dataDirectString]);
    NSLog(@"iv : %@", [[encrypted valueForKey:@"iv"] dataDirectString]);
    NSLog(@"ephemPublicKey : %@", [[encrypted valueForKey:@"ephemPublicKey"] dataDirectString]);
    NSLog(@"private key : 97e416370613ca532c97bd84e4cc1d9aeb5d1e8e22cd6b660df3fa5823acfc71");
    
    NSDictionary *rndTestEnc = @{@"ephemPublicKey": [@"04523c5605e67fda732aff8df4d8b71ff4dab655fb0bd12c0dbdc3bca026a13dda5f6501ff4d6473cd75e434ef8148bbaf163c3e101eb39bc77eef482865c058e5" parseHexData],
    @"cipher" : [@"19b712e97c22d79bca2e69a8c251e47b" parseHexData],
    @"iv" : [@"aef8e7e64c6accdb8d068ea97241a2a6" parseHexData],
                              @"mac" : [@"d0b91b295ff761d943a1387750114fb09ca930f6d2307d309e377ed0aac4eebf" parseHexData] };
    NSString *rndTestPrivKey = @"8D9363B42BCA8CAE790294D0FD05C3B402DCE367EBA9CBB9373197BB66D4D9EE";
    NSLog(@"test dec : %@", [[NSString alloc] initWithData:[web3.crypto decrypt:rndTestEnc PrivKey:[rndTestPrivKey parseHexData]] encoding:NSUTF8StringEncoding]);
    /**test
    web3.utils
    */
    NSLog(@"randomHex 32 : %@", [web3.utils randomHex:32]);
    NSLog(@"sha3 : %@", [web3.utils sha3:@"hello world"]);
    NSLog(@"keccak256 : %@", [web3.utils keccak256:@"hello world"]);
    NSLog(@"toChecksumAddress : %@", [web3.utils toChecksumAddress:[testAddress1 lowercaseString]]);
    NSLog(@"checkAddressChecksum : %@", [web3.utils checkAddressChecksum:testAddress1] ? @"true" : @"false");
    NSLog(@"numberToHex : %@", [web3.utils numberToHex:@"1000"]);
    NSLog(@"hexToNumber : %@", [web3.utils hexToNumber:@"0x123"]);
    NSLog(@"utf8ToHex : %@", [web3.utils utf8ToHex:@"hello world"]);
    NSLog(@"hexToUtf8 : %@", [web3.utils hexToUtf8:@"0x68656c6c6f20776f726c64"]);
    NSLog(@"toWei : %@", [web3.utils toWei:@"10" WithUnit:@"ether"]);
    NSLog(@"fromWei : %@", [web3.utils fromWei:@"1000000" WithUnit:@"ether"]);
    
    /**test
     web3.eth.accounts*/
    NSLog(@"create : %@", [web3.eth.accounts create]);
    NSLog(@"privateKeyToAccount : %@", [web3.eth.accounts privateKeyToAccount:testPrivateKey]);
    
    CVETHTransaction *testTx = [[CVETHTransaction alloc] init];
    testTx.nonce = [web3.utils numberToHex:@"61"];
    testTx.gasPrice = [web3.utils numberToHex:@"2250000000"];
    testTx.gasLimit = [web3.utils numberToHex:@"21000"];
    testTx.to = [testAddress2 removePrefix0x];
    testTx.value = [web3.utils numberToHex:[web3.utils toWei:@"100" WithUnit:@"ether"]];
    NSDictionary *signTx = [web3.eth.accounts signTransaction:testTx WithPrivateKey:testPrivateKey];
    NSLog(@"signTransaction : %@", signTx);
    NSLog(@"signtx-recover : %@", [web3.eth.accounts recoverTransaction:[signTx valueForKey:@"rawTransaction"]]);
    NSLog(@"signtx-rlp decode : %@", rlp_decode([[signTx valueForKey:@"rawTransaction"] parseHexData]));
    
    NSString *testRawTx = @"0xf86c3d84861c468082520894a11cb28a6066684db968075101031d3151dc40ed89056bc75e2d631000008029a07670cffdc041a39174b917ae8ca4faadf3339d4ff27bc92df2b01e624cc0370ea032f201f955a9f852c5d288eac0e4bef1e70bb20b98088785854aeea26514d907";
    NSLog(@"recoverTransaction : %@", [web3.eth.accounts recoverTransaction:testRawTx]);
    NSLog(@"sign : %@", [web3.eth.accounts sign:@"hello world" WithPrivateKey:testPrivateKey]);
    NSLog(@"recover : %@", [web3.eth.accounts recover:@"hello world" WithSignature:@"0xcc1b5ae5b05e159d401271afe5d786babfe5456b32bf17d74479dfa9094564c457b3935bea2a88f0cfa387b8a2e923a6bafdefd44200f2461093481b71d6bdb81c"]);
    NSDictionary *encryptDic = [web3.eth.accounts encrypt:testPrivateKey WithPassword:@"test!"];
    NSLog(@"encrypt : %@", encryptDic);
    NSLog(@"encrypt to decrypt : %@", [web3.eth.accounts decrypt:encryptDic WithPassword:@"test!"]);
    
    NSDictionary *jsonDic = @{@"version":@3,@"id":@"a003acb8-076b-4f68-b4ff-3e5a7d9f33db",@"address":@"2c7536e3605d9c16a7a3d7b1898e529396a65c23",@"crypto":@{@"ciphertext":@"95e6242a314e5eb490c4a5819b43910ea921629e10b2769a660b2d8a31a2b757",@"cipherparams":@{@"iv":@"d53f6ddb5788a84a79744ec0fdaec26e"},@"cipher":@"aes-128-ctr",@"kdf":@"scrypt",@"kdfparams":@{@"dklen":@32,@"salt":@"44e6f5555f776f0fd795d9120780221a3dd656cb3434e2ceddb548d07ee0abf9",@"n":@8192,@"r":@8,@"p":@1},@"mac":@"840319587d58ade158c5a16459fb2d1b5d06fa299314ccbec46c0f0a9ac7006b"}};
    
    NSLog(@"decrypt : %@", [web3.eth.accounts decrypt:jsonDic WithPassword:@"test!"]);
    
    /**test
     web3.eth
     */
    NSLog(@"getGasPrice : %@", [web3.eth getGasPrice]);
    NSLog(@"getBlockNumber : %@", [web3.eth getBlockNumber]);
    NSLog(@"getBalance : %@", [web3.utils fromWei:[web3.eth getBalance:testAddress2] WithUnit:@"ether"]);
    NSLog(@"getTranactionCount : %@", [web3.eth getTranactionCount:testAddress2]);
    NSLog(@"sendSignedTransaction : %@", [web3.eth sendSignedTransaction:@"0xf86c3d84861c468082520894a11cb28a6066684db968075101031d3151dc40ed89056bc75e2d631000008029a07670cffdc041a39174b917ae8ca4faadf3339d4ff27bc92df2b01e624cc0370ea032f201f955a9f852c5d288eac0e4bef1e70bb20b98088785854aeea26514d907"]);
    NSLog(@"signedTransaction : %@", [web3.eth signedTransaction:testTx WithPrivateKey:testPrivateKey]);
    NSLog(@"call : %@", [web3.eth call:testTx]);
    NSLog(@"estimateGasFrom : %@", [web3.eth estimateGasFrom:testAddress2 TX:testTx]);
    NSLog(@"getChainId : %@", [web3.eth getChainId]);
    
    /**test
     web3.eth.contract
     */
    PKWeb3EthContract *testContract = [web3.eth.contract initWithAddress:@"0x4946C9c48A1cB906142B180aC7e5E003D3CDD14f" AbiJsonStr:@"[{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"address\"}],\"name\": \"holderLockBalance\",\"outputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [],\"name\": \"name\",\"outputs\": [{\"name\": \"\",\"type\": \"string\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [{\"name\": \"_spender\",\"type\": \"address\"},{\"name\": \"_value\",\"type\": \"uint256\"}],\"name\": \"approve\",\"outputs\": [{\"name\": \"\",\"type\": \"bool\"}],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"uint256\"},{\"name\": \"\",\"type\": \"uint256\"}],\"name\": \"roundPresaleHolderList\",\"outputs\": [{\"name\": \"\",\"type\": \"address\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"address\"}],\"name\": \"subOwner\",\"outputs\": [{\"name\": \"\",\"type\": \"bool\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"name\": \"presaleHolderList\",\"outputs\": [{\"name\": \"\",\"type\": \"address\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"name\": \"holderList\",\"outputs\": [{\"name\": \"\",\"type\": \"address\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [],\"name\": \"totalSupply\",\"outputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"address\"}],\"name\": \"isHolders\",\"outputs\": [{\"name\": \"\",\"type\": \"bool\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"name\": \"totalEthInWei\",\"outputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [],\"name\": \"fundsWallet\",\"outputs\": [{\"name\": \"\",\"type\": \"address\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [{\"name\": \"_from\",\"type\": \"address\"},{\"name\": \"_to\",\"type\": \"address\"},{\"name\": \"_value\",\"type\": \"uint256\"}],\"name\": \"transferFrom\",\"outputs\": [{\"name\": \"\",\"type\": \"bool\"}],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [],\"name\": \"decimals\",\"outputs\": [{\"name\": \"\",\"type\": \"uint8\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [{\"name\": \"_address\",\"type\": \"address\"}],\"name\": \"lockAddress\",\"outputs\": [],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [{\"name\": \"_presales\",\"type\": \"uint256\"}],\"name\": \"presaleHolderRelease\",\"outputs\": [],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [],\"name\": \"totalPresaleHolderCount\",\"outputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"address\"}],\"name\": \"presaleJoinCount\",\"outputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [],\"name\": \"totalHolderCount\",\"outputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [{\"name\": \"_spender\",\"type\": \"address\"},{\"name\": \"_subtractedValue\",\"type\": \"uint256\"}],\"name\": \"decreaseApproval\",\"outputs\": [{\"name\": \"\",\"type\": \"bool\"}],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"_owner\",\"type\": \"address\"}],\"name\": \"balanceOf\",\"outputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [{\"name\": \"_presales\",\"type\": \"uint256\"},{\"name\": \"_to\",\"type\": \"address\"},{\"name\": \"_amount\",\"type\": \"uint256\"},{\"name\": \"_presalesETH\",\"type\": \"uint256\"},{\"name\": \"_presalesBTH\",\"type\": \"uint256\"},{\"name\": \"_presalesCASH\",\"type\": \"uint256\"},{\"name\": \"_reason\",\"type\": \"string\"}],\"name\": \"manualPresales\",\"outputs\": [],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [],\"name\": \"lockStart\",\"outputs\": [],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"address\"}],\"name\": \"isLockHolders\",\"outputs\": [{\"name\": \"\",\"type\": \"bool\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [{\"name\": \"_presales\",\"type\": \"uint256\"}],\"name\": \"presaleHolderLock\",\"outputs\": [],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [],\"name\": \"symbol\",\"outputs\": [{\"name\": \"\",\"type\": \"string\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [],\"name\": \"lockStop\",\"outputs\": [],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"name\": \"totalCash\",\"outputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [{\"name\": \"_to\",\"type\": \"address\"},{\"name\": \"_value\",\"type\": \"uint256\"}],\"name\": \"transfer\",\"outputs\": [{\"name\": \"\",\"type\": \"bool\"}],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"name\": \"totalRoundPresaleHolderCount\",\"outputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [{\"name\": \"_address\",\"type\": \"address\"}],\"name\": \"releaseAddress\",\"outputs\": [],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"name\": \"presalesAmount\",\"outputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [],\"name\": \"locked\",\"outputs\": [{\"name\": \"\",\"type\": \"bool\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [{\"name\": \"_address\",\"type\": \"address\"},{\"name\": \"_lockAmount\",\"type\": \"uint256\"}],\"name\": \"setHolderLockBalance\",\"outputs\": [],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"address\"},{\"name\": \"\",\"type\": \"uint256\"}],\"name\": \"holderPresaleInfo\",\"outputs\": [{\"name\": \"presalesTime\",\"type\": \"uint256\"},{\"name\": \"presalesAmount\",\"type\": \"uint256\"},{\"name\": \"presalesETH\",\"type\": \"uint256\"},{\"name\": \"presalesBTC\",\"type\": \"uint256\"},{\"name\": \"presalesCASH\",\"type\": \"uint256\"},{\"name\": \"reason\",\"type\": \"string\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [{\"name\": \"_spender\",\"type\": \"address\"},{\"name\": \"_addedValue\",\"type\": \"uint256\"}],\"name\": \"increaseApproval\",\"outputs\": [{\"name\": \"\",\"type\": \"bool\"}],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"_owner\",\"type\": \"address\"},{\"name\": \"_spender\",\"type\": \"address\"}],\"name\": \"allowance\",\"outputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [{\"name\": \"_address\",\"type\": \"address\"}],\"name\": \"addSubOwner\",\"outputs\": [],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"constant\": true,\"inputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"name\": \"totalBtcInWei\",\"outputs\": [{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"},{\"constant\": false,\"inputs\": [{\"name\": \"_address\",\"type\": \"address\"}],\"name\": \"removeSubOwner\",\"outputs\": [],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"function\"},{\"inputs\": [],\"payable\": false,\"stateMutability\": \"nonpayable\",\"type\": \"constructor\"},{\"anonymous\": false,\"inputs\": [{\"indexed\": true,\"name\": \"from\",\"type\": \"address\"},{\"indexed\": true,\"name\": \"to\",\"type\": \"address\"},{\"indexed\": false,\"name\": \"value\",\"type\": \"uint256\"}],\"name\": \"Transfer\",\"type\": \"event\"},{\"anonymous\": false,\"inputs\": [{\"indexed\": true,\"name\": \"owner\",\"type\": \"address\"},{\"indexed\": true,\"name\": \"spender\",\"type\": \"address\"},{\"indexed\": false,\"name\": \"value\",\"type\": \"uint256\"}],\"name\": \"Approval\",\"type\": \"event\"}]"];
    NSLog(@"encodeABI : %@", [testContract encodeABI:@"holderPresaleInfo(address,uint256)" WithArgument:@[@"0x88dbbd9a4dcf2bf8e08ae451fd4ef25800a0e9bc",@"1"]]);
    NSLog(@"call : %@", [testContract call:@"holderPresaleInfo(address,uint256)" WithArgument:@[@"0x88dbbd9a4dcf2bf8e08ae451fd4ef25800a0e9bc",@"1"]]);
    
    /*btc wallet test*/
    NSLog(@"wif to : %@", [CVBTCWallet wifToPrivateKey:@"5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"]);
    NSLog(@"pri to : %@", [CVBTCWallet privateToWif:@"0C28FCA386C7A227600B2FE50B7CAE11EC86D3BF1FBE471BE89827E19D72AA1D"]);
    NSLog(@"isWIF : %@", [CVBTCWallet isWIF:@"5J3mBbAH58CpQ3Y5RNJpUKPE62SQ5tfcvU2JpbnkeyhfsYB1Jcn"] ? @"true" : @"false");
    NSLog(@"isWIFCompressed : %@", [CVBTCWallet isWIFCompressed:@"KxFC1jmwwCoACiCAWZ3eXa96mBM6tb3TYzGmf6YwgdGWZgawvrtJ"] ? @"true" : @"false");
    NSLog(@"getWalletAddress : %@", [CVBTCWallet getWalletAddress:@"0C28FCA386C7A227600B2FE50B7CAE11EC86D3BF1FBE471BE89827E19D72AA1D"]);
    
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
