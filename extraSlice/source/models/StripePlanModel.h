//
//  StripePlanModel.h
//  extraSlice
//
//  Created by Administrator on 24/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StripePlanModel : NSObject
@property(strong, nonatomic) NSString *stripePlanId;
@property(strong, nonatomic) NSNumber *eslicePlanId;
@property(strong, nonatomic) NSString *stripePlanName;
@property(strong, nonatomic) NSString *resIds;
@property(strong, nonatomic) NSNumber *id;

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (StripePlanModel *)initWithDictionary:(NSDictionary*)dictionary;
@end
