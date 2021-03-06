//
//  PlanModel.h
//  extraSlice
//
//  Created by Administrator on 21/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlanModel : NSObject
@property(strong, nonatomic) NSString *planName;
@property(strong, nonatomic) NSString *planDesc;
@property(strong, nonatomic) NSString *planStartDate;
@property(strong, nonatomic) NSString *planEndtDate;
@property(strong, nonatomic) NSNumber *planId ;
@property(strong, nonatomic) NSNumber *planDuarationInDays ;
@property(strong, nonatomic) NSNumber *planPrice ;
@property(strong, nonatomic) NSMutableArray *resourceTypeList ;
@property(nonatomic) BOOL purchaseOnSpot;
@property(strong, nonatomic) NSString *planDuaration;
@property(strong, nonatomic) NSNumber *subStartDay;

@property(nonatomic) BOOL isSubPlan;
@property(nonatomic) BOOL haveSubPlan;

@property(strong, nonatomic) NSNumber *noOfPlans;
@property(strong, nonatomic) NSNumber *noOfDesks;
@property(strong, nonatomic) NSNumber *noOfMembers;
@property(strong, nonatomic) NSNumber *parentPlanId;

@property(strong, nonatomic) NSMutableArray *subPlanList ;

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (PlanModel *)initWithDictionary:(NSDictionary*)dictionary;
@end
