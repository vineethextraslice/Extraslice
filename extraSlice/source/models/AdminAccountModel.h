//
//  AdminAccountModel.h
//  extraSlice
//
//  Created by Administrator on 21/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdminAccountModel : NSObject

@property(strong, nonatomic) NSString *strpSecKey;
@property(strong, nonatomic) NSString *strpPubKey;
@property(strong, nonatomic) NSString *paypalClientId;
@property(strong, nonatomic) NSString *paypalEnv;
@property(strong, nonatomic) NSString *about;
@property(strong, nonatomic) NSString *contactNo;
@property(strong, nonatomic) NSString *contactEmail;
@property(strong, nonatomic) NSString *termsNCondUrl;
@property(strong, nonatomic) NSString *privacyPolicyUrl;

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (AdminAccountModel *)initWithDictionary:(NSDictionary*)dictionary;

@end
