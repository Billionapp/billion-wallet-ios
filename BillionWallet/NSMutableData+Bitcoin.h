//
//  NSMutableData+Bitcoin.h
//  BreadWallet
//
//  Created by Aaron Voisine on 5/20/13.
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

#if BITCOIN_TESTNET
#define BITCOIN_MAGIC_NUMBER 0x0709110bu
#else
#define BITCOIN_MAGIC_NUMBER 0xd9b4bef9u
#endif

CF_IMPLICIT_BRIDGING_ENABLED

CFAllocatorRef _Nonnull SecureAllocator(void);

CF_IMPLICIT_BRIDGING_DISABLED

@interface NSMutableData (Bitcoin)

+ (NSMutableData * _Nullable)secureData;
+ (NSMutableData * _Nullable)secureDataWithLength:(NSUInteger)length;
+ (NSMutableData * _Nullable)secureDataWithCapacity:(NSUInteger)capacity;
+ (NSMutableData * _Nullable)secureDataWithData:(NSData * _Nonnull)data;

+ (size_t)sizeOfVarInt:(uint64_t)i;

- (void)appendUInt8:(uint8_t)i;
- (void)appendUInt16:(uint16_t)i;
- (void)appendUInt32:(uint32_t)i;
- (void)appendUInt64:(uint64_t)i;
- (void)appendVarInt:(uint64_t)i;
- (void)appendString:(NSString * _Nonnull)s;

- (void)appendScriptPubKeyForAddress:(NSString * _Nonnull)address;
- (void)appendScriptPushData:(NSData * _Nonnull)d;

- (void)appendMessage:(NSData * _Nonnull)message type:(NSString * _Nonnull)type;
- (void)appendNullPaddedString:(NSString * _Nonnull)s length:(NSUInteger)length;
- (void)appendNetAddress:(uint32_t)address port:(uint16_t)port services:(uint64_t)services;

@end
