//
//  ReservationModel.h
//  extraSlice
//
//  Created by Administrator on 27/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReservationModel : NSObject
@property(strong, nonatomic) NSNumber *reservedByUser;
@property(strong, nonatomic) NSNumber *reservedByOrg;
@property(strong, nonatomic) NSString *reservedByOrgName;
@property(strong, nonatomic) NSString *startDate;
@property(strong, nonatomic) NSString *endTime;
@property(strong, nonatomic) NSNumber *duration;
@property(strong, nonatomic) NSString *resourceType;
@property(strong, nonatomic) NSNumber *resourceTypeId;
@property(strong, nonatomic) NSNumber *resourceId;
@property(strong, nonatomic) NSString *resourceName;
@property(strong, nonatomic) NSNumber *smSpaceId;
@property(strong, nonatomic) NSString *smSpaceName;
@property(strong, nonatomic) NSNumber *reservationId;
@property(strong, nonatomic) NSString *reservedByUserName;
@property(strong, nonatomic) NSString *reservationName;
@property(strong, nonatomic) NSString *description;
- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (ReservationModel *)initWithDictionary:(NSDictionary*)dictionary;
@end
