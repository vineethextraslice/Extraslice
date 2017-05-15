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
#import "ESliceConstants.h"
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
         if([result objectForKey:@"WARNING"] != (id)[NSNull null] && [result objectForKey:@"WARNING"] != nil){
             [utils setWarningMessage:[result objectForKey:@"WARNING"]];
         }
        
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return userModel;
}


-(UserModel *) createUser:(UserModel *)userModel OfferModel: (PlanOfferModel *)offerModel AddOnList:(NSMutableArray *)addOnList UserRegCode:(NSString *) userCode CardToken:(NSString *) cardToken PlanIds:(NSArray *) planIdList  TrialEndsAt:(NSNumber *) trialEndAt TrailDays:(NSNumber *) trialDays Gateway:(NSString *) gateway;{
    NSString *urlString =@"user/addUser";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    if(addOnList != nil && addOnList.count > 0){
        [request setValue:addOnList forKey:@"ResourceTypeList"];
    }
    if(offerModel != nil ){
        [request setValue:[offerModel dictionaryWithPropertiesOfObject:offerModel] forKey:@"OfferModel"];
    }
    [request setValue:userCode forKey:@"UserRegCode"];
     [request setValue:planIdList forKey:@"planIdList"];
     [request setValue:cardToken forKey:@"cardToken"];
     [request setValue:trialEndAt forKey:@"trialEndsAt"];
     [request setValue:trialDays forKey:@"trialDays"];
    [request setValue:gateway forKey:@"gateWay"];
    [request setValue:[userModel dictionaryWithPropertiesOfObject:userModel] forKey:@"User"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    
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
-(NSString *) addDedicatedMembershipRequest:(UserRequestModel *) userReqModel OfferModel: (PlanOfferModel *)offerModel AddOnList:(NSMutableArray *)addOnList{
    NSString *urlString =@"user/addDedicatedMembershipRequest";
    
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    if(addOnList != nil && addOnList.count > 0){
        [request setValue:addOnList forKey:@"ResourceTypeList"];
    }
    if(offerModel != nil ){
        [request setValue:[offerModel dictionaryWithPropertiesOfObject:offerModel] forKey:@"OfferModel"];
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
-(NSString *) getCustomerAccount:(NSNumber *) userId StrpAcct:(NSNumber *) strpAcct{
    NSString *urlString =@"custacct/getCustomerAccount";
    NSMutableDictionary *requestData = [NSMutableDictionary dictionary];
    [requestData setValue:userId forKey:@"userId"];
    [requestData setValue:strpAcct forKey:@"strpAcct"];
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
        NSDictionary *acctDic =[result objectForKey:@"User"];
        CustAcctModel *acctMdl = [[CustAcctModel alloc]init];
        acctMdl = [acctMdl initWithDictionary:acctDic];
        return acctMdl.customerId;
    }else{
        return [result objectForKey:@"ERRORMESSAGE"];
    }

}
-(UserModel *) addGuestUser:(UserModel *)userModel{
    NSString *urlString =@"user/addGuestUser";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [request setValue:version forKey:@"versionCode"];
    //float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    //[request setValue:[NSString stringWithFormat:@"%f",ver] forKey:@"versionCode"];
    [request setValue:@"iOS" forKey:@"deviceType"];
    [request setValue:[userModel dictionaryWithPropertiesOfObject:userModel] forKey:@"User"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    
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
