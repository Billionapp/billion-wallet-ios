//
//  BRWalletManager+Keychain.h
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

#import "BRWalletManager.h"
#import "BRBIP39Mnemonic.h"

@interface BRWalletManager (Keychain)

+ (NSString *_Nullable) getMnemonicKeychainString;
+ (NSData *_Nullable) getMPKKeychainData;
+ (NSData *_Nullable) getSEEDKeychainData;
+ (void) clearKeyChainWithKey: (NSString *_Nullable) key;

+ (BOOL) setKeychainDictionary: (NSDictionary *_Nullable) dict andKey: (NSString *_Nullable) key;
+ (NSDictionary *_Nullable) getKeychainDictionary: (NSString *_Nullable) key;

// Account Root
- (void) setKeyChainAccountRootKeysWithNumber: (uint32_t) number;
+ (NSData *_Nullable) getAccountRootPrivKey;
+ (NSData *_Nullable) getAccountRootPubKey;

// Mnemonic Auth Id XPriv
- (void) setKeychainAuthIDXPrivForAccount: (uint32_t) number andAuthIdXPriv: (NSData *_Nullable) authIdPriv;
+ (NSData *_Nullable) getKeychainAuthIdXPrivForAccount: (uint32_t) number;

// Wallet Digest
- (void) setKeyChainWalletDigestForAccount: (uint32_t)number andWalletDigest:(NSString *_Nullable) walletDigest;
- (NSString *_Nullable) getKeychainWalletDigestForAccount: (uint32_t) number;

// Mnemonic Auth Id XPub
- (void) setKeychainAuthIDXPubForAccount: (uint32_t) number andAuthIdPub: (NSData *_Nullable) authIdXPub;
- (NSData *_Nullable) getKeychainAuthIDXPubForAccount: (uint32_t) number;

// UDID
+ (void) setKeyChainUdidForAccountNumber: (uint32_t) accountNumber andUdid: (NSString *_Nullable) udid;
+ (NSString *_Nullable) getKeyChainUdidForAccountNumber: (uint32_t) accountNumber;

// Shared Public key DH
+ (void) setKeyChainSharedPubDHForAccount: (uint32_t) accountNumber key: (NSData *_Nullable) key;
+ (NSData *_Nullable) getKeyChainSharedPubDHForAccount: (uint32_t) accountNumber;

// Secret DHA
+ (void) setKeyChainSecretDHForAccount: (uint32_t) number secret: (NSData *_Nullable) secret;
+ (NSData *_Nullable) getKeyChainSecretDHForAccount: (uint32_t) number;

// Password
+ (void) setKeyChainPassword: (NSString *_Nullable) password;
+ (NSString *_Nullable) getKeyChainPassword;

//PaymentCode
+ (void) setKeyChainPaymentCodeForAccount:(uint32_t)number andPaymentCode:(NSString *_Nonnull) paymentCode;
+ (NSString *_Nonnull) getKeychainPaymentCodeForAccount: (uint32_t) number;

//PaymentCodePriv
+ (void) setKeyChainPaymentCodePrivForAccount:(uint32_t)number andPaymentCodePriv:(NSData *_Nonnull) paymentCodePriv;
+ (NSData *_Nonnull) getKeychainPaymentCodePrivForAccount: (uint32_t) number;

//NotificationId
+ (void) setKeyChainNotificationIdVer1ForAccount:(uint32_t)number andNotificationId:(NSString *_Nonnull) notificationId;
+ (NSString *_Nonnull) getKeychainNotificationIdVer1ForAccount: (uint32_t) number;

+ (void) setKeyChainNotificationIdVer2ForAccount:(uint32_t)number andNotificationId:(NSData *_Nonnull) notificationId;
+ (NSData *_Nonnull) getKeychainNotificationIdVer2ForAccount: (uint32_t) number;

@end
