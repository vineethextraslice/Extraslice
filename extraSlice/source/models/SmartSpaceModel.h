//
//  SmartSpaceModel.h
//  extraSlice
//
//  Created by Administrator on 27/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmartSpaceModel : NSObject
@property(strong, nonatomic) NSNumber *smSpaceId;
@property(strong, nonatomic) NSString *smSapceName;
@property(strong, nonatomic) NSString *address;
@property(strong, nonatomic) NSNumber *latitude;
@property(strong, nonatomic) NSNumber *longitude;
@property(strong, nonatomic) NSMutableArray *resourceList;
- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (SmartSpaceModel *)initWithDictionary:(NSDictionary*)dictionary;
@end
