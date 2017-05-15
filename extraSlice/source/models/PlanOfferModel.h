//
//  PlanOfferModel.h
//  extraSlice
//
//  Created by Administrator on 07/10/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlanOfferModel : NSObject
@property(strong, nonatomic) NSString *offerName;
@property(strong, nonatomic) NSString *offerShortDesc;
@property(strong, nonatomic) NSString *applicableTo;
@property(strong, nonatomic) NSString *offerType;
@property(strong, nonatomic) NSNumber *offerValue ;
@property(strong, nonatomic) NSNumber *offerId ;
@property(strong, nonatomic) NSString *commitmentType;
@property(strong, nonatomic) NSNumber *commitmentValue ;
@property(strong, nonatomic) NSString *monthsExcluded;
@property(strong, nonatomic) NSString *validFrom;
@property(strong, nonatomic) NSString *validTill;

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (PlanOfferModel *)initWithDictionary:(NSDictionary*)dictionary;
@end

