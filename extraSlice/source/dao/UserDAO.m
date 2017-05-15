 //
//  UserDAO.m
//  WalkNPay
//
//  Created by Administrator on 17/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import "UserDAO.h"
#import "NSString+AESCrypt.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "WebServiceDAO.h"
#import "WnPConstants.h"
#import "Utilities.h"
@implementation UserDAO

-(UserModel *) getUser:(NSString *)userName Password:(NSString *)password{
    Utilities *utils=[[Utilities alloc]init];
    NSString *urlString =@"user/getUserByUserNameAndAppDetl";
    UserModel *userModel =[[UserModel alloc] init];
    userModel.userName=userName;
    userModel.email=userName;
    userModel.password =[utils encode:password];
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

    
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
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


-(UserModel *) createUser:(UserModel *)userModel AddOnList:(NSMutableArray *)addOnList UserRegCode:(NSString *) userCode{
    NSString *urlString =@"user/addUser";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    if(addOnList != nil && addOnList.count > 0){
        [request setValue:addOnList forKey:@"ResourceTypeList"];
    }
    [request setValue:userCode forKey:@"UserRegCode"];
    [request setValue:[userModel dictionaryWithPropertiesOfObject:userModel] forKey:@"User"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to create user." userInfo:nil];
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
-(NSString *) addDedicatedMembershipRequest:(UserRequestModel *) userReqModel AddOnList:(NSMutableArray *)addOnList{
    NSString *urlString =@"user/addDedicatedMembershipRequest";
    
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    if(addOnList != nil && addOnList.count > 0){
        [request setValue:addOnList forKey:@"ResourceTypeList"];
    }
  
    [request setValue:[userReqModel dictionaryWithPropertiesOfObject:userReqModel] forKey:@"User"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

   WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        return @"Failed to register your request";
    }else if([[result objectForKey:@"STATUS"] isEqual:@"SUCCESS"]){
        return @"SUCCESS";
    }else{
        return[result objectForKey:@"ERRORMESSAGE"];
    }
   
}

-(NSString *) resetPassword:(NSString *)userName{
    NSString *urlString =@"user/resetPassword";
    UserModel *userModel =[[UserModel alloc] init];
    userModel.userName=userName;
    userModel.email=userName;
    NSString *jsonString= [userModel convertObjectToJsonString:YES];
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        return @"Failed to reset password. Please try again";
    }else if([[result objectForKey:@"STATUS"] isEqual:@"SUCCESS"]){
        return @"SUCCESS";
    }else{
        return[result objectForKey:@"ERRORMESSAGE"];
    }
    
}

-(NSString *) resendVericationCode:(UserModel *)userModel{
    NSString *urlString =@"user/resendVerificationEmail";
    NSString *jsonString= [userModel convertObjectToJsonString:YES];
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        return @"Failed to reset password. Please try again";
    }else if([[result objectForKey:@"STATUS"] isEqual:@"SUCCESS"]){
        return @"SUCCESS";
    }else{
        return[result objectForKey:@"ERRORMESSAGE"];
    }
    
    
}
-(UserModel *) updateUser:(UserModel *)userModel {
    NSString *urlString =@"user/updateUser";
    NSString *jsonString= [userModel convertObjectToJsonString:YES];
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
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

-(NSString *) deleteUser:(NSNumber *) userId OrgId:(NSNumber *) orgId{
    NSString *urlString =@"user/deleteUser";
    NSMutableDictionary *requestData = [NSMutableDictionary dictionary];
    [requestData setValue:userId forKey:@"userId"];
    [requestData setValue:orgId forKey:@"orgId"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestData options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get user details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        return @"SUCCESS";
        
    }else{
         return [result objectForKey:@"ERRORMESSAGE"];
    }
}
-(NSString *) updateUserPlan:(NSNumber *) userId OrgId:(NSNumber *) orgId PlanId:(NSNumber *)planId StartDate:(NSString *) plnStartDate EndtDate:(NSString *) plnEndDate PaymentReference:(NSString *) pymntRefKey{

    NSString *urlString =@"user/updateUserPlan";
    NSMutableDictionary *requestData = [NSMutableDictionary dictionary];
    [requestData setValue:userId forKey:@"userId"];
    [requestData setValue:orgId forKey:@"orgId"];
    [requestData setValue:planId forKey:@"planId"];
    [requestData setValue:plnStartDate forKey:@"plnStartDate"];
    [requestData setValue:plnEndDate forKey:@"plnEndDate"];
    [requestData setValue:pymntRefKey forKey:@"pymntRefKey"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestData options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get user details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        return @"SUCCESS";
        
    }else{
        return [result objectForKey:@"ERRORMESSAGE"];
    }
}
/*public JSONObject deleteUserByName(String userName,String orgName)  throws CustomException{
    String urlString = Utilities.mainUrl + "/user/deleteUserByName";
    JSONObject rootObject = null;
    JSONObject model = new JSONObject();
    try {
        model.put("userName", userName);
        model.put("orgName", orgName);
        rootObject = WSConnnection.getResult(urlString, model.toString(),mContext);
    } catch (Exception e) {
        throw new CustomException(e.getLocalizedMessage());
    }
    return rootObject;
}
*/

@end
