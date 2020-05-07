@import Foundation;

@interface NSData (RLP)

+ (NSData *)fromNSValue:(NSValue *)value;
// supported types: (u)int16_t, (u)int32_t, (u)int64_t
+ (NSData *)rlpFromNSValue:(NSValue *)value;

@end
