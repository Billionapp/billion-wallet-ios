//
//  BAppStructs.h
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

#ifndef BAppStructs_h
#define BAppStructs_h

typedef struct {
    uint8_t txid[32];
    uint32_t index;
} TXOutpoint;

#endif /* BAppStructs_h */
