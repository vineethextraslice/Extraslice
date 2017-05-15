//
//  ResourceModel.h
//  extraSlice
//
//  Created by Administrator on 28/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourceModel : NSObject
@property(strong, nonatomic) NSString *resourceName;
@property(strong, nonatomic) NSString *resourceDesc;
@property(strong, nonatomic) NSNumber *resourceId;
@property(strong, nonatomic) NSString *resourceType;
@property(nonatomic) BOOL isFree;
@property(strong, nonatomic) NSNumber *maxBookingDuration;
@property(strong, nonatomic) NSNumber *minSlotDuration;
@property(strong, nonatomic) NSString *imageUrl;
@property(strong, nonatomic) NSNumber *resourcePrice;
- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (ResourceModel *)initWithDictionary:(NSDictionary*)dictionary;
@end
