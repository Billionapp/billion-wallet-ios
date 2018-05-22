//
//  BIP44Sequence.m
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

#import "BIP44Sequence.h"
#import "BRKey.h"
#import "NSString+Bitcoin.h"
#import "NSData+Bitcoin.h"
#import "NSMutableData+Bitcoin.h"

#define BIP32_SEED_KEY "Bitcoin seed"
#define BIP32_XPRV     "\x04\x88\xAD\xE4"
#define BIP32_XPUB     "\x04\x88\xB2\x1E"

// BIP44 is a hierarchy for deterministic wallets
// BIP32 is a scheme for deriving chains of addresses from a seed value
// https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
// https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki

// Private parent key -> private child key
//
// CKDpriv((kpar, cpar), i) -> (ki, ci) computes a child extended private key from the parent extended private key:
//
// - Check whether i >= 2^31 (whether the child is a hardened key).
//     - If so (hardened child): let I = HMAC-SHA512(Key = cpar, Data = 0x00 || ser256(kpar) || ser32(i)).
//       (Note: The 0x00 pads the private key to make it 33 bytes long.)
//     - If not (normal child): let I = HMAC-SHA512(Key = cpar, Data = serP(point(kpar)) || ser32(i)).
// - Split I into two 32-byte sequences, IL and IR.
// - The returned child key ki is parse256(IL) + kpar (mod n).
// - The returned chain code ci is IR.
// - In case parse256(IL) >= n or ki = 0, the resulting key is invalid, and one should proceed with the next value for i
//   (Note: this has probability lower than 1 in 2^127.)
//
static void CKDpriv(UInt256 *k, UInt256 *c, uint32_t i)
{
    uint8_t buf[sizeof(BRECPoint) + sizeof(i)];
    UInt512 I;
    
    if (i & BIP32_HARD) {
        buf[0] = 0;
        *(UInt256 *)&buf[1] = *k;
    }
    else BRSecp256k1PointGen((BRECPoint *)buf, k);
    
    *(uint32_t *)&buf[sizeof(BRECPoint)] = CFSwapInt32HostToBig(i);
    
    HMAC(&I, SHA512, sizeof(UInt512), c, sizeof(*c), buf, sizeof(buf)); // I = HMAC-SHA512(c, k|P(k) || i)
    
    BRSecp256k1ModAdd(k, (UInt256 *)&I); // k = IL + k (mod n)
    *c = *(UInt256 *)&I.u8[sizeof(UInt256)]; // c = IR
    
    memset(buf, 0, sizeof(buf));
    memset(&I, 0, sizeof(I));
}

// Public parent key -> public child key
//
// CKDpub((Kpar, cpar), i) -> (Ki, ci) computes a child extended public key from the parent extended public key.
// It is only defined for non-hardened child keys.
//
// - Check whether i >= 2^31 (whether the child is a hardened key).
//     - If so (hardened child): return failure
//     - If not (normal child): let I = HMAC-SHA512(Key = cpar, Data = serP(Kpar) || ser32(i)).
// - Split I into two 32-byte sequences, IL and IR.
// - The returned child key Ki is point(parse256(IL)) + Kpar.
// - The returned chain code ci is IR.
// - In case parse256(IL) >= n or Ki is the point at infinity, the resulting key is invalid, and one should proceed with
//   the next value for i.
//
static void CKDpub(BRECPoint *K, UInt256 *c, uint32_t i)
{
    if (i & BIP32_HARD) return; // can't derive private child key from public parent key
    
    uint8_t buf[sizeof(*K) + sizeof(i)];
    UInt512 I;
    
    *(BRECPoint *)buf = *K;
    *(uint32_t *)&buf[sizeof(*K)] = CFSwapInt32HostToBig(i);
    
    HMAC(&I, SHA512, sizeof(UInt512), c, sizeof(*c), buf, sizeof(buf)); // I = HMAC-SHA512(c, P(K) || i)
    
    *c = *(UInt256 *)&I.u8[sizeof(UInt256)]; // c = IR
    BRSecp256k1PointAdd(K, (UInt256 *)&I); // K = P(IL) + K
    
    memset(buf, 0, sizeof(buf));
    memset(&I, 0, sizeof(I));
}

@implementation BIP44Sequence

// MARK: - BRKeySequence

/**
 Derives Master public key for generating wallet addresses (BIP44 derivation path)
 Master public key format is: 4 byte parent fingerprint || 32 byte chain code || 33 byte compressed public key

 @param seed Mnemonic seed (BIP39 generated for example)
 @return Master public key
 */
- (NSData * _Nonnull)masterPublicKeyFromSeed:(NSData * _Nonnull)seed
{
    uint32_t acc_num = 0;
    
    if (! seed) return nil;
    
    NSMutableData *mpk = [NSMutableData secureData];
    UInt512 I;
    
    HMAC(&I, SHA512, sizeof(UInt512), BIP32_SEED_KEY, strlen(BIP32_SEED_KEY), seed.bytes, seed.length);
    
    UInt256 secret = *(UInt256 *)&I, chain = *(UInt256 *)&I.u8[sizeof(UInt256)];
    
    [mpk appendBytes:[BRKey keyWithSecret:secret compressed:YES].hash160.u32 length:4];
    
    uint32_t coin = 0; // Bitcoin Main
#if BITCOIN_TESTNET
    coin = 1; // Bitcoin Testnet
#endif
    
    CKDpriv(&secret, &chain, 44 | BIP32_HARD); // m/44'
    CKDpriv(&secret, &chain, coin | BIP32_HARD); // m/44'/coin'
    CKDpriv(&secret, &chain, acc_num | BIP32_HARD); // m/44'/coin'/acc_num'
    
    
    [mpk appendBytes:&chain length:sizeof(chain)];
    [mpk appendData:[BRKey keyWithSecret:secret compressed:YES].publicKey];
    
    return mpk;
}

/**
 Derive n-th public key for internal/external chain from master public key

 @param n Public key index
 @param internal false for public chain, true otherwize
 @param masterPublicKey Master public key
 @return Derived public key as ECPoint packed in NSData
 */
- (NSData * _Nullable)publicKey:(uint32_t)n internal:(BOOL)internal masterPublicKey:(NSData * _Nonnull)masterPublicKey
{
    if (masterPublicKey.length < 4 + sizeof(UInt256) + sizeof(BRECPoint)) return nil;
    
    UInt256 chain = *(const UInt256 *)((const uint8_t *)masterPublicKey.bytes + 4);
    BRECPoint pubKey = *(const BRECPoint *)((const uint8_t *)masterPublicKey.bytes + 36);
    
    CKDpub(&pubKey, &chain, internal ? 1 : 0); // internal or external chain
    CKDpub(&pubKey, &chain, n); // nth key in chain
    
    return [NSData dataWithBytes:&pubKey length:sizeof(pubKey)];
}

/**
 Calculate n-th private key from seed for account 0
 
 @param n Private key index
 @param internal false for public chain, true otherwize
 @param seed Menmonic seed (BIP39 generated for example)
 @return Private key in WIF format
 */
- (NSString * _Nonnull)privateKey:(uint32_t)n internal:(BOOL)internal fromSeed:(NSData * _Nonnull)seed
{
    return seed ? [self privateKeys:@[@(n)] internal:internal fromSeed:seed].lastObject : nil;
}

/**
 Calculate n-th private keys from seed for account 0

 @param n Private key index array
 @param internal false for public chain, true otherwize
 @param seed Menmonic seed (BIP39 generated for example)
 @return Private keys in WIF format
 */
- (NSArray<NSString *> * _Nonnull)privateKeys:(NSArray<NSNumber *> *)n internal:(BOOL)internal fromSeed:(NSData * _Nonnull)seed
{
    uint32_t acc_num = 0;
    
    if (! seed || ! n) return nil;
    if (n.count == 0) return @[];
    
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:n.count];
    UInt512 I;
    
    HMAC(&I, SHA512, sizeof(UInt512), BIP32_SEED_KEY, strlen(BIP32_SEED_KEY), seed.bytes, seed.length);
    
    UInt256 secret = *(UInt256 *)&I, chain = *(UInt256 *)&I.u8[sizeof(UInt256)];
    uint8_t version = BITCOIN_PRIVKEY;
    
    uint32_t coin = 0; // Bitcoin Main
#if BITCOIN_TESTNET
    version = BITCOIN_PRIVKEY_TEST;
    coin = 1; // Bitcoin Testnet
#endif
    
    CKDpriv(&secret, &chain, 44 | BIP32_HARD); // m/44'
    CKDpriv(&secret, &chain, coin | BIP32_HARD); // m/44'/coin'
    CKDpriv(&secret, &chain, acc_num | BIP32_HARD); // m/44'/coin'/acc_num'
    CKDpriv(&secret, &chain, internal ? 1 : 0); // internal or external chain
    
    for (NSNumber *i in n) {
        NSMutableData *privKey = [NSMutableData secureDataWithCapacity:34];
        UInt256 s = secret, c = chain;
        
        CKDpriv(&s, &c, i.unsignedIntValue); // nth key in chain
        
        [privKey appendBytes:&version length:1];
        [privKey appendBytes:&s length:sizeof(s)];
        [privKey appendBytes:"\x01" length:1]; // specifies compressed pubkey format
        [a addObject:[NSString base58checkWithData:privKey]];
    }
    
    return a;
}

/**
 Calculates payment code xPriv key for specific account following BIP47 derivation path

 @param account Account number
 @param seed Mnemonic seed (BIP39 generated for example)
 @return Payment code xPriv packed in NSData
 */
- (NSData * _Nonnull)paymentCodePrivateKeyForAccount:(uint32_t)account fromSeed:(NSData * _Nonnull)seed
{
    if (! seed) return nil;
    
    NSMutableData *pcpk = [NSMutableData secureData];
    UInt512 I;
    
    HMAC(&I, SHA512, sizeof(UInt512), BIP32_SEED_KEY, strlen(BIP32_SEED_KEY), seed.bytes, seed.length);
    
    UInt256 secret = *(UInt256 *)&I, chain = *(UInt256 *)&I.u8[sizeof(UInt256)];
    
    uint32_t coin = 0;  // Bitcoin derivation path only
    
    CKDpriv(&secret, &chain, 47 | BIP32_HARD); // m/47H
    CKDpriv(&secret, &chain, coin | BIP32_HARD); // Bitcoin Main/Test m/47H/0H
    
    CKDpriv(&secret, &chain, account | BIP32_HARD); // m/47H/coinH/accountH
    
    [pcpk appendBytes:&secret length:sizeof(secret)];
    [pcpk appendBytes:&chain length:sizeof(chain)]; // xPriv
    
    return pcpk;
}

/**
 Calculates payment code xPub key for specific account following BIP47 derivation path

 @param account Account number
 @param seed Mnemonic seed (BIP39 generated for example)
 @return Payment code xPub packed in NSData
 */
- (NSData * _Nonnull)paymentCodeForAccount:(uint32_t)account fromSeed:(NSData * _Nonnull)seed
{
    NSMutableData *pc = [NSMutableData secureData];
    
    NSData* xPrivate = [self paymentCodePrivateKeyForAccount:account fromSeed:seed];
    UInt256 secret = *(UInt256 *)xPrivate.bytes;
    UInt256 chain = *(UInt256 *)(xPrivate.bytes+sizeof(UInt256));
    BRECPoint p;
    BRSecp256k1PointGen(&p, &secret);
    
    [pc appendBytes:&p length:sizeof(p)];
    [pc appendBytes:&chain length:sizeof(chain)]; // xPub
    
    return pc;
}

/**
 Calculates n-th private key for specific payment code xPriv key
 @param n Derived key number
 @param codePriv
 @paramblock
 xPriv for the payment code, packed in NSData as follows:
    x,c
 @endparamblock
 @return Private key as UInt256 packed in NSData
 */
- (NSData * _Nonnull)privateKey:(uint32_t)n forPaymentCodePriv:(NSData * _Nonnull)codePriv
{
    NSMutableData *key = [NSMutableData secureData];
    
    UInt256 secret = *(UInt256 *)codePriv.bytes;
    UInt256 chain = *(UInt256 *)(codePriv.bytes+sizeof(UInt256));
    
    CKDpriv(&secret, &chain, n);        // xPriv(PC/n)
    
    [key appendBytes:&secret length:sizeof(secret)];
    
    return key;
}

/**
 Calculates n-th public key for specific payment code xPub key

 @param n Derived key number
 @param codePub
 @parblock
 <b>xPub</b> of the payment code, packed in NSData as follows:
 <tt>sign,x,c</tt>
 @endparblock
 @return Public key as ECPoint structure packed in NSData
 */
- (NSData * _Nonnull)publicKey:(uint32_t)n forPaymentCodePub:(NSData * _Nonnull)codePub
{
    NSMutableData *key = [NSMutableData secureData];
    
    BRECPoint point = *(BRECPoint *)codePub.bytes;
    UInt256 chain = *(UInt256 *)(codePub.bytes+sizeof(BRECPoint));
    
    CKDpub(&point, &chain, n);          // xPub(PC/n)
    
    [key appendBytes:&point length:sizeof(point)];
    
    return key;
}

/**
 Calculates n-th private key in a specific subchain for specific payment code xPriv key

 @param n Derived key number
 @param sub Subchain number
 @param codePriv
 @paramblock
 xPriv for the payment code, packed in NSData as follows:
 x,c
 @endparamblock
 @return Private key as UInt256 packed in NSData
 */
- (NSData * _Nonnull)privateKey:(uint32_t)n inSubchain:(uint32_t)sub forPaymentCodePriv:(NSData * _Nonnull)codePriv
{
    NSMutableData *key = [NSMutableData secureData];
    
    UInt256 secret = *(UInt256 *)codePriv.bytes;
    UInt256 chain = *(UInt256 *)(codePriv.bytes+sizeof(UInt256));
    
    CKDpriv(&secret, &chain, sub);      // xPriv(PC/sub)
    CKDpriv(&secret, &chain, n);        // xPriv(PC/sub/n)
    
    [key appendBytes:&secret length:sizeof(secret)];
    
    return key;
}

/**
 Calculates n-th public key in a specific subchain for specific payment code xPub key
 
 @param n Derived key number
 @param codePub
 @parblock
 <b>xPub</b> of the payment code, packed in NSData as follows:
 <tt>sign,x,c</tt>
 @endparblock
 @return Public key as ECPoint structure packed in NSData
 */
- (NSData * _Nonnull)publicKey:(uint32_t)n inSubchain:(uint32_t)sub forPaymentCodePub:(NSData * _Nonnull)codePub
{
    NSMutableData *key = [NSMutableData secureData];
    
    BRECPoint point = *(BRECPoint *)codePub.bytes;
    UInt256 chain = *(UInt256 *)(codePub.bytes+sizeof(BRECPoint));
    
    CKDpub(&point, &chain, sub);        // xPub(PC/sub)
    CKDpub(&point, &chain, n);          // xPub(PC/sub/n)
    
    [key appendBytes:&point length:sizeof(point)];
    
    return key;
}

+ (NSData *) deriveAccountRootXPrivateKeyForAccountNumber:(uint32_t)accountNumber fromSeed:(NSData *)seed
{
    if (!seed) return nil;
    
    UInt512 I;
    HMAC(&I, SHA512, sizeof(UInt512), BIP32_SEED_KEY, strlen(BIP32_SEED_KEY), seed.bytes, seed.length);
    UInt256 secret = *(UInt256 *)&I;
    UInt256 chain = *(UInt256 *)&I.u8[sizeof(UInt256)];
    NSMutableData *accRootPriv = [NSMutableData secureData];
    
    uint32_t coin = 0; // Bitcoin Main
#if BITCOIN_TESTNET
    coin = 1; // Bitcoin Testnet
#endif
    CKDpriv(&secret, &chain, 44 | BIP32_HARD); // m/44'
    CKDpriv(&secret, &chain, coin | BIP32_HARD); // // m/44'/coin'
    CKDpriv(&secret, &chain, accountNumber | BIP32_HARD);// m/44'/coin'/account_number'
    
    [accRootPriv appendBytes:&secret length:sizeof(secret)];
    [accRootPriv appendBytes:&chain length:sizeof(chain)];// UInt256
    
    return accRootPriv;
}

+ (NSData *) deriveAccountRootPublicKeyForAccountNumber:(uint32_t)accountNumber fromSeed:(NSData *)seed
{
    if (! seed) return nil;
    
    NSData *priv = [self deriveAccountRootXPrivateKeyForAccountNumber:accountNumber fromSeed:seed];
    
    BRECPoint p;
    BRSecp256k1PointGen(&p, priv.bytes);
    
    NSMutableData *pubK = [NSMutableData secureData];
    [pubK appendBytes:&p length:sizeof(p)];
    
    return pubK;
}

+ (NSData *) derivePrivKeyForAccountNumber: (uint32_t) accountNumber fromSeed:(NSData *) seed isInternalChain: (BOOL) isInternal  {
    NSData *privAcRoot = [self deriveAccountRootXPrivateKeyForAccountNumber:accountNumber fromSeed:seed];
    UInt256 secret = *(UInt256 *)(privAcRoot.bytes);
    UInt256 chain = *(UInt256 *)(privAcRoot.bytes + sizeof(UInt256));
    
    uint32_t ch = isInternal ? 1 : 0;
    CKDpriv(&secret, &chain, ch);
    
    NSMutableData *privK = [NSMutableData secureData];
    [privK appendBytes:&secret length:sizeof(secret)];
    return privK;
}

+ (NSData *) derivePubKeyForAccountNumber: (uint32_t) accountNumber fromSeed: (NSData *) seed isInternalChain: (BOOL) isInternal {
    if (!seed) return nil;
    
    NSData *privKey = [self derivePrivKeyForAccountNumber:accountNumber fromSeed:seed isInternalChain:isInternal];
    BRECPoint p;
    BRSecp256k1PointGen(&p, privKey.bytes);
    
    NSMutableData *pubK = [NSMutableData secureData];
    [pubK appendBytes:&p length:sizeof(p)];
    return pubK;
}

+ (NSData *) deriveMnemonicAuthIdXPrivateKeyForAccountNumber: (uint32_t) accountNumber fromSeed: (NSData *) seed {
    if (!seed) return nil;
    
    UInt512 I;
    HMAC(&I, SHA512, sizeof(UInt512), BIP32_SEED_KEY, strlen(BIP32_SEED_KEY), seed.bytes, seed.length);
    UInt256 secret = *(UInt256 *)&I;
    UInt256 chain = *(UInt256 *)&I.u8[sizeof(UInt256)];
    NSMutableData *accRootPriv = [NSMutableData secureData];
    
    uint32_t coin = 0; // Bitcoin Main
#if BITCOIN_TESTNET
    coin = 1; // Bitcoin Testnet
#endif
    CKDpriv(&secret, &chain, 345 | BIP32_HARD); // m/345'
    CKDpriv(&secret, &chain, coin | BIP32_HARD); // // m/345'/coin'
    CKDpriv(&secret, &chain, accountNumber | BIP32_HARD);// m/345'/coin'/account_number'
    CKDpriv(&secret, &chain, 0 | BIP32_HARD);// m/345'/coin'/account_number'/0'
    
    [accRootPriv appendBytes:&secret length:sizeof(secret)];
    [accRootPriv appendBytes:&chain length:sizeof(chain)];
    
    return accRootPriv;
}

+ (NSData *_Nullable) deriveMnemonicAuthIDPubKeyForAccount: (uint32_t) number fromSeed: (NSData *) seed {
    if (!seed) return nil;
    
    NSData *privKey = [self deriveMnemonicAuthIdXPrivateKeyForAccountNumber:number fromSeed:seed];
    BRECPoint p;
    BRSecp256k1PointGen(&p, privKey.bytes);
    
    NSMutableData *pubK = [NSMutableData secureData];
    [pubK appendBytes:&p length:sizeof(p)];
    return pubK;
}

@end
