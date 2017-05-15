//
//  ResourceTypeModel.h
//  extraSlice
//
//  Created by Administrator on 21/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourceTypeModel : NSObject

@property(strong, nonatomic) NSString *resourceTypeName;
@property(strong, nonatomic) NSString *planLimitUnit;
@property(strong, nonatomic) NSString *allowUsageBy;
@property(strong, nonatomic) NSNumber *resourceTypeId ;
@property(strong, nonatomic) NSNumber *planLimit ;
@property(strong, nonatomic) NSNumber *currentUsage ;
@property(strong, nonatomic) NSNumber *planSplPrice ;
@property(strong, nonatomic) NSNumber *orgId ;
@property(strong, nonatomic) NSString *resourceDesc ;

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (ResourceTypeModel *)initWithDictionary:(NSDictionary*)dictionary;
@end
