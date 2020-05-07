@import Foundation;

#import "NSData+RLP.h"
// supported types: NSArray, NSData, NSString, NSValue
FOUNDATION_EXPORT NSData *rlp_encode(id data);
FOUNDATION_EXPORT id rlp_decode(NSData *data);
