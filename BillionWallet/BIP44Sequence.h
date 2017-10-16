//
//  BIP44Sequence.h
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRKeySequence.h"
#import "MACRO.h"

#define BIP32_HARD 0x80000000

@interface BIP44Sequence : NSObject<BRKeySequence>

- (NSData * _Nonnull) masterPublicKeyFromSeed:(NSData * _Nonnull)seed;
- (NSData * _Nullable) publicKey:(uint32_t)n internal:(BOOL)internal masterPublicKey:(NSData * _Nonnull)masterPublicKey;
- (NSString * _Nonnull) privateKey:(uint32_t)n internal:(BOOL)internal fromSeed:(NSData * _Nonnull)seed;
- (NSArray<NSString *> * _Nonnull) privateKeys:(NSArray<NSNumber *> * _Nonnull)n internal:(BOOL)internal fromSeed:(NSData * _Nonnull)seed;

- (NSData * _Nonnull) paymentCodePrivateKeyForAccount:(uint32_t)account fromSeed:(NSData * _Nonnull)seed;
- (NSData * _Nonnull) paymentCodeForAccount:(uint32_t)account fromSeed:(NSData * _Nonnull)seed;

- (NSData * _Nonnull) privateKey:(uint32_t)n forPaymentCodePriv:(NSData * _Nonnull)codePriv;
- (NSData * _Nonnull) publicKey:(uint32_t)n forPaymentCodePub:(NSData * _Nonnull)codePub;

- (NSData * _Nonnull) privateKey:(uint32_t)n inSubchain:(uint32_t)sub forPaymentCodePriv:(NSData * _Nonnull)codePriv;
- (NSData * _Nonnull) publicKey:(uint32_t)n inSubchain:(uint32_t)sub forPaymentCodePub:(NSData * _Nonnull)codePub;

// m/44'/coin'/account_number'
+ (NSData *_Nonnull) deriveAccountRootXPrivateKeyForAccountNumber:(uint32_t)accountNumber fromSeed:(NSData *_Nonnull)seed;
+ (NSData *_Nonnull) deriveAccountRootPublicKeyForAccountNumber:(uint32_t)accountNumber fromSeed:(NSData *_Nonnull)seed;

+ (NSData *_Nullable) derivePrivKeyForAccountNumber: (uint32_t) accountNumber fromSeed:(NSData *_Nullable) seed isInternalChain: (BOOL) isInternal;
+ (NSData *_Nullable) derivePubKeyForAccountNumber: (uint32_t) accountNumber fromSeed: (NSData *_Nullable) seed isInternalChain: (BOOL) isInternal;

// m/345'/coin'/account_number'/0'
+ (NSData *_Nullable) deriveMnemonicAuthIdXPrivateKeyForAccountNumber: (uint32_t) accountNumber fromSeed: (NSData *_Nullable) seed;
+ (NSData *_Nullable) deriveMnemonicAuthIDPubKeyForAccount: (uint32_t) number fromSeed: (NSData *_Nullable) seed;

@end
