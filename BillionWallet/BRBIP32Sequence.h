//
//  BRBIP32Sequence.h
//  BreadWallet
//
//  Created by Aaron Voisine on 7/19/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "BRKeySequence.h"
#import "MACRO.h"

#define BIP32_HARD 0x80000000

// BIP32 is a scheme for deriving chains of addresses from a seed value
// https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki

@interface BRBIP32Sequence : NSObject<BRKeySequence>

- (NSData * _Nullable)masterPublicKeyFromSeed:(NSData * _Nullable)seed;
- (NSData * _Nullable)publicKey:(uint32_t)n internal:(BOOL)internal masterPublicKey:(NSData * _Nonnull)masterPublicKey;
- (NSString * _Nullable)privateKey:(uint32_t)n internal:(BOOL)internal fromSeed:(NSData * _Nonnull)seed;
- (NSArray * _Nullable)privateKeys:(NSArray * _Nonnull)n internal:(BOOL)internal fromSeed:(NSData * _Nonnull)seed;

// key used for authenticated API calls, i.e. bitauth: https://github.com/bitpay/bitauth
- (NSString * _Nullable)authPrivateKeyFromSeed:(NSData * _Nullable)seed;

// key used for BitID: https://github.com/bitid/bitid/blob/master/BIP_draft.md
- (NSString * _Nullable)bitIdPrivateKey:(uint32_t)n forURI:(NSString * _Nonnull)uri fromSeed:(NSData * _Nonnull)seed;

- (NSString * _Nullable)serializedPrivateMasterFromSeed:(NSData * _Nullable)seed;
- (NSString * _Nullable)serializedMasterPublicKey:(NSData * _Nonnull)masterPublicKey;

@end
