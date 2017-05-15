//
//  TransactionDAO.h
//  WalkNPay
//
//  Created by Administrator on 17/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionModel.h"

@interface TransactionDAO : NSObject
-(TransactionModel *) addTransaction:(NSNumber *)userId StoreId:(NSNumber *)storeId Coupon:(NSMutableArray *) couponList PayMethod:(NSString *) payMethod;
-(NSString *) deleteTransaction:(NSNumber *)userId OrderId:(NSNumber *)orderId;
-(NSString *) updateTransactionToPurchase:(NSNumber *)userId OrderId:(NSNumber *)orderId;
-(NSString *) sendReceiptByEmail:(NSNumber *)userId OrderId:(NSNumber *)orderId;
-(NSDictionary *) getAllRecieptsForuser:(NSNumber *)userId SoreId:(NSNumber *)storeId;
-(NSDictionary *) getAllRecieptsForuserWithOffset:(NSNumber *)userId StoreId:(NSNumber *)storeId Limit:(int) limit Offset:(int ) offset;
@end
