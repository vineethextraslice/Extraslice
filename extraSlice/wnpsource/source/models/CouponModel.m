//
//  CouponModel.m
//  WalkNPay
//
//  Created by Irshad on 12/1/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "CouponModel.h"
#import "objc/runtime.h"
#import "ProductModel.h"
#import "WnPConstants.h"


@implementation CouponModel
@synthesize description =_description;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.couponId = @-1;
        self.storeId = @-1;
        self.userId = @-1;
        self.offerOnProductId = @-1;
        self.noOfUsages = @0;
        self.offeredCount = @0;
        self.offeredProductId = @-1;
        self.description=@"";
        self.categoryId = @-1;
        self.offerAbovePrice = @0;
        self.offerOnCount = @0;
        self.applicableAmount = @0;
        self.couponPrice = @0;
        self.offeredAmount = @0;
        self.offeredPerct = @0;
        
        self.couponCode=@"";
        self.couponType=@"";
        self.payBy=@"";
        self.reasonForFailure=@"";
        self.notApplicableWith=@"";
        self.offeredProductName=@"";
        self.offerOnProductName=@"";
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.000Z";
        self.startDate = @"2050-12-12";//[dateFormatter stringFromDate:yourDate];
        self.endDate = @"2050-12-12";//[dateFormatter stringFromDate:yourDate];
        self.applyBy=@"";
        self.recalculatedOfferedAmount= @0;
        self.couponApplied=FALSE;
        self.includeTaxInOffer=FALSE;
        self.offeredItemCount= @0;
        self.offeredItemAmount= @0;
        self.offeredOtherItemAmount= @0;
        self.offeredOtherItemCount= @0;
    }
    return self;
}


- (NSDictionary *) dictionaryWithAllPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        @try {
            NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
            [dict setObject:[obj valueForKey:key] forKey:key];
        }
        @catch (NSException *exception) {
            NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
            [dict setObject:@0 forKey:key];

        }
        
        
    }
    free(properties);
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *ignoredFields = [[NSMutableArray alloc] init];
    [ignoredFields addObject:@"recalculatedOfferedAmount"];
    [ignoredFields addObject:@"offeredItemCount"];
    [ignoredFields addObject:@"offeredItemAmount"];
    [ignoredFields addObject:@"offeredOtherItemAmount"];
    [ignoredFields addObject:@"offeredOtherItemCount"];
    
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if(![ignoredFields containsObject:key]){
            [dict setObject:[obj valueForKey:key] forKey:key];
        }
    }
    
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dict];
}
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:([self dictionaryWithPropertiesOfObject:self])
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
- (CouponModel *)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        NSArray*keys=[dictionary allKeys];
        for (NSString* key in keys) {
            NSString *setterStr = [NSString stringWithFormat:@"set%@%@:",
                                   [[key substringToIndex:1] capitalizedString],
                                   [key substringFromIndex:1]];
            
            if ([self respondsToSelector:NSSelectorFromString(setterStr)]) {
                NSString *valueString = [dictionary objectForKey:key];
                [self setValue:valueString forKey:key];
            }
            
        }
    }
    return self;
}

- (CouponModel *)initWithAllDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        NSArray*keys=[dictionary allKeys];
        for (NSString* key in keys) {
            NSString *setterStr = [NSString stringWithFormat:@"set%@%@:",
                                   [[key substringToIndex:1] capitalizedString],
                                   [key substringFromIndex:1]];
            
            if ([self respondsToSelector:NSSelectorFromString(setterStr)]) {
                NSString *valueString = [dictionary objectForKey:key];
                [self setValue:valueString forKey:key];
            }
            
        }
    }
    return self;
}





-(void) calcualteOfferAmount:(BOOL) selected reallocate:(BOOL) reallocate {
    PaymentGateway *pymntGway=[[PaymentGateway alloc] init];
    int totalCount = 0;
    double totalAmount = 0;
    BOOL offerApplicable = false;
    WnPConstants *wnpConst = [[WnPConstants alloc]init];
    NSMutableDictionary *itemIdList = [[NSMutableDictionary alloc]init];
    for (ProductModel *item in [wnpConst getItemsFromArray]) {
        totalCount = totalCount + item.purchasedQuantity.intValue;
        totalAmount = totalAmount + (item.purchasedQuantity.doubleValue * item.price.doubleValue);
        if (item.id.intValue == self.offerOnProductId.intValue || self.offeredProductId.intValue == item.id.intValue) {
            [itemIdList setObject:item forKey:item.id];
        }
    }
    if (self.offerOnProductId.intValue > 0) {
        int offerApplicableQty = 0;
        
        ProductModel *pm = [itemIdList objectForKey:self.offerOnProductId];
        if (pm != nil) {
            if(reallocate){
                self.offeredItemAmount = [NSNumber numberWithInt:0];
                pm.offerAppliedQty = [NSNumber numberWithInt:(pm.offerAppliedQty.intValue-self.offeredItemCount.intValue)];
                self.offeredItemCount = [NSNumber numberWithInt:0];
                pm.offerAppliedAmt =  [NSNumber numberWithDouble:(pm.offerAppliedAmt.doubleValue-self.offeredItemAmount.doubleValue)];
                self.offeredItemCount = [NSNumber numberWithInt:0];
                if (self.offeredProductId.intValue > 0){
                    ProductModel *offerModel = [itemIdList objectForKey:self.offeredProductId];
                    if(offerModel != nil){
                        offerModel.offerAppliedQty = [NSNumber numberWithInt:(offerModel.offerAppliedQty.intValue - self.offeredOtherItemCount.intValue)];
                        self.offeredOtherItemCount = [NSNumber numberWithInt:0];
                        offerModel.offerAppliedAmt = [NSNumber numberWithDouble:(offerModel.offerAppliedAmt.doubleValue - self.offeredOtherItemAmount.doubleValue)];
                        self.offeredOtherItemAmount= [NSNumber numberWithInt:0];
                    }
                }
            }
            offerApplicableQty = (pm.purchasedQuantity.intValue - pm.offerAppliedQty.intValue);
            self.recalculatedOfferedAmount =[NSNumber numberWithDouble:((offerApplicableQty * pm.price.doubleValue) - pm.offerAppliedAmt.doubleValue)];
            if ([pymntGway getTotalAmtForOffer].doubleValue < self.recalculatedOfferedAmount.doubleValue) {
                self.recalculatedOfferedAmount = [pymntGway getTotalAmtForOffer];
            }
            if (self.recalculatedOfferedAmount < 0) {
                self.recalculatedOfferedAmount = [NSNumber numberWithInt:0];
                return;
            }
            if (self.offerOnCount.intValue > 0) {
                if (offerApplicableQty >= self.offerOnCount.intValue) {
                    int actualApplicableQty = (int) (offerApplicableQty / self.offerOnCount.intValue);
                    if(actualApplicableQty > 0){
                        if (self.offeredProductId.intValue > 0) {
                            ProductModel *offeredModel = [itemIdList objectForKey:self.offeredProductId];
                            if(offeredModel != nil && offeredModel.purchasedQuantity.intValue > 0){
                                offerApplicable = [self calculateOfferOnOtherProduct:&selected actualApplicableQuantity:[NSNumber numberWithInt:actualApplicableQty] Product:offeredModel];
                                
                                
                            }else{
                                self.recalculatedOfferedAmount = 0;
                                offerApplicable = false;
                            }
                        } else {
                            if (self.offeredAmount.doubleValue > 0) {
                                offerApplicable = true;
                                if (self.offeredAmount.doubleValue <= self.recalculatedOfferedAmount.doubleValue) {
                                    self.recalculatedOfferedAmount = self.offeredAmount;
                                }
                            } else if (self.offeredPerct.doubleValue > 0) {
                                self.recalculatedOfferedAmount = [NSNumber numberWithDouble:(self.recalculatedOfferedAmount.doubleValue * self.offeredPerct.doubleValue / 100)];
                                offerApplicable = true;
                            } else if (self.offeredCount.intValue > 0) {
                                actualApplicableQty = (int) (offerApplicableQty / (self.offerOnCount.intValue+self.offeredCount.intValue));
                                if(actualApplicableQty > 0){
                                    self.recalculatedOfferedAmount = [NSNumber numberWithDouble:(actualApplicableQty * self.offeredCount.intValue * pm.price.doubleValue)];
                                    offerApplicable = true;
                                }else{
                                    self.recalculatedOfferedAmount = [NSNumber numberWithInt:0];
                                    offerApplicable = false;
                                }
                            }
                        }
                    }else{
                        self.recalculatedOfferedAmount = 0;
                        offerApplicable = false;
                    }
                    if (offerApplicable && selected) {
                        self.offeredItemCount = [NSNumber numberWithInt:(actualApplicableQty * ( self.offerOnCount.intValue+self.offeredCount.intValue))];
                        pm.offerAppliedQty = [NSNumber numberWithInt:(pm.offerAppliedQty.intValue + self.offeredItemCount.intValue)];
                    }
                }
            } else if (self.offerAbovePrice.doubleValue > 0) {
                if (self.recalculatedOfferedAmount.doubleValue >= self.offerAbovePrice.doubleValue) {
                    int actualApplicableQty = ((int) (self.recalculatedOfferedAmount.doubleValue / self.offerAbovePrice.doubleValue));
                    if(actualApplicableQty > 0){
                        if (self.offeredProductId.intValue > 0) {
                            ProductModel *offeredModel = [itemIdList objectForKey:self.offeredProductId];
                            if(offeredModel != nil && offeredModel.purchasedQuantity.intValue > 0){
                                offerApplicable = [self calculateOfferOnOtherProduct:&selected actualApplicableQuantity:[NSNumber numberWithInt:actualApplicableQty] Product:offeredModel];
                            }
                        } else {
                            if (self.offeredAmount.doubleValue > 0) {
                                offerApplicable = true;
                                if (self.offeredAmount.doubleValue <= self.recalculatedOfferedAmount.doubleValue) {
                                    self.recalculatedOfferedAmount = self.offeredAmount;
                                }
                            } else if (self.offeredPerct.doubleValue > 0) {
                                offerApplicable = true;
                                self.recalculatedOfferedAmount = [NSNumber numberWithDouble:(self.recalculatedOfferedAmount.doubleValue * self.offeredPerct.doubleValue / 100)];
                            } else if (self.offeredCount.intValue > 0) {
                                self.recalculatedOfferedAmount = [NSNumber numberWithDouble:(actualApplicableQty * self.offeredCount.intValue * pm.price.doubleValue)];
                                offerApplicable = true;
                                
                            }
                        }
                    }else{
                        self.recalculatedOfferedAmount = [NSNumber numberWithInt:0];
                        offerApplicable = false;
                    }
                    if (offerApplicable && selected) {
                        self.offeredItemAmount = self.recalculatedOfferedAmount;
                        pm.offerAppliedAmt = [NSNumber numberWithDouble:(pm.offerAppliedAmt.doubleValue + self.offeredItemAmount.doubleValue)];
                    }
                }
            }
            
        }
        
    } else {
        if (self.offerOnCount.intValue > 0) {
            if (totalCount >= self.offerOnCount.intValue) {
                double usablePrice = [pymntGway getTotalAmtForOffer].doubleValue;
                if (self.offeredAmount.doubleValue > 0) {
                    offerApplicable = true;
                    if (self.offeredAmount.doubleValue <= usablePrice) {
                        self.recalculatedOfferedAmount = self.offeredAmount;
                    } else {
                        self.recalculatedOfferedAmount = [pymntGway getTotalAmtForOffer];
                    }
                } else if (self.offeredPerct.doubleValue > 0) {
                    offerApplicable = true;
                    self.recalculatedOfferedAmount = [NSNumber numberWithDouble:([pymntGway getTotalAmtForOffer].doubleValue * self.offeredPerct.doubleValue / 100)];
                }else{
                    offerApplicable = false;
                    self.recalculatedOfferedAmount = [NSNumber numberWithInt:0];
                }
            }
        } else if (self.offerAbovePrice.doubleValue > 0) {
            if (totalAmount >= self.offerAbovePrice.doubleValue) {
                double usablePrice = [pymntGway getTotalAmtForOffer].doubleValue;
                
                if (self.offeredProductId.intValue > 0) {
                    if(reallocate){
                        ProductModel *offerModel = [itemIdList objectForKey:self.offeredProductId];
                        if(offerModel != nil){
                            offerModel.offerAppliedQty = [NSNumber numberWithInt:(offerModel.offerAppliedQty.intValue-self.offeredOtherItemCount.intValue)];
                            self.offeredOtherItemCount = [NSNumber numberWithInt:0];
                            offerModel.offerAppliedAmt = [NSNumber numberWithDouble:(offerModel.offerAppliedAmt.doubleValue - self.offeredOtherItemAmount.doubleValue)];
                            self.offeredOtherItemAmount = [NSNumber numberWithInt:0];
                        }
                    }
                    int actualApplicableQty = ((int) (usablePrice / self.offerAbovePrice.doubleValue));
                    if(actualApplicableQty > 0){
                        ProductModel *offeredModel = [itemIdList objectForKey:self.offeredProductId];
                        if(offeredModel != nil && offeredModel.purchasedQuantity.intValue > 0){
                            offerApplicable = [self calculateOfferOnOtherProduct:&selected actualApplicableQuantity:[NSNumber numberWithInt:actualApplicableQty] Product:offeredModel];
                        }else{
                            offerApplicable = false;
                            self.recalculatedOfferedAmount = [NSNumber numberWithInt:0];
                        }
                    }else{
                        offerApplicable = false;
                        self.recalculatedOfferedAmount = [NSNumber numberWithInt:0];
                    }
                }else{
                    if (self.offeredAmount.doubleValue > 0) {
                        if (self.offeredAmount.doubleValue <= usablePrice) {
                            offerApplicable = true;
                            self.recalculatedOfferedAmount = self.offeredAmount;
                        } else {
                            offerApplicable = true;
                            self.recalculatedOfferedAmount = [pymntGway getTotalAmtForOffer];
                        }
                    } else if (self.offeredPerct.doubleValue > 0) {
                        offerApplicable = true;
                        self.recalculatedOfferedAmount = [NSNumber numberWithDouble:([pymntGway getTotalAmtForOffer].doubleValue * self.offeredPerct.doubleValue / 100)];
                    }
                }
            }
        } else {
            double usablePrice = [pymntGway getTotalAmtForOffer].doubleValue;
            if (self.offeredProductId.intValue > 0) {
                int actualApplicableQty = ((int) (usablePrice / self.offerAbovePrice.doubleValue));
                if(actualApplicableQty > 0){
                    ProductModel *offeredModel = [itemIdList objectForKey:self.offeredProductId];
                    if(offeredModel != nil && offeredModel.purchasedQuantity.intValue > 0){
                        offerApplicable = [self calculateOfferOnOtherProduct:&selected actualApplicableQuantity:[NSNumber numberWithInt:actualApplicableQty] Product:offeredModel];
                    }else{
                        offerApplicable = false;
                        self.recalculatedOfferedAmount = [NSNumber numberWithInt:0];
                    }
                }else{
                    offerApplicable = false;
                    self.recalculatedOfferedAmount = [NSNumber numberWithInt:0];
                }
            }else{
                if (self.offeredAmount.doubleValue > 0) {
                    if (self.offeredAmount.doubleValue <= usablePrice) {
                        offerApplicable = true;
                        self.recalculatedOfferedAmount = self.offeredAmount;
                    } else {
                        offerApplicable = true;
                        self.recalculatedOfferedAmount = [pymntGway getTotalAmtForOffer];
                    }
                } else if (self.offeredPerct.doubleValue > 0) {
                    offerApplicable = true;
                    self.recalculatedOfferedAmount = [NSNumber numberWithDouble:([pymntGway getTotalAmtForOffer].doubleValue * self.offeredPerct.doubleValue / 100)];
                }
            }
            
        }
        
    }
    if (!offerApplicable) {
        self.recalculatedOfferedAmount = 0;
    }else{
        if ([pymntGway getTotalAmtForOffer].doubleValue < self.recalculatedOfferedAmount.doubleValue) {
            self.recalculatedOfferedAmount = [pymntGway getTotalAmtForOffer];
        }
    }
}
-(BOOL ) calculateOfferOnOtherProduct:(BOOL *) selected actualApplicableQuantity:(NSNumber *) actualApplicableQty Product:(ProductModel *)offerModel{
    BOOL offerApplicable =FALSE;
    int actualQuantity = actualApplicableQty.intValue;
    double actualPrice = offerModel.price.doubleValue;
    if (self.offeredCount.intValue > 0) {
        actualQuantity = actualApplicableQty.intValue * self.offeredCount.intValue;
        if ((offerModel.purchasedQuantity.intValue - offerModel.offerAppliedQty.intValue) < (actualApplicableQty.intValue * self.offeredCount.intValue)) {
            actualQuantity = (int)(offerModel.purchasedQuantity.intValue - offerModel.offerAppliedQty.intValue);
            if(actualQuantity <= 0){
                actualQuantity = 0;
                offerApplicable = false;
            }else{
                offerApplicable = true;
            }
        }
        self.recalculatedOfferedAmount = [NSNumber numberWithDouble:(actualQuantity * actualPrice)];
        if(self.recalculatedOfferedAmount.doubleValue > 0){
            offerApplicable = true;
            if (selected) {
                offerModel.offerAppliedQty = [NSNumber numberWithInt:(offerModel.offerAppliedQty.intValue + actualQuantity)];
                self.offeredOtherItemCount = [NSNumber numberWithInt:((int)actualQuantity)];
            }
        }else{
            self.recalculatedOfferedAmount = [NSNumber numberWithInt:0];
            offerApplicable = false;
        }
        
    } else if (self.offeredAmount.doubleValue > 0) {
        self.recalculatedOfferedAmount = self.offeredAmount;
        if (self.offeredAmount.doubleValue < ((offerModel.purchasedQuantity.intValue - offerModel.offerAppliedQty.intValue) * actualPrice)) {
            self.recalculatedOfferedAmount = [NSNumber numberWithDouble:((offerModel.purchasedQuantity.intValue - offerModel.offerAppliedQty.intValue) * actualPrice)];
            
        }
        if(self.recalculatedOfferedAmount > 0){
            offerApplicable = true;
            if (selected) {
                offerModel.offerAppliedAmt = [NSNumber numberWithDouble:(offerModel.offerAppliedAmt.doubleValue + self.recalculatedOfferedAmount.doubleValue)];
                self.offeredOtherItemAmount =self.recalculatedOfferedAmount;
            }
        }
    } else if (self.offeredPerct.doubleValue > 0) {
        self.recalculatedOfferedAmount = [NSNumber numberWithDouble:(offerModel.purchasedQuantity.intValue * offerModel.price.doubleValue * self.offeredPerct.doubleValue / 100)];
        offerApplicable = true;
        
    }else{
        self.recalculatedOfferedAmount = 0;
        offerApplicable = false;
    }
    
    return offerApplicable;
}

@end
