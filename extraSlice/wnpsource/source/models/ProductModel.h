//
//  ProductModel.h
//  WalkNPay
//
//  Created by Irshad on 11/28/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductModel : NSObject
@property(strong,nonatomic) NSString *code;
@property(strong,nonatomic) NSNumber *storeId;
@property(strong,nonatomic) NSString *name;
@property(strong,nonatomic) NSString *prodDescription;
@property(strong,nonatomic) NSNumber *id;
@property(strong,nonatomic) NSNumber *storeItemId;
@property(strong,nonatomic) NSNumber *price;
@property(strong,nonatomic) NSNumber *taxPercentage;
@property(strong,nonatomic) NSNumber *availableQty;
@property(strong,nonatomic) NSNumber *rewardsAmount;
@property(strong,nonatomic) NSNumber *taxAmount;
@property(strong,nonatomic) NSNumber *purchasedQuantity;
@property(strong,nonatomic) NSNumber *offerAppliedQty;
@property(strong,nonatomic) NSNumber *offerAppliedAmt;
@property(nonatomic) BOOL active;
@property(nonatomic) BOOL onDemandItem;

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(ProductModel *)initWithDictionary:(NSDictionary*)dictionary;
@end
