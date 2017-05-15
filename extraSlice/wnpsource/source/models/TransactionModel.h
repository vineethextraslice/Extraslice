//
//  TransactionModel.h
//  WalkNPay
//
//  Created by Irshad on 12/1/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransactionModel : NSObject
@property(strong,nonatomic) NSNumber *orderId;
@property(strong,nonatomic) NSString *userName;
@property(strong,nonatomic) NSString *subTotal;
@property(strong,nonatomic) NSNumber *storeId;
@property(strong,nonatomic) NSNumber *userId;
@property(strong,nonatomic) NSString *grossTotal;
@property(strong,nonatomic) NSString *totalTax;
@property(strong,nonatomic) NSString *offerTotal;
@property(strong,nonatomic) NSString *payableTotal;
@property(strong,nonatomic) NSString *orderDate;
@property(strong,nonatomic) NSString *storeName;
@property(strong,nonatomic) NSString *payMethod;
@property(strong,nonatomic) NSMutableArray *couponList;
@property(strong,nonatomic) NSMutableArray *itemList;
@property(strong,nonatomic) NSDictionary *recieptStore;
@property(strong,nonatomic) NSString *deviceType;
@property(strong,nonatomic) NSString *receiptFor;

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
- (TransactionModel *)initWithDictionary:(NSDictionary*)dictionary;
@end
