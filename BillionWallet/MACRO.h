//
//  MACRO.h
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11.05.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

#if DEBUG
    #define PEER_LOGGING    1
#else
    #define PEER_LOGGING    0
#endif
#define EVENT_LOGGING   0

#define LOCK @"\xF0\x9F\x94\x92" // unicode lock symbol U+1F512 (utf-8)
#define REDX @"\xE2\x9D\x8C"     // unicode cross mark U+274C, red x emoji (utf-8)
#define NBSP @"\xC2\xA0"         // no-break space (utf-8)

#define BIP32_SEED_KEY "Bitcoin seed"
#define BIP32_XPRV     "\x04\x88\xAD\xE4"
#define BIP32_XPUB     "\x04\x88\xB2\x1E"

#define MNEMONIC_KEY        @"mnemonic"
#define CREATION_TIME_KEY   @"creationtime"
#define MASTER_PUBKEY_KEY   @"masterpubkey"
#define SPEND_LIMIT_KEY     @"spendlimit"
#define AUTH_PRIVKEY_KEY    @"authprivkey"
#define SEED_KEY            @"seed" // depreceated

#define ACCOUNT_ROOT_PRIV_KEY  @"accountRootPrivKey"
#define ACCOUNT_ROOT_PUB_KEY   @"accountRootPubKey"
#define MNEMONIC_AUTH_ID_XPRIV @"mnemonicAuthIdXPriv"
#define MNEMONIC_AUTH_ID_PUB   @"mnemonicAuthIDPub"
#define UDID                   @"udid"
#define SHARED_KEY_DH          @"sharedKeyDH"
#define SECRET_DH              @"secretDH"
#define WALLET_DIGEST          @"walletDigest"
#define PAYMENT_CODE           @"paymentCode"
#define PAYMENT_CODE_PRIV      @"paymentCodePriv"
#define NOTIFICATION_ID_VER_1  @"notificationIdVer1"
#define NOTIFICATION_ID_VER_2  @"notificationIdVer2"
#if BITCOIN_TESTNET
    #define SEC_ATTR_SERVICE      @"com.evogroup.billionwallet-test"
#else
    #define SEC_ATTR_SERVICE      @"com.evogroup.billionwallet"
#endif
#define BIP32_HARD 0x80000000

