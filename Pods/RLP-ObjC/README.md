# rlp-objc
Objective-C implementation of [RLP](https://github.com/ethereum/wiki/wiki/RLP) (Recursive Length Prefix).

This implementation is faster than most other implementations because it only allocates one buffer per encode operation instead of recursively concatenating smaller buffers.

While encode can handle NSString and NSData, decode only returns NSData.
You must use ABI to interpet the types.
ABI support would be appreciated; please submit a pull request.

## Installation

```
pod 'RLP-ObjC'
```

## Usage

```
#import <rlp.h>

NSData *encoded = rlp_encode(@[ @"cat", @(0) ]);
NSArray *decoded = rlp_decode(encoded);
```

## Build with Makefile

- make: incrementally build the things

- make again: rebuild the things

- make clean: remove all build products

- make check: incrementally run the tests

- make distcheck: rerun all the tests
