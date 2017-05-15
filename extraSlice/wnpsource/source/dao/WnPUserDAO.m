//
//  UserDAO.m
//  WalkNPay
//
//  Created by Administrator on 17/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import "WnPUserDAO.h"
#import "NSString+AESCrypt.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "WnPWebServiceDAO.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"
@implementation WnPUserDAO

-(NSString *) updateESliceUser:(UserModel *)esModel{
    WnPUtilities *utils=[[WnPUtilities alloc]init];
    NSString *urlString =@"user/updateESliceUser";
    WnPUserModel *userModel =[[WnPUserModel alloc] init];
    userModel.userName=esModel.userName;
    userModel.email=esModel.userName;
    userModel.authCode =[utils encode: esModel.userId.stringValue];
    userModel.userId = esModel.userId;
    userModel.roleId = [NSNumber numberWithInt:0];
    NSString *jsonString= [userModel convertObjectToJsonString:YES];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    NSString *status = @"";
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
       status = @"Error. Failed get user details";
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        status = @"Success";
    }else{
        status = [result objectForKey:@"ERRORMESSAGE"] ;
    }
    return status;

}
-(WnPUserModel *) authenticateESliceUser:(UserModel *)esModel{
    WnPUtilities *utils=[[WnPUtilities alloc]init];
    NSString *urlString =@"user/authenticateESliceUser";
    WnPUserModel *userModel =[[WnPUserModel alloc] init];
    userModel.userName=esModel.userName;
    userModel.email=esModel.userName;
    userModel.password =esModel.password;
    userModel.authCode =[utils encode: esModel.userId.stringValue];
    userModel.userId = [NSNumber numberWithInt:0];
    userModel.roleId = [NSNumber numberWithInt:0];
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    [request setValue:version forKey:@"APPVERSION"];
    [request setValue:[NSString stringWithFormat:@"%f",ver] forKey:@"OSVERSION"];
    [request setValue:@"iOS" forKey:@"DEVICETYPE"];
    [request setValue:[userModel dictionaryWithPropertiesOfObject:userModel] forKey:@"UserModel"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get user details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSDictionary *userDictionary =[result objectForKey:@"User"];
        userModel = [userModel initWithDictionary:userDictionary];
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return userModel;

}

-(WnPUserModel *) getUser:(NSString *)userName Password:(NSString *)password{
    WnPUtilities *utils=[[WnPUtilities alloc]init];
    NSString *urlString =@"user/getUserByUserName";
    WnPUserModel *userModel =[[WnPUserModel alloc] init];
    userModel.userName=userName;
    userModel.email=userName;
    userModel.password =[utils encode:password];
    userModel.userId = [NSNumber numberWithInt:0];
    userModel.roleId = [NSNumber numberWithInt:0];
    NSString *jsonString= [userModel convertObjectToJsonString:YES];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get user details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSDictionary *userDictionary =[result objectForKey:@"User"]; userModel = [userModel initWithDictionary:userDictionary];
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return userModel;
}


-(WnPUserModel *) createUser:(NSString *)userName Password:(NSString *)password{
    WnPUtilities *utils=[[WnPUtilities alloc]init];
    NSString *urlString =@"user/addUser";
    WnPUserModel *userModel =[[WnPUserModel alloc] init];
    userModel.userName=userName;
    userModel.email=userName;
    userModel.password =[utils encode:password];
    userModel.userId = [NSNumber numberWithInt:0];
    userModel.roleId = [NSNumber numberWithInt:0];
    NSString *jsonString= [userModel convertObjectToJsonString:YES];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to create user." userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSDictionary *userDictionary =[result objectForKey:@"User"]; userModel = [userModel initWithDictionary:userDictionary];
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return userModel;
}


-(NSString *) resetPassword:(NSString *)userName{
    NSString *urlString =@"user/resetPassword";
    WnPUserModel *userModel =[[WnPUserModel alloc] init];
    userModel.userName=userName;
    userModel.email=userName;
    NSString *jsonString= [userModel convertObjectToJsonString:YES];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        return @"Failed to reset password. Please try again";
    }else if([[result objectForKey:@"STATUS"] isEqual:@"SUCCESS"]){
        return @"SUCCESS";
    }else{
        return[result objectForKey:@"ERRORMESSAGE"];
    }
    
}

-(NSString *) resendVericationCode:(WnPUserModel *)userModel{
    NSString *urlString =@"user/resendVerificationEmail";
    NSString *jsonString= [userModel convertObjectToJsonString:YES];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        return @"Failed to reset password. Please try again";
    }else if([[result objectForKey:@"STATUS"] isEqual:@"SUCCESS"]){
        return @"SUCCESS";
    }else{
        return[result objectForKey:@"ERRORMESSAGE"];
    }
    
    
}
-(WnPUserModel *) updateUser:(WnPUserModel *)userModel {
    NSString *urlString =@"user/updateUser";
    NSString *jsonString= [userModel convertObjectToJsonString:YES];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get user details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSDictionary *userDictionary =[result objectForKey:@"User"]; userModel = [userModel initWithDictionary:userDictionary];
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return userModel;
    
}

@end
