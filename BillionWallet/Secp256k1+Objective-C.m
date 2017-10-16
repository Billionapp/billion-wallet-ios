//
//  Secp256k1+Objective-C.m
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Secp256k1+Objective-C.h"
#import "secp256k1/include/secp256k1.h"
#import "MACRO.h"

static secp256k1_context *context = NULL;
static dispatch_once_t once_token = 0;

@implementation Secp256k1

+ (BOOL) isPointInGroup:(UInt256)point {
    dispatch_once(&once_token, ^{ context = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY); });
    
    return secp256k1_ec_seckey_verify(context, (const unsigned char *)&point) == 1;
}

+ (UInt256) modAdd:(UInt256)a plus:(UInt256)b {
    dispatch_once(&once_token, ^{ context = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY); });
    
    if (secp256k1_ec_privkey_tweak_add(context, (unsigned char *)&a, (const unsigned char *)&b) == 0) {
        return UINT256_ZERO;
    }
    
    return a;
}

+ (UInt256)modMul:(UInt256) a mul:(UInt256) b {
    dispatch_once(&once_token, ^{ context = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY); });
    
    if (secp256k1_ec_privkey_tweak_mul(context, (unsigned char *)&a, (const unsigned char *)&b) == 0) {
        return UINT256_ZERO;
    }
    
    return a;
}

+ (ECPoint)pointGen:(UInt256) i {
    secp256k1_pubkey pubkey;
    ECPoint p;
    size_t pLen = sizeof(ECPoint);
    memset(&p, 0, sizeof(ECPoint));
    
    dispatch_once(&once_token, ^{ context = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY); });
    
    if ((secp256k1_ec_pubkey_create(context, &pubkey, (const unsigned char *)&i) &
         secp256k1_ec_pubkey_serialize(context, (unsigned char *)&p, &pLen, &pubkey, SECP256K1_EC_COMPRESSED)) != 1) {
        return p;
    }
    
    return p;
}

+ (ECPoint)pointAdd:(ECPoint) p plus:(UInt256) i {
    secp256k1_pubkey pubkey;
    size_t pLen = sizeof(p);
    
    dispatch_once(&once_token, ^{ context = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY); });
    
    if (secp256k1_ec_pubkey_parse(context, &pubkey, (const unsigned char *)&p, sizeof(p)) &
            secp256k1_ec_pubkey_tweak_add(context, &pubkey, (const unsigned char *)&i) &
        secp256k1_ec_pubkey_serialize(context, (unsigned char *)&p, &pLen, &pubkey, SECP256K1_EC_COMPRESSED) != 1) {
        return p;
    }
    
    return p;
}

+ (ECPoint)pointMul:(ECPoint) p mul:(UInt256) i {
    secp256k1_pubkey pubkey;
    size_t pLen = sizeof(p);
    
    dispatch_once(&once_token, ^{ context = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY); });
    if (secp256k1_ec_pubkey_parse(context, &pubkey, (const unsigned char *)&p, sizeof(p)) &
            secp256k1_ec_pubkey_tweak_mul(context, &pubkey, (const unsigned char *)&i) &
        secp256k1_ec_pubkey_serialize(context, (unsigned char *)&p, &pLen, &pubkey, SECP256K1_EC_COMPRESSED) != 1) {
        return p;
    }
    
    return p;
}

+ (NSData *)signData:(UInt256)data key:(UInt256)key {
    if (uint256_is_zero(key)) {
        return nil;
    }
    
    NSMutableData *sig = [NSMutableData dataWithLength:72];
    size_t len = sig.length;
    secp256k1_ecdsa_signature s;
    
    dispatch_once(&once_token, ^{ context = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY); });
    
    if (secp256k1_ecdsa_sign(context, &s, data.u8, key.u8, secp256k1_nonce_function_rfc6979, NULL) &&
        secp256k1_ecdsa_signature_serialize_der(context, sig.mutableBytes, &len, &s)) {
        sig.length = len;
    }
    else sig = nil;
    
    return sig;
}

+ (BOOL)verifySignature:(NSData *)sig forData:(UInt256)data withKey:(ECPoint)publicKey {
    secp256k1_pubkey pk;
    secp256k1_ecdsa_signature s;
    BOOL r = NO;
    
    dispatch_once(&once_token, ^{ context = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY); });
    
    if (secp256k1_ec_pubkey_parse(context, &pk, publicKey.p, 33) &&
        secp256k1_ecdsa_signature_parse_der(context, &s, sig.bytes, sig.length) &&
        secp256k1_ecdsa_verify(context, &s, data.u8, &pk) == 1) { // success is 1, all other values are fail
        r = YES;
    }
    
    return r;
}

@end
