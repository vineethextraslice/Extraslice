//
//  UserModel.h
//  WalkNPay
//
//  Created by Irshad on 11/27/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject
@property(strong, nonatomic) NSString *userName;
@property(strong, nonatomic) NSString *password;
@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) NSNumber *userId ;
@property(strong, nonatomic) NSNumber *roleId ;
@property(nonatomic) BOOL usingTempPwd;
@property(nonatomic) BOOL autoEmail;

@property(strong, nonatomic) NSString *firstName;
@property(strong, nonatomic) NSString *lastName;
@property(strong, nonatomic) NSString *roleName;
@property(strong, nonatomic) NSString *tempPassword;
@property(strong, nonatomic) NSString *verificationCode;
@property(strong, nonatomic) NSString *addressLine1;
@property(strong, nonatomic) NSString *addressLine2;
@property(strong, nonatomic) NSString *addressLine3;
@property(strong, nonatomic) NSString *zip;
@property(strong, nonatomic) NSString *state;
@property(strong,nonatomic) NSMutableArray *orgList;

@property(strong, nonatomic) NSString *userType;


- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (UserModel *)initWithDictionary:(NSDictionary*)dictionary;
@end
