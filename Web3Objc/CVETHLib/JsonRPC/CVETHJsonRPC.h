//
//  CVETHJsonRPC.h
//  CVETHWallet
//
//  Created by coin on 03/09/2019.
//  Copyright © 2019 coin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CVETHJsonRPC : NSObject
/*RPC*/
/* eth_getBalance -> result
 */
+(void)getBalanceAddress:(NSString *)_address UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion;
+(NSDictionary *)getBalanceAddress:(NSString *)_address;

/* eth_getTransactionCount -> result
 */
+(void)getTransactionCount:(NSString *)_address UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion;
+(NSDictionary *)getTransactionCount:(NSString *)_address;
/* eth_gasPrice -> result
 */
+(void)getGasPriceUseIndicator:(BOOL)_useIndocator Completion:(void (^)(NSDictionary *successResult))completion;
+(NSDictionary *)getGasPrice;

/* eth_estimateGas -> result
 */
+(void)estimateGasFrom:(NSString *)_fromAddress To:(NSString *)_toAddress GasPrice:(NSString *)_gasPrice Amount:(NSString *)_amount Data:(NSString *)_data UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion;
+(NSDictionary *)estimateGasFrom:(NSString *)_fromAddress To:(NSString *)_toAddress GasPrice:(NSString *)_gasPrice Amount:(NSString *)_amount Data:(NSString *)_data;

/* eth_sendRawTransaction -> result
 */
+(void)sendRawTransaction:(NSString *)_hash UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion;
+(NSDictionary *)sendRawTransaction:(NSString *)_hash;

/* eth_getTransactionByHash -> result.value
 */
+(void)getTransactionByHash:(NSString *)_txHash UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion;
+(NSDictionary *)getTransactionByHash:(NSString *)_txHash;

/* eth_getTransactionReceipt -> result.value
 */
+(void)getTransactionReceipt:(NSString *)_txHash UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion;
+(NSDictionary *)getTransactionReceipt:(NSString *)_txHash;

/* get erc20 token info
 * name, symbol, decimals, totalSupply
 */
+(void)getTokenInfo:(NSString *)_contractAddress UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *infoDic))completion;
+(NSDictionary *)getTokenInfo:(NSString *)_contractAddress;

+(void)getTokenDecimals:(NSString *)_contractAddress UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *infoDic))completion;
+(NSDictionary *)getTokenDecimals:(NSString *)_contractAddress;

/* get Balance erc20 token
 * _contract : token contract address
 * _address : wallet address
 */
+(void)getBalanceToken:(NSString *)_contract Address:(NSString *)_address UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion;
+(NSDictionary *)getBalanceToken:(NSString *)_contract Address:(NSString *)_address;

/*transfer erc20 token
 * _address : wallet address
 * _amount : token amount(hex wei)
 */
+(NSString *)transferDataStringAddress:(NSString *)_address Amount:(NSString *)_amount;


/* eth_call
 */
+(void)ethCallFrom:(NSString *)_fromAddress To:(NSString *)_toAddress Gas:(NSString *)_gas GasPrice:(NSString *)_gasPrice Value:(NSString *)_value Data:(NSString *)_data UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion;
+(NSDictionary *)ethCallFrom:(NSString *)_fromAddress To:(NSString *)_toAddress Gas:(NSString *)_gas GasPrice:(NSString *)_gasPrice Value:(NSString *)_value Data:(NSString *)_data;

/* JSONRPC
 */
//+(void)getJsonRPCData:(NSString *)_method WithParams:(NSArray *)_params UseIndicator:(BOOL)_useIndocator completion:(void (^)(NSDictionary *successResult))completion;
+(NSDictionary *)getJsonRPCData:(NSString *)_method WithParams:(NSArray *)_params;

@end

NS_ASSUME_NONNULL_END
