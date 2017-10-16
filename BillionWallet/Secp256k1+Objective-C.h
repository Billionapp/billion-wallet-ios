//
//  Secp256k1+Objective-C.h
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

#import "NSData+Bitcoin.h"

typedef struct {
    uint8_t p[33];
} ECPoint;

@interface Secp256k1 : NSObject

+ (BOOL) isPointInGroup:(UInt256)a;

// adds 256bit big endian ints a and b (mod secp256k1 order)
+ (UInt256)modAdd:(UInt256)a plus:(UInt256)b;

+ (UInt256)modMul:(UInt256)a mul:(UInt256)b;
+ (ECPoint)pointGen:(UInt256)i;
+ (ECPoint)pointAdd:(ECPoint)p plus:(UInt256)i;
+ (ECPoint)pointMul:(ECPoint)p mul:(UInt256)i;

+ (NSData *)signData:(UInt256)data key:(UInt256)key;
+ (BOOL)verifySignature:(NSData *)sig forData:(UInt256)data withKey:(ECPoint)publicKey;

@end
