//
//  OrganizationModel.h
//  extraSlice
//
//  Created by Administrator on 21/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrganizationModel : NSObject
@property(strong, nonatomic) NSString *orgName;
@property(strong, nonatomic) NSString *keyWords;
@property(strong, nonatomic) NSString *contactEmail;
@property(strong, nonatomic) NSString *contactNo;
@property(strong, nonatomic) NSString *address;
@property(strong, nonatomic) NSNumber *orgRoleId ;
@property(strong, nonatomic) NSNumber *orgId ;
@property(nonatomic) BOOL approved;
@property(nonatomic) BOOL individualRefOrg;



- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (OrganizationModel *)initWithDictionary:(NSDictionary*)dictionary;
@end
