//
//  BRWalletManager+SweepPrivateKey.m
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

#import "BRWalletManager+SweepPrivateKey.h"

@implementation BRWalletManager (SweepPrivateKey)

- (void) utxosWithRequest:(NSURLRequest *) request forAddresses:(NSArray *)addresses
               completion:(void (^)(NSArray *utxos, NSArray *amounts, NSArray *scripts, NSError *error))completion {
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completion(nil, nil, nil, error);
            return;
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSMutableArray *utxos = [NSMutableArray array], *amounts = [NSMutableArray array],
        *scripts = [NSMutableArray array];
        BRUTXO o;
        NSMutableArray *txRefs = json[@"txrefs"];
        
        for (NSMutableDictionary *txRef in txRefs) {
            o.hash = *(const UInt256 *)[txRef[@"tx_hash"] hexToData].reverse.bytes;
            o.n = [txRef[@"tx_output_n"] unsignedIntValue];
            [utxos addObject:brutxo_obj(o)];
            [amounts addObject:txRef[@"value"]];
            [scripts addObject:[txRef[@"script"] hexToData]];
        }
        
        completion(utxos, amounts, scripts, nil);
    }] resume];
    
}

- (void) sweepPrivateKeyWithRequest: (NSURLRequest *_Nullable) request withPrivKey: (NSString * _Nonnull)privKey withFee:(BOOL)fee
                         completion:(void (^ _Nonnull)(BRTransaction * _Nullable tx, uint64_t fee, uint64_t amount, NSError * _Null_unspecified error))completion {
    
    BRKey *key = [BRKey keyWithPrivateKey:privKey];
    
    if (! key.address) {
        completion(nil, 0, 0, [NSError errorWithDomain:@"checkingKeyErrorDomain" code:187 userInfo:@{NSLocalizedDescriptionKey:
                                                                                           NSLocalizedString(@"not a valid private key", nil)}]);
        return;
    }
    
    if ([self.wallet containsAddress:key.address]) {
        completion(nil, 0, 0, [NSError errorWithDomain:@"checkingKeyErrorDomain" code:187 userInfo:@{NSLocalizedDescriptionKey:
                                                                                           NSLocalizedString(@"this private key is already in your wallet", nil)}]);
        return;
    }
        
    [self utxosWithRequest:request forAddresses:@[key.address] completion:^(NSArray * _Nullable utxos, NSArray * _Nullable amounts, NSArray * _Nullable scripts, NSError * _Nullable error) {
        BRTransaction *tx = [BRTransaction new];
        uint64_t balance = 0, feeAmount = 0;
        NSUInteger i = 0;
        
        if (error) {
            completion(nil, 0, 0, error);
            return;
        }
        
        //TODO: make sure not to create a transaction larger than TX_MAX_SIZE
        for (NSValue *output in utxos) {
            BRUTXO o;
            
            [output getValue:&o];
            [tx addInputHash:o.hash index:o.n script:scripts[i]];
            balance += [amounts[i++] unsignedLongLongValue];
        }
        
        if (balance == 0) {
            completion(nil, 0, 0, [NSError errorWithDomain:@"checkingKeyErrorDomain" code:417 userInfo:@{NSLocalizedDescriptionKey:
                                                                                               NSLocalizedString(@"this private key is empty", nil)}]);
            return;
        }
        
        if (fee) feeAmount = [self.wallet feeForTxSize:tx.size + 34 + (key.publicKey.length - 33)*tx.inputHashes.count];
        
        if (feeAmount + self.wallet.minOutputAmount > balance) {
            completion(nil, 0, 0, [NSError errorWithDomain:@"checkingKeyErrorDomain" code:417 userInfo:@{NSLocalizedDescriptionKey:
                                                                                               NSLocalizedString(@"transaction fees would cost more than the funds available on this "
                                                                                                                 "private key (due to tiny \"dust\" deposits)",nil)}]);
            return;
        }
        
        [tx addOutputAddress:self.wallet.receiveAddress amount:balance - feeAmount];
        
        if (! [tx signWithPrivateKeys:@[privKey]]) {
            completion(nil, 0, 0, [NSError errorWithDomain:@"checkingKeyErrorDomain" code:401 userInfo:@{NSLocalizedDescriptionKey:
                                                                                               NSLocalizedString(@"error signing transaction", nil)}]);
            return;
        }
        
        completion(tx, feeAmount, balance, nil);
    }];
}


@end
