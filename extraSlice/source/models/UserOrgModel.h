//
//  UserOrgModel.h
//  extraSlice
//
//  Created by Administrator on 30/09/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserOrgModel : NSObject
@property(strong, nonatomic) NSString *userName;
@property(strong, nonatomic) NSString *orgName;
@property(strong, nonatomic) NSString *userStatus;
@property(strong, nonatomic) NSNumber *userId ;
@property(strong, nonatomic) NSNumber *orgId ;
@property(strong, nonatomic) NSNumber *orgRoleId ;




- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (UserOrgModel *)initWithDictionary:(NSDictionary*)dictionary;
@end
