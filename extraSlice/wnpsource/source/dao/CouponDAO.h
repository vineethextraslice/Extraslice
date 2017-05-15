//
//  CouponDAO.h
//  WalkNPay
//
//  Created by Administrator on 29/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CouponModel.h"
#import "TransactionModel.h"
@interface CouponDAO : NSObject
-(NSMutableArray *) getAllCouponsForPurchase:(NSNumber *)userId StoreId:(NSNumber *)storeId ;
-(NSMutableArray *) getAllPrepaidCoupons:(NSNumber *)userId StoreId:(NSNumber *)storeId ;
-(NSNumber *) getPrepaidBalance:(NSNumber *)userId ;
-(TransactionModel *) addPrepaidBalance:(NSNumber *)userId CoupunIds:(NSMutableArray *) cpnIdArray CustomeCouponModel:(CouponModel *)couponModel StoreId:(NSNumber *) storeId PayWith:(NSString *) payWith ;
-(NSNumber *) updatePrepaidToComplete:(NSNumber *)userId StoreId:(NSNumber *)storeId  OrderId:(NSNumber *)orderId;
-(NSNumber *) reAllocatePrepaid:(NSNumber *)userId StoreId:(NSNumber *)storeId  OrderId:(NSNumber *)orderId;
-(NSMutableArray *) applyAllCoupons:(NSNumber *)userId StoreId:(NSNumber *)storeId CouponList:(NSArray *) cpnList;
@end
