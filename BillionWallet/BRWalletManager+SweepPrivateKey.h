//
//  BRWalletManager+SweepPrivateKey.h
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

#import "BRWalletManager.h"
#import "BRKey.h"
#import "NSData+Bitcoin.h"
#import "NSString+Bitcoin.h"
#import "MACRO.h"

@interface BRWalletManager (SweepPrivateKey)

- (void) utxosWithRequest:(NSURLRequest *_Nullable) request forAddresses:(NSArray *_Nullable)addresses
               completion:(void (^_Nullable)(NSArray * _Nullable utxos, NSArray * _Nullable amounts, NSArray * _Nullable scripts, NSError * _Nullable error))completion;

- (void) sweepPrivateKeyWithRequest: (NSURLRequest *_Nullable) request withPrivKey: (NSString * _Nonnull)privKey withFee:(BOOL)fee
                         completion:(void (^ _Nonnull)(BRTransaction * _Nonnull tx, uint64_t fee, uint64_t amount, NSError * _Null_unspecified error))completion;

@end
