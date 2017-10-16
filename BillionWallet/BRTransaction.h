//
//  BRTransaction.h
//  BreadWallet
//
//  Created by Aaron Voisine on 5/16/13.
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
#import "MACRO.h"

#define TX_FEE_PER_KB        1000ULL     // standard tx fee per kb of tx size, rounded up to nearest kb
#define TX_OUTPUT_SIZE       34          // estimated size for a typical transaction output
#define TX_INPUT_SIZE        148         // estimated size for a typical compact pubkey transaction input
#define TX_MIN_OUTPUT_AMOUNT (TX_FEE_PER_KB*3*(TX_OUTPUT_SIZE + TX_INPUT_SIZE)/1000) //no txout can be below this amount
#define TX_MAX_SIZE          100000      // no tx can be larger than this size in bytes
#define TX_FREE_MAX_SIZE     1000        // tx must not be larger than this size in bytes without a fee
#define TX_FREE_MIN_PRIORITY 57600000ULL // tx must not have a priority below this value without a fee
#define TX_UNCONFIRMED       INT32_MAX   // block height indicating transaction is unconfirmed
#define TX_MAX_LOCK_HEIGHT   500000000   // a lockTime below this value is a block height, otherwise a timestamp

typedef union _UInt256 UInt256;

@interface BRTransaction : NSObject

/**
 Address in form of NSString
 */
@property (nonatomic, readonly) NSArray * _Nonnull inputAddresses;
/**
 UInt256 in form of NSValue
 */
@property (nonatomic, readonly) NSArray * _Nonnull inputHashes;
/**
 Integer as NSNumber
 */
@property (nonatomic, readonly) NSArray * _Nonnull inputIndexes;
/**
 NSData
 */
@property (nonatomic, readonly) NSArray * _Nonnull inputScripts;
/**
 NSData
 */
@property (nonatomic, readonly) NSArray * _Nonnull inputSignatures;
/**
 UInt32 as NSNumber
 */
@property (nonatomic, readonly) NSArray * _Nonnull inputSequences;
/**
 UInt64 as NSNumber
 */
@property (nonatomic, readonly) NSArray * _Nonnull outputAmounts;
/**
 Address as NSString
 */
@property (nonatomic, readonly) NSArray * _Nonnull outputAddresses;
/**
 NSData
 */
@property (nonatomic, readonly) NSArray * _Nonnull outputScripts;


//Notes for transaction
@property (nonatomic, nullable) NSString *userNote;

//Flag for notification transaction
@property (nonatomic) BOOL isNotification;

@property (nonatomic, assign) UInt256 txHash;
@property (nonatomic, assign) uint32_t version;
@property (nonatomic, assign) uint32_t lockTime;
@property (nonatomic, assign) uint32_t blockHeight;
@property (nonatomic, assign) NSTimeInterval timestamp; // time interval since refrence date, 00:00:00 01/01/01 GMT
@property (nonatomic, readonly) size_t size; // size in bytes if signed, or estimated size assuming compact pubkey sigs
@property (nonatomic, readonly) uint64_t standardFee;
@property (nonatomic, readonly) BOOL isSigned; // checks if all signatures exist, but does not verify them
@property (nonatomic, readonly, getter = toData) NSData * _Nonnull data;

@property (nonatomic, readonly) NSString * _Nonnull longDescription;

+ (instancetype _Nullable)transactionWithMessage:(NSData * _Nonnull)message;

- (instancetype _Nullable)initWithMessage:(NSData * _Nonnull)message;
- (instancetype _Nullable)initWithInputHashes:(NSArray * _Nonnull)hashes inputIndexes:(NSArray<NSNumber *> * _Nonnull)indexes inputScripts:(NSArray<NSData *> * _Nonnull)scripts
outputAddresses:(NSArray<NSString *> * _Nonnull)addresses outputAmounts:(NSArray<NSNumber *> * _Nonnull)amounts;

- (void)addInputHash:(UInt256)hash index:(NSUInteger)index script:(NSData * _Nullable)script;
- (void)addInputHash:(UInt256)hash index:(NSUInteger)index script:(NSData * _Nullable)script signature:(NSData * _Nullable)signature
sequence:(uint32_t)sequence;
- (void)addOutputAddress:(NSString * _Nonnull)address amount:(uint64_t)amount;
- (void)addOutputScript:(NSData * _Nonnull)script amount:(uint64_t)amount;
- (void)setInputAddress:(NSString * _Nonnull)address atIndex:(NSUInteger)index;
- (void)shuffleOutputOrder;
- (BOOL)signWithPrivateKeys:(NSArray<NSString *> * _Nonnull)privateKeys;

// priority = sum(input_amount_in_satoshis*input_age_in_blocks)/tx_size_in_bytes
- (uint64_t)priorityForAmounts:(NSArray<NSNumber *> * _Nonnull)amounts withAges:(NSArray<NSNumber *> * _Nonnull)ages;

// the block height after which the transaction can be confirmed without a fee, or TX_UNCONFIRMED for never
- (uint32_t)blockHeightUntilFreeForAmounts:(NSArray<NSNumber *> * _Nonnull)amounts withBlockHeights:(NSArray<NSNumber *> * _Nonnull)heights;

@end
