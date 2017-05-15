//
//  CouponModel.h
//  WalkNPay
//
//  Created by Irshad on 12/1/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaymentGateway.h"


@interface CouponModel : NSObject
@property(strong,nonatomic)  NSNumber *couponId;
@property(strong,nonatomic) NSNumber *storeId;
@property(strong,nonatomic) NSNumber *userId;
@property(strong,nonatomic) NSNumber *offerOnProductId;
@property(strong,nonatomic) NSNumber *noOfUsages;
@property(strong,nonatomic) NSNumber *offeredCount;
@property(strong,nonatomic) NSNumber *offeredProductId;
@property(strong,nonatomic) NSNumber *categoryId;
@property(strong,nonatomic) NSNumber *offerAbovePrice;
@property(strong,nonatomic) NSNumber *offerOnCount;
@property(strong,nonatomic) NSNumber *applicableAmount;
@property(strong,nonatomic) NSNumber *couponPrice;
@property(strong,nonatomic) NSNumber *offeredAmount;
@property(strong,nonatomic) NSNumber *offeredPerct;

@property(strong,nonatomic) NSString *couponCode;
@property(strong,nonatomic) NSString *couponType;
@property(strong,nonatomic) NSString *payBy;
@property(strong,nonatomic) NSString *reasonForFailure;
@property(strong,nonatomic) NSString *notApplicableWith;
@property(strong,nonatomic) NSString *offeredProductName;
@property(strong,nonatomic) NSString *offerOnProductName;
@property(strong,nonatomic) NSString *description;
@property(strong,nonatomic) NSString *startDate;
@property(strong,nonatomic) NSString *endDate;
@property(strong,nonatomic) NSString *applyBy;

@property(nonatomic) BOOL couponApplied;
@property(nonatomic) BOOL includeTaxInOffer;

@property(strong,nonatomic) NSNumber *recalculatedOfferedAmount;
@property(strong,nonatomic) NSNumber *offeredItemCount;
@property(strong,nonatomic) NSNumber *offeredItemAmount;
@property(strong,nonatomic) NSNumber *offeredOtherItemAmount;
@property(strong,nonatomic) NSNumber *offeredOtherItemCount;




-(void) calcualteOfferAmount:(BOOL) selected reallocate:(BOOL) reallocate ;
- (NSDictionary *) dictionaryWithAllPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
- (CouponModel *)initWithDictionary:(NSDictionary*)dictionary;
- (CouponModel *)initWithAllDictionary:(NSDictionary*)dictionary;
@end
