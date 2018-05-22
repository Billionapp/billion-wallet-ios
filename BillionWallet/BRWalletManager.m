//
//  BRWalletManager.m
//  BreadWallet
//
//  Created by Aaron Voisine on 3/2/14.
//  Copyright (c) 2014 Aaron Voisine <voisine@gmail.com>
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

#import "BRWalletManager.h"
#import "BRKey.h"
#import "BRKey+BIP38.h"
#import "BRBIP39Mnemonic.h"
#import "BRBIP32Sequence.h"
#import "BIP44Sequence.h"
#import "BRTransaction.h"
#import "BRTransactionEntity.h"
#import "BRTxMetadataEntity.h"
#import "BRAddressEntity.h"
#import "NSString+Bitcoin.h"
#import "NSData+Bitcoin.h"
#import "NSMutableData+Bitcoin.h"
#import "NSManagedObject+Sugar.h"
#import "Reachability.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "MACRO.h"

#define FEE_PER_KB_URL       @"https://api.breadwallet.com/fee-per-kb"
#define TICKER_URL           @"https://bitpay.com/rates"
#define TICKER_FAILOVER_URL  @"https://api.breadwallet.com/rates"

#define SEED_ENTROPY_LENGTH   (128/8)
#define DEFAULT_CURRENCY_CODE @"USD"
#define DEFAULT_SPENT_LIMIT   SATOSHIS

#define LOCAL_CURRENCY_CODE_KEY @"LOCAL_CURRENCY_CODE"
#define CURRENCY_CODES_KEY      @"CURRENCY_CODES"
#define CURRENCY_NAMES_KEY      @"CURRENCY_NAMES"
#define CURRENCY_PRICES_KEY     @"CURRENCY_PRICES"
#define SPEND_LIMIT_AMOUNT_KEY  @"SPEND_LIMIT_AMOUNT"
#define SECURE_TIME_KEY         @"SECURE_TIME"
#define FEE_PER_KB_KEY          @"FEE_PER_KB"

#define MNEMONIC_KEY        @"mnemonic"
#define CREATION_TIME_KEY   @"creationtime"
#define MASTER_PUBKEY_KEY   @"masterpubkey"
#define SPEND_LIMIT_KEY     @"spendlimit"
#define AUTH_PRIVKEY_KEY    @"authprivkey"
#define SEED_KEY            @"seed" // depreceated
#define USER_ACCOUNT_KEY    @"http://dev.digitalheroes.tech"

BOOL setKeychainData(NSData *data, NSString *key, BOOL authenticated)
{
    if (! key) return NO;

    id accessible = (authenticated) ? (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                                    : (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
    NSDictionary *query = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService:SEC_ATTR_SERVICE,
                            (__bridge id)kSecAttrAccount:key};

    if (SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL) == errSecItemNotFound) {
        if (! data) return YES;

        NSDictionary *item = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                               (__bridge id)kSecAttrService:SEC_ATTR_SERVICE,
                               (__bridge id)kSecAttrAccount:key,
                               (__bridge id)kSecAttrAccessible:accessible,
                               (__bridge id)kSecValueData:data};
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)item, NULL);

        if (status == noErr) return YES;
        NSLog(@"SecItemAdd error: %@",
              [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil].localizedDescription);
        return NO;
    }

    if (! data) {
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);

        if (status == noErr) return YES;
        NSLog(@"SecItemDelete error: %@",
              [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil].localizedDescription);
        return NO;
    }

    NSDictionary *update = @{(__bridge id)kSecAttrAccessible:accessible,
                             (__bridge id)kSecValueData:data};
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);

    if (status == noErr) return YES;
    NSLog(@"SecItemUpdate error: %@",
          [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil].localizedDescription);
    return NO;
}

 NSData *getKeychainData(NSString *key, NSError **error)
{
    NSDictionary *query = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService:SEC_ATTR_SERVICE,
                            (__bridge id)kSecAttrAccount:key,
                            (__bridge id)kSecReturnData:@YES};
    CFDataRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);

    if (status == errSecItemNotFound) return nil;
    if (status == noErr) return CFBridgingRelease(result);
    NSLog(@"SecItemCopyMatching error: %@",
          [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil].localizedDescription);
    if (error) *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    return nil;
}

BOOL setKeychainInt(int64_t i, NSString *key, BOOL authenticated)
{
    @autoreleasepool {
        NSMutableData *d = [NSMutableData secureDataWithLength:sizeof(int64_t)];

        *(int64_t *)d.mutableBytes = i;
        return setKeychainData(d, key, authenticated);
    }
}

int64_t getKeychainInt(NSString *key, NSError **error)
{
    @autoreleasepool {
        NSData *d = getKeychainData(key, error);

        return (d.length == sizeof(int64_t)) ? *(int64_t *)d.bytes : 0;
    }
}

BOOL setKeychainString(NSString *s, NSString *key, BOOL authenticated)
{
    @autoreleasepool {
        NSData *d = (s) ? CFBridgingRelease(CFStringCreateExternalRepresentation(SecureAllocator(), (CFStringRef)s,
                                                                                 kCFStringEncodingUTF8, 0)) : nil;

        return setKeychainData(d, key, authenticated);
    }
}

NSString *getKeychainString(NSString *key, NSError **error)
{
    @autoreleasepool {
        NSData *d = getKeychainData(key, error);

        return (d) ? CFBridgingRelease(CFStringCreateFromExternalRepresentation(SecureAllocator(), (CFDataRef)d,
                                                                                kCFStringEncodingUTF8)) : nil;
    }
}

BOOL setKeychainDict(NSDictionary *dict, NSString *key, BOOL authenticated)
{
    @autoreleasepool {
        NSData *d = (dict) ? [NSKeyedArchiver archivedDataWithRootObject:dict] : nil;
        
        return setKeychainData(d, key, authenticated);
    }
}

 NSDictionary *getKeychainDict(NSString *key, NSError **error)
{
    @autoreleasepool {
        NSData *d = getKeychainData(key, error);
        
        return (d) ? [NSKeyedUnarchiver unarchiveObjectWithData:d] : nil;
    }
}

@interface BRWalletManager()

@property (nonatomic, strong) BRWallet *wallet;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NSArray *currencyPrices;
@property (nonatomic, strong) NSNumber *localPrice;
@property (nonatomic, strong) id protectedObserver;

@end

@implementation BRWalletManager

+ (instancetype)sharedInstance
{
    static id singleton = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        singleton = [self new];
    });

    return singleton;
}

- (instancetype)init
{
    if (! (self = [super init])) return nil;

    [NSManagedObject setConcurrencyType:NSPrivateQueueConcurrencyType];
    self.sequence = [BIP44Sequence new];
    self.mnemonic = [BRBIP39Mnemonic new];
    self.reachability = [Reachability reachabilityForInternetConnection];
    _format = [NSNumberFormatter new];
    self.format.lenient = YES;
    self.format.numberStyle = NSNumberFormatterCurrencyStyle;
    self.format.generatesDecimalNumbers = YES;
    self.format.negativeFormat = [@"- " stringByAppendingString:self.format.positiveFormat];
    self.format.currencyCode = @"XBT";
    self.format.currencySymbol = BITS NARROW_NBSP;
    self.format.maximumFractionDigits = 2;
    self.format.minimumFractionDigits = 0; // iOS 8 bug, minimumFractionDigits now has to be set after currencySymbol
    self.format.maximum = @(MAX_MONEY/(int64_t)pow(10.0, self.format.maximumFractionDigits));
    _localFormat = [NSNumberFormatter new];
    self.localFormat.lenient = YES;
    self.localFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    self.localFormat.generatesDecimalNumbers = YES;
    self.localFormat.negativeFormat = self.format.negativeFormat;

    self.protectedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationProtectedDataDidBecomeAvailable object:nil
        queue:nil usingBlock:^(NSNotification *note) {
            [self protectedInit];
        }];

    if ([UIApplication sharedApplication].protectedDataAvailable) [self protectedInit];
    return self;
}

- (void)protectedInit
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];

    if (self.protectedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.protectedObserver];
    self.protectedObserver = nil;
    _currencyCodes = [defs arrayForKey:CURRENCY_CODES_KEY];
    _currencyNames = [defs arrayForKey:CURRENCY_NAMES_KEY];
    _currencyPrices = [defs arrayForKey:CURRENCY_PRICES_KEY];
    self.localCurrencyCode = ([defs stringForKey:LOCAL_CURRENCY_CODE_KEY]) ?
        [defs stringForKey:LOCAL_CURRENCY_CODE_KEY] : [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    dispatch_async(dispatch_get_main_queue(), ^{ [self updateExchangeRate]; });
}

- (void)dealloc
{
    if (self.protectedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.protectedObserver];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (BRWallet *)wallet
{
    if (_wallet) return _wallet;

    if (getKeychainData(SEED_KEY, nil)) { // upgrade from old keychain scheme
        @autoreleasepool {
            NSString *seedPhrase = getKeychainString(MNEMONIC_KEY, nil);

            NSLog(@"upgrading to authenticated keychain scheme");
            if (! setKeychainData([self.sequence masterPublicKeyFromSeed:[self.mnemonic deriveKeyFromPhrase:seedPhrase
                                   withPassphrase:nil]], MASTER_PUBKEY_KEY, NO)) return _wallet;
            if (setKeychainString(seedPhrase, MNEMONIC_KEY, YES)) setKeychainData(nil, SEED_KEY, NO);
        }
    }

    uint64_t feePerKb = 0;
    NSData *mpk = self.masterPublicKey;

    if (! mpk) return _wallet;

    @synchronized(self) {
        if (_wallet) return _wallet;

        _wallet =
            [[BRWallet alloc] initWithContext:[NSManagedObject context] sequence:self.sequence
            masterPublicKey:mpk seed:^NSData *(NSString *authprompt, uint64_t amount) {
                return [self seedWithPrompt:authprompt forAmount:amount];
            }];

        _wallet.feePerKb = DEFAULT_FEE_PER_KB;
        feePerKb = [[NSUserDefaults standardUserDefaults] doubleForKey:FEE_PER_KB_KEY];
        if (feePerKb >= MIN_FEE_PER_KB && feePerKb <= MAX_FEE_PER_KB) _wallet.feePerKb = feePerKb;

        // verify that keychain matches core data, with different access and backup policies it's possible to diverge
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BRKey *k = [BRKey keyWithPublicKey:[self.sequence publicKey:0 internal:NO masterPublicKey:mpk]];

            if (_wallet.allReceiveAddresses.count > 0 && k && ! [_wallet containsAddress:k.address]) {
                NSLog(@"wallet doesn't contain address: %@", k.address);
// deadpool: This breaks testing when using several different platforms
// Possible solution: exclude normal operations with wallet when running tests
//#if DEBUG
//                abort(); // don't wipe core data for debug builds
//#else
                [[NSManagedObject context] performBlockAndWait:^{
                    [BRAddressEntity deleteObjects:[BRAddressEntity allObjects]];
                    [BRTransactionEntity deleteObjects:[BRTransactionEntity allObjects]];
                    [BRTxMetadataEntity deleteObjects:[BRTxMetadataEntity allObjects]];
                    [NSManagedObject saveContext];
                }];

                _wallet = nil;

                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:BRWalletManagerSeedChangedNotification
                     object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:BRWalletBalanceChangedNotification
                     object:nil];
                });
//#endif
            }
        });

        return _wallet;
    }
}

// true if keychain is available and we know that no wallet exists on it
- (BOOL)noWallet
{
    NSError *error = nil;

    if (_wallet) return NO;
    if (getKeychainData(MASTER_PUBKEY_KEY, &error) || error) return NO;
    if (getKeychainData(SEED_KEY, &error) || error) return NO; // check for old keychain scheme
    return YES;
}

// true if this is a "watch only" wallet with no signing ability
- (BOOL)watchOnly
{
    return (self.masterPublicKey && self.masterPublicKey.length == 0) ? YES : NO;
}

// master public key used to generate wallet addresses
- (NSData *)masterPublicKey
{
    return [getKeychainData(MASTER_PUBKEY_KEY, nil) subdataWithRange:NSMakeRange(0, 69)];
}

// requesting seedPhrase will trigger authentication
- (NSString *)seedPhrase
{
    return [self seedPhraseWithPrompt:nil];
}

- (void)setSeedPhrase:(NSString *)seedPhrase
{
    @autoreleasepool { // @autoreleasepool ensures sensitive data will be dealocated immediately
        if (seedPhrase) seedPhrase = [self.mnemonic normalizePhrase:seedPhrase];

        [[NSManagedObject context] performBlockAndWait:^{
            [BRAddressEntity deleteObjects:[BRAddressEntity allObjects]];
            [BRTransactionEntity deleteObjects:[BRTransactionEntity allObjects]];
            [BRTxMetadataEntity deleteObjects:[BRTxMetadataEntity allObjects]];
            [NSManagedObject saveContext];
        }];

        setKeychainData(nil, CREATION_TIME_KEY, NO);
        setKeychainData(nil, MASTER_PUBKEY_KEY, NO);
        setKeychainData(nil, SPEND_LIMIT_KEY, NO);
        setKeychainData(nil, AUTH_PRIVKEY_KEY, NO);

        if (! setKeychainString(seedPhrase, MNEMONIC_KEY, YES)) {
            NSLog(@"[ERROR] Error setting wallet seed");
            return;
        }

        NSData *masterPubKey = (seedPhrase) ? [self.sequence masterPublicKeyFromSeed:[self.mnemonic
                                               deriveKeyFromPhrase:seedPhrase withPassphrase:nil]] : nil;

        if ([seedPhrase isEqual:@"wipe"]) masterPubKey = [NSData data]; // watch only wallet
        setKeychainData(masterPubKey, MASTER_PUBKEY_KEY, NO);
        _wallet = nil;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BRWalletManagerSeedChangedNotification object:nil];
    });
}

// interval since refrence date, 00:00:00 01/01/01 GMT
- (NSTimeInterval)seedCreationTime
{
    NSData *d = getKeychainData(CREATION_TIME_KEY, nil);

    if (d.length == sizeof(NSTimeInterval)) return *(const NSTimeInterval *)d.bytes;
    return (self.watchOnly) ? 0 : BIP39_CREATION_TIME;
}

// private key for signing authenticated api calls
- (NSString *)authPrivateKey
{
    @autoreleasepool {
        NSString *privKey = getKeychainString(AUTH_PRIVKEY_KEY, nil);

        if (! privKey) {
            NSData *seed = [self.mnemonic deriveKeyFromPhrase:getKeychainString(MNEMONIC_KEY, nil) withPassphrase:nil];

            privKey = [[BRBIP32Sequence new] authPrivateKeyFromSeed:seed];
            setKeychainString(privKey, AUTH_PRIVKEY_KEY, NO);
        }

        return privKey;
    }
}

- (NSDictionary *)userAccount
{
    return getKeychainDict(USER_ACCOUNT_KEY, nil);
}

- (void)setUserAccount:(NSDictionary *)userAccount
{
    setKeychainDict(userAccount, USER_ACCOUNT_KEY, NO);
}

- (void)setSeedCreationTime:(NSTimeInterval)seedCreationTime {
    // we store the wallet creation time on the keychain because keychain data persists even when an app is deleted
    setKeychainData([NSData dataWithBytes:&seedCreationTime length:sizeof(seedCreationTime)], CREATION_TIME_KEY, NO);
}

// generates a random seed, saves to keychain and returns the associated seedPhrase
- (NSString *)generateRandomSeed
{
    @autoreleasepool {
        NSMutableData *entropy = [NSMutableData secureDataWithLength:SEED_ENTROPY_LENGTH];
        NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];

        if (SecRandomCopyBytes(kSecRandomDefault, entropy.length, entropy.mutableBytes) != 0) return nil;

        NSString *phrase = [self.mnemonic encodePhrase:entropy];

        self.seedPhrase = phrase;
        
        
        [self setSeedCreationTime:time];
        return phrase;
    }
}

// authenticates user and returns seed
- (NSData *)seedWithPrompt:(NSString *)authprompt forAmount:(uint64_t)amount
{
    @autoreleasepool {
        BOOL touchid = (self.wallet.totalSent + amount < getKeychainInt(SPEND_LIMIT_KEY, nil)) ? YES : NO;

        if (! [self authenticateWithPrompt:authprompt andTouchId:touchid]) return nil;
        // BUG: if user manually chooses to enter pin, the touch id spending limit is reset, but the tx being authorized
        // still counts towards the next touch id spending limit
        if (! touchid) setKeychainInt(self.wallet.totalSent + amount + self.spendingLimit, SPEND_LIMIT_KEY, NO);
        return [self.mnemonic deriveKeyFromPhrase:getKeychainString(MNEMONIC_KEY, nil) withPassphrase:nil];
    }
}

// authenticates user and returns seedPhrase
- (NSString *)seedPhraseWithPrompt:(NSString *)authprompt
{
    @autoreleasepool {
        return ([self authenticateWithPrompt:authprompt andTouchId:NO]) ? getKeychainString(MNEMONIC_KEY, nil) : nil;
    }
}

// MARK: - authentication

// prompts user to authenticate with touch id or passcode
- (BOOL)authenticateWithPrompt:(NSString *)authprompt andTouchId:(BOOL)touchId
{
    return YES;
}

- (BOOL)isTestnet {
#if BITCOIN_TESTNET
    return true;
#else 
    return false;
#endif
}

// amount that can be spent using touch id without pin entry
- (uint64_t)spendingLimit
{
    // it's ok to store this in userdefaults because increasing the value only takes effect after successful pin entry
    if (! [[NSUserDefaults standardUserDefaults] objectForKey:SPEND_LIMIT_AMOUNT_KEY]) return SATOSHIS;

    return [[NSUserDefaults standardUserDefaults] doubleForKey:SPEND_LIMIT_AMOUNT_KEY];
}

- (void)setSpendingLimit:(uint64_t)spendingLimit
{
    if (setKeychainInt((spendingLimit > 0) ? self.wallet.totalSent + spendingLimit : 0, SPEND_LIMIT_KEY, NO)) {
        // use setDouble since setInteger won't hold a uint64_t
        [[NSUserDefaults standardUserDefaults] setDouble:spendingLimit forKey:SPEND_LIMIT_AMOUNT_KEY];
    }
}

// last known time from an ssl server connection
- (NSTimeInterval)secureTime
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:SECURE_TIME_KEY];
}

// MARK: - exchange rate

- (double)localCurrencyPrice
{
    return self.localPrice.doubleValue;
}

// local currency ISO code
- (void)setLocalCurrencyCode:(NSString *)code
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSUInteger i = [_currencyCodes indexOfObject:code];

    if (i == NSNotFound) {
        code = DEFAULT_CURRENCY_CODE;
        i = [_currencyCodes indexOfObject:DEFAULT_CURRENCY_CODE];
    }
    _localCurrencyCode = [code copy];

    if (i < _currencyPrices.count && self.secureTime + 3*24*60*60 > [NSDate timeIntervalSinceReferenceDate]) {
        self.localPrice = _currencyPrices[i]; // don't use exchange rate data more than 72hrs out of date
    }
    else self.localPrice = @(0);

    self.localFormat.currencyCode = _localCurrencyCode;
    self.localFormat.maximum =
        [[NSDecimalNumber decimalNumberWithDecimal:self.localPrice.decimalValue]
         decimalNumberByMultiplyingBy:(id)[NSDecimalNumber numberWithLongLong:MAX_MONEY/SATOSHIS]];

    if ([self.localCurrencyCode isEqual:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode]]) {
        [defs removeObjectForKey:LOCAL_CURRENCY_CODE_KEY];
    }
    else [defs setObject:self.localCurrencyCode forKey:LOCAL_CURRENCY_CODE_KEY];

    if (! _wallet) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BRWalletBalanceChangedNotification object:nil];
    });
}

- (void)loadTicker:(NSString *)tickerURL withJSONKey:(NSString *)jsonKey failoverHandler:(void (^)(void))failover
{
    if (self.reachability.currentReachabilityStatus == NotReachable) return;
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:tickerURL]
                                cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];

    //NSLog(@"%@", req.URL.absoluteString);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:req
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            if (failover) failover();
            return;
        }
        
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSMutableArray *codes = [NSMutableArray array], *names = [NSMutableArray array], *rates =[NSMutableArray array];
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) { // store server timestamp
            NSString *date = ((NSHTTPURLResponse *)response).allHeaderFields[@"Date"];
            NSTimeInterval now = ([[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:nil]
                                   matchesInString:(date ? date : @"") options:0
                                   range:NSMakeRange(0, date.length)].lastObject).date.timeIntervalSinceReferenceDate;
            
            if (now > self.secureTime) [defs setDouble:now forKey:SECURE_TIME_KEY];
        }
        
        if (error || ! [json isKindOfClass:[NSDictionary class]] || ! [json[jsonKey] isKindOfClass:[NSArray class]]) {
            NSLog(@"unexpected response from %@:\n%@", req.URL.host,
                  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if (failover) failover();
            return;
        }
        
        for (NSDictionary *d in json[jsonKey]) {
            if (! [d isKindOfClass:[NSDictionary class]] || ! [d[@"code"] isKindOfClass:[NSString class]] ||
                ! [d[@"name"] isKindOfClass:[NSString class]] || ! [d[@"rate"] isKindOfClass:[NSNumber class]]) {
                NSLog(@"unexpected response from %@:\n%@", req.URL.host,
                      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                if (failover) failover();
                return;
            }
            
            if ([d[@"code"] isEqual:@"BTC"]) continue;
            [codes addObject:d[@"code"]];
            [names addObject:d[@"name"]];
            [rates addObject:d[@"rate"]];
        }
        
        _currencyCodes = codes;
        _currencyNames = names;
        _currencyPrices = rates;
        //self.localCurrencyCode = _localCurrencyCode; // update localCurrencyPrice and localFormat.maximum
        [defs setObject:self.currencyCodes forKey:CURRENCY_CODES_KEY];
        [defs setObject:self.currencyNames forKey:CURRENCY_NAMES_KEY];
        [defs setObject:self.currencyPrices forKey:CURRENCY_PRICES_KEY];
        [defs synchronize];
        NSLog(@"exchange rate updated to %@/%@", [self localCurrencyStringForAmount:SATOSHIS],
              [self stringForAmount:SATOSHIS]);
        
        [self updateFeePerKb];
    }] resume];
}

- (void)updateExchangeRate
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateExchangeRate) object:nil];
    [self performSelector:@selector(updateExchangeRate) withObject:nil afterDelay:60.0];

    [self loadTicker:TICKER_URL withJSONKey:@"data" failoverHandler:^{
        [self loadTicker:TICKER_FAILOVER_URL withJSONKey:@"body" failoverHandler:nil];
    }];
}

// MARK: - floating fees

- (void)updateFeePerKb
{
    if (self.reachability.currentReachabilityStatus == NotReachable) return;

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FEE_PER_KB_URL]
                                cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    
    //NSLog(@"%@", req.URL.absoluteString);

    [[[NSURLSession sharedSession] dataTaskWithRequest:req
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"unable to fetch fee-per-kb: %@", error);
            return;
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

        if (error || ! [json isKindOfClass:[NSDictionary class]] ||
            ! [json[@"fee_per_kb"] isKindOfClass:[NSNumber class]]) {
            NSLog(@"unexpected response from %@:\n%@", req.URL.host,
                  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return;
        }

        uint64_t newFee = [json[@"fee_per_kb"] unsignedLongLongValue];
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        
        if (newFee >= MIN_FEE_PER_KB && newFee <= MAX_FEE_PER_KB && newFee != [defs doubleForKey:FEE_PER_KB_KEY]) {
            NSLog(@"setting new fee-per-kb %lld", newFee);
            [defs setDouble:newFee forKey:FEE_PER_KB_KEY]; // use setDouble since setInteger won't hold a uint64_t
            _wallet.feePerKb = newFee;
        }
    }] resume];
}

// MARK: - string helpers
- (int64_t)amountForString:(NSString *)string
{
    if (string.length == 0) return 0;
    return [[NSDecimalNumber decimalNumberWithDecimal:[self.format numberFromString:string].decimalValue]
             decimalNumberByMultiplyingByPowerOf10:self.format.maximumFractionDigits].longLongValue;
}

- (NSString *)stringForAmount:(int64_t)amount
{
    return [self.format stringFromNumber:[(id)[NSDecimalNumber numberWithLongLong:amount]
            decimalNumberByMultiplyingByPowerOf10:-self.format.maximumFractionDigits]];
}

// NOTE: For now these local currency methods assume that a satoshi has a smaller value than the smallest unit of any
// local currency. They will need to be revisited when that is no longer a safe assumption.
- (int64_t)amountForLocalCurrencyString:(NSString *)string
{
    if ([string hasPrefix:@"<"]) string = [string substringFromIndex:1];

    NSNumber *n = [self.localFormat numberFromString:string];
    int64_t price = [[NSDecimalNumber decimalNumberWithDecimal:self.localPrice.decimalValue]
                      decimalNumberByMultiplyingByPowerOf10:self.localFormat.maximumFractionDigits].longLongValue,
            local = [[NSDecimalNumber decimalNumberWithDecimal:n.decimalValue]
                      decimalNumberByMultiplyingByPowerOf10:self.localFormat.maximumFractionDigits].longLongValue,
            overflowbits = 0, p = 10, min, max, amount;

    if (local == 0 || price < 1) return 0;
    while (llabs(local) + 1 > INT64_MAX/SATOSHIS) {
        local /= 2;
        overflowbits++; // make sure we won't overflow an int64_t
    }
    min = llabs(local)*SATOSHIS/price + 1; // minimum amount that safely matches local currency string
    max = (llabs(local) + 1)*SATOSHIS/price - 1; // maximum amount that safely matches local currency string
    amount = (min + max)/2; // average min and max
    while (overflowbits > 0) {
        local *= 2;
        min *= 2;
        max *= 2;
        amount *= 2;
        overflowbits--;
    }

    if (amount >= MAX_MONEY) return (local < 0) ? -MAX_MONEY : MAX_MONEY;
    while ((amount/p)*p >= min && p <= INT64_MAX/10) p *= 10; // lowest decimal precision matching local currency string
    p /= 10;
    return (local < 0) ? -(amount/p)*p : (amount/p)*p;
}

- (NSString *)localCurrencyStringForAmount:(int64_t)amount
{
    if (amount == 0) return [self.localFormat stringFromNumber:@(0)];
    if (self.localPrice.doubleValue <= DBL_EPSILON) return @""; // no exchange rate data

    NSDecimalNumber *n = [[[NSDecimalNumber decimalNumberWithDecimal:self.localPrice.decimalValue]
                           decimalNumberByMultiplyingBy:(id)[NSDecimalNumber numberWithLongLong:llabs(amount)]]
                          decimalNumberByDividingBy:(id)[NSDecimalNumber numberWithLongLong:SATOSHIS]],
                     *min = [[NSDecimalNumber one]
                             decimalNumberByMultiplyingByPowerOf10:-self.localFormat.maximumFractionDigits];

    // if the amount is too small to be represented in local currency (but is != 0) then return a string like "$0.01"
    if ([n compare:min] == NSOrderedAscending) n = min;
    if (amount < 0) n = [n decimalNumberByMultiplyingBy:(id)[NSDecimalNumber numberWithInt:-1]];
    return [self.localFormat stringFromNumber:n];
}

@end
