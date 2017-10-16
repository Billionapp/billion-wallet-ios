//
//  BRWalletManager+Keychain.m
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

#import "BRWalletManager+Keychain.h"

BOOL setKeychainData(NSData *data, NSString *key, BOOL authenticated);
NSData *getKeychainData(NSString *key, NSError **error);
BOOL setKeychainInt(int64_t i, NSString *key, BOOL authenticated);
int64_t getKeychainInt(NSString *key, NSError **error);
BOOL setKeychainString(NSString *s, NSString *key, BOOL authenticated);
NSString *getKeychainString(NSString *key, NSError **error);
BOOL setKeychainDict(NSDictionary *dict, NSString *key, BOOL authenticated);
NSDictionary *getKeychainDict(NSString *key, NSError **error);

@implementation BRWalletManager (Keychain)

+ (NSString *) getMnemonicKeychainString {
	
	return getKeychainString(MNEMONIC_KEY, nil);
}

+ (NSData *) getMPKKeychainData {
	
	return getKeychainData(MASTER_PUBKEY_KEY, nil);
}

+ (NSData *) getSEEDKeychainData {
	
	return getKeychainData(SEED_KEY, nil);
}

+ (void) clearKeyChainWithKey: (NSString *) key {
    
    setKeychainData(nil, key, YES);
}


+ (BOOL) setKeychainDictionary: (NSDictionary *_Nullable) dict andKey: (NSString *_Nullable) key {
    if (!key) return NO;
    return setKeychainDict(dict, key, YES);
}

+ (NSDictionary *_Nullable) getKeychainDictionary: (NSString *_Nullable) key {
    return getKeychainDict(key, nil);
}

- (void) setKeyChainAccountRootKeysWithNumber: (uint32_t) number; {
    
    NSString *seedPhrase = getKeychainString(MNEMONIC_KEY, nil);
    NSData *seed = [[BRBIP39Mnemonic new] deriveKeyFromPhrase:seedPhrase withPassphrase:nil];
    
    NSData *privKey = [BIP44Sequence deriveAccountRootXPrivateKeyForAccountNumber:number fromSeed:seed];
    
    NSData *pubKey = [BIP44Sequence deriveAccountRootPublicKeyForAccountNumber:number fromSeed:seed];
    setKeychainData(privKey, ACCOUNT_ROOT_PRIV_KEY, YES);
    setKeychainData(pubKey, ACCOUNT_ROOT_PUB_KEY, YES);
    
}

+ (NSData *) getAccountRootPrivKey {
	
	return getKeychainData(ACCOUNT_ROOT_PRIV_KEY, nil);
}

+ (NSData *) getAccountRootPubKey {
	return getKeychainData(ACCOUNT_ROOT_PUB_KEY, nil);
}

- (void) setKeychainAuthIDXPrivForAccount: (uint32_t) number andAuthIdXPriv: (NSData *) authIdPriv {
 
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    NSMutableDictionary *authIDPrivDict = [getKeychainDict(MNEMONIC_AUTH_ID_XPRIV, nil) mutableCopy];
    
    if (!authIDPrivDict) {
        authIDPrivDict = [[NSMutableDictionary alloc] init];
    }
    
    if (![authIDPrivDict objectForKey:acNum]) {
        [authIDPrivDict setValue:authIdPriv forKey:acNum];
        setKeychainDict(authIDPrivDict, MNEMONIC_AUTH_ID_XPRIV, YES);
    }
}


+ (NSData *_Nullable) getKeychainAuthIdXPrivForAccount: (uint32_t) number {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    NSDictionary *authIdPrivDict = getKeychainDict(MNEMONIC_AUTH_ID_XPRIV, nil);
    return [authIdPrivDict valueForKey:acNum];
}

- (void) setKeyChainWalletDigestForAccount:(uint32_t)number andWalletDigest:(NSString *) walletDigest {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    
    NSMutableDictionary *walletDigestDict = [getKeychainDict(WALLET_DIGEST, nil) mutableCopy];
    
    if (!walletDigestDict) {
        walletDigestDict = [[NSMutableDictionary alloc] init];
    }
    
    if (![walletDigestDict objectForKey:acNum]) {
        [walletDigestDict setValue:walletDigest forKey:acNum];
        setKeychainDict(walletDigestDict, WALLET_DIGEST, YES);
    }
}

- (NSString *) getKeychainWalletDigestForAccount: (uint32_t) number {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    NSDictionary *walletDigestDict = getKeychainDict(WALLET_DIGEST, nil);
    return [walletDigestDict valueForKey:acNum];
}

- (void) setKeychainAuthIDXPubForAccount: (uint32_t) number andAuthIdPub: (NSData *) authIdXPub {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    NSMutableDictionary *authIDPubDict = [getKeychainDict(MNEMONIC_AUTH_ID_PUB, nil) mutableCopy];
    
    if (!authIDPubDict) {
        authIDPubDict = [[NSMutableDictionary alloc] init];
    }
    
    if (![authIDPubDict objectForKey:acNum]) {
        [authIDPubDict setValue:authIdXPub forKey:acNum];
        setKeychainDict(authIDPubDict, MNEMONIC_AUTH_ID_PUB, YES);
        
    }
}

- (NSData *) getKeychainAuthIDXPubForAccount: (uint32_t) number {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    NSDictionary *authIdPubDict = getKeychainDict(MNEMONIC_AUTH_ID_PUB, nil);
    return [authIdPubDict valueForKey:acNum];
}

+ (void) setKeyChainUdidForAccountNumber: (uint32_t) accountNumber andUdid: (NSString *) udid {
	NSString *acNum = [NSString stringWithFormat:@"%u", accountNumber];
	NSMutableDictionary *udidDict = [getKeychainDict(UDID, nil) mutableCopy];
	
	if (!udidDict) {
		udidDict = [[NSMutableDictionary alloc] init];
	}
	
	if (![udidDict objectForKey:acNum]) {
		[udidDict setValue:udid forKey:acNum];
		setKeychainDict(udidDict, UDID, YES);
	}
}

+ (NSData *) getKeyChainUdidForAccountNumber: (uint32_t) accountNumber {
	NSString *acNum = [NSString stringWithFormat:@"%u", accountNumber];
	NSDictionary *udidDict = getKeychainDict(UDID, nil);
	return [udidDict valueForKey:acNum];
}

+ (void) setKeyChainSharedPubDHForAccount:(uint32_t)accountNumber key:(NSData *)key {
    NSString *acNum = [NSString stringWithFormat:@"%u", accountNumber];
    NSMutableDictionary *shKDHDict = [getKeychainDict(SHARED_KEY_DH, nil) mutableCopy];
    
    if (!shKDHDict) {
        shKDHDict = [[NSMutableDictionary alloc] init];
    }
    
    if (![shKDHDict objectForKey:acNum]) {
        [shKDHDict setValue:key forKey:acNum];
        setKeychainDict(shKDHDict, SHARED_KEY_DH, YES);
    }
}

+ (NSString *) getKeyChainSharedPubDHForAccount: (uint32_t) accountNumber {
    NSString *acNum = [NSString stringWithFormat:@"%u", accountNumber];
    NSDictionary *shKDHDict = getKeychainDict(SHARED_KEY_DH, nil);
    return [shKDHDict valueForKey:acNum];
}

+ (void) setKeyChainSecretDHForAccount: (uint32_t) number secret: (NSData *_Nullable) secret {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    NSDictionary *secretKDHDict = getKeychainDict(SECRET_DH, nil);
    
    if (!secretKDHDict) {
        secretKDHDict = [[NSMutableDictionary alloc] init];
    }
    
    if (![secretKDHDict objectForKey:acNum]) {
        [secretKDHDict setValue:secret forKey:acNum];
        setKeychainDict(secretKDHDict, SECRET_DH, YES);
    }
}

+ (NSData *) getKeyChainSecretDHForAccount:(uint32_t)number {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    NSDictionary *secretKDHDict = getKeychainDict(SECRET_DH, nil);
    return [secretKDHDict valueForKey:acNum];
}

+ (void) setKeyChainPassword: (NSString *) password {
    setKeychainString(password, @"APP_AUTH_PASSWORD", YES);
}

+ (NSString *) getKeyChainPassword {
    return getKeychainString(@"APP_AUTH_PASSWORD", nil);
}

+ (void) setKeyChainPaymentCodeForAccount:(uint32_t)number andPaymentCode:(NSString *) paymentCode {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    
    NSMutableDictionary *paymentCodeDict = [getKeychainDict(PAYMENT_CODE, nil) mutableCopy];
    
    if (!paymentCodeDict) {
        paymentCodeDict = [[NSMutableDictionary alloc] init];
    }
    
    if (![paymentCodeDict objectForKey:acNum]) {
        [paymentCodeDict setValue:paymentCode forKey:acNum];
        setKeychainDict(paymentCodeDict, PAYMENT_CODE, YES);
    }
}

+ (NSString *) getKeychainPaymentCodeForAccount: (uint32_t) number {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    NSDictionary *paymentCodeDict = getKeychainDict(PAYMENT_CODE, nil);
    return [paymentCodeDict valueForKey:acNum];
}

+ (void) setKeyChainPaymentCodePrivForAccount:(uint32_t)number andPaymentCodePriv:(NSData *) paymentCodePriv {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    
    NSMutableDictionary *paymentCodePrivDict = [getKeychainDict(PAYMENT_CODE_PRIV, nil) mutableCopy];
    
    if (!paymentCodePrivDict) {
        paymentCodePrivDict = [[NSMutableDictionary alloc] init];
    }
    
    if (![paymentCodePrivDict objectForKey:acNum]) {
        [paymentCodePrivDict setValue:paymentCodePriv forKey:acNum];
        setKeychainDict(paymentCodePrivDict, PAYMENT_CODE_PRIV, YES);
    }
}

+ (NSData *) getKeychainPaymentCodePrivForAccount: (uint32_t) number {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    NSDictionary *paymentCodePrivDict = getKeychainDict(PAYMENT_CODE_PRIV, nil);
    return [paymentCodePrivDict valueForKey:acNum];
}

+ (void) setKeyChainNotificationIdVer1ForAccount:(uint32_t)number andNotificationId:(NSString *) notificationId {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    
    NSMutableDictionary *notificationIdDict = [getKeychainDict(NOTIFICATION_ID_VER_1, nil) mutableCopy];
    
    if (!notificationIdDict) {
        notificationIdDict = [[NSMutableDictionary alloc] init];
    }
    
    if (![notificationIdDict objectForKey:acNum]) {
        [notificationIdDict setValue:notificationId forKey:acNum];
        setKeychainDict(notificationIdDict, NOTIFICATION_ID_VER_1, YES);
    }
}

+ (NSString *) getKeychainNotificationIdVer1ForAccount: (uint32_t) number {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    NSDictionary *notificationIdDict = getKeychainDict(NOTIFICATION_ID_VER_1, nil);
    return [notificationIdDict valueForKey:acNum];
}

+ (void) setKeyChainNotificationIdVer2ForAccount:(uint32_t)number andNotificationId:(NSData *) notificationId {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    
    NSMutableDictionary *notificationIdDict = [getKeychainDict(NOTIFICATION_ID_VER_2, nil) mutableCopy];
    
    if (!notificationIdDict) {
        notificationIdDict = [[NSMutableDictionary alloc] init];
    }
    
    if (![notificationIdDict objectForKey:acNum]) {
        [notificationIdDict setValue:notificationId forKey:acNum];
        setKeychainDict(notificationIdDict, NOTIFICATION_ID_VER_2, YES);
    }
}

+ (NSData *) getKeychainNotificationIdVer2ForAccount: (uint32_t) number {
    NSString *acNum = [NSString stringWithFormat:@"%u", number];
    NSDictionary *notificationIdDict = getKeychainDict(NOTIFICATION_ID_VER_2, nil);
    return [notificationIdDict valueForKey:acNum];
}

@end
