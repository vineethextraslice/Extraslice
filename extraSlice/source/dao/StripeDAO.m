//
//  StripeDAO.m
//  WalkNPay
//
//  Created by Administrator on 30/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import "StripeDAO.h"
#import "WebServiceDAO.h"
#import "WnPConstants.h"
#import "Utilities.h"
#import "PlanModel.h"
#import "StripePlanModel.h"

@implementation StripeDAO
-(NSString *) doStripePayment:(NSNumber *)amount ID:(NSNumber *)strId CardToken:(NSString *) cardToken Currency:(NSString *) currency Description:(NSString *) description IsDealerAccount:(BOOL) isDealerAcct{
    
    NSMutableDictionary *strpRequestData = [NSMutableDictionary dictionary];
    [strpRequestData setValue:amount forKey:@"amount"];
    [strpRequestData setValue:currency forKey:@"currency"];
    [strpRequestData setValue:cardToken forKey:@"token"];
    [strpRequestData setValue:description forKey:@"description"];
    [strpRequestData setValue:strId forKey:@"id"];
    if(isDealerAcct){
        [strpRequestData setValue:@"true" forKey:@"isDealerAccount"];
    }else{
        [strpRequestData setValue:@"false" forKey:@"isDealerAccount"];
    }
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:strpRequestData options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *urlString =@"transaction/makeStripePayment";
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get product details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    NSString *refKey = nil ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        refKey = [result objectForKey:@"PaymentReferenceKey"];
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return refKey;
}
-(NSString *) subscribeACustomer:(NSString *)email CardToken:(NSString *) cardToken PlanId:(NSString *) planId {
    
    NSMutableDictionary *strpRequestData = [NSMutableDictionary dictionary];
    [strpRequestData setValue:email forKey:@"email"];
    [strpRequestData setValue:planId forKey:@"planId"];
    [strpRequestData setValue:cardToken forKey:@"token"];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:strpRequestData options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *urlString =@"transaction/addSripeSubscription";
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get product details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"];
    NSString *refKey = nil;   ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        refKey = [result objectForKey:@"PaymentReferenceKey"];
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return refKey;
}

-(StripePlanModel *) getOrCreateStripePlan:(PlanModel *)planModel AddOnList:(NSMutableArray *)addOnList{
    StripePlanModel *strpPlnModel=nil;
    Utilities *utils=[[Utilities alloc]init];
    NSString *urlString =@"custacct/getOrCreateStripePlan";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    if(addOnList != nil && addOnList.count > 0){
        [request setValue:addOnList forKey:@"ResourceTypeList"];
    }
    [request setValue:[planModel dictionaryWithPropertiesOfObject:planModel] forKey:@"Plan"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSLog(@"%@",jsonString);
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to create user." userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSDictionary *userDictionary =[result objectForKey:@"StripePlan"];
        strpPlnModel =[[StripePlanModel alloc]init];
        strpPlnModel = [strpPlnModel initWithDictionary:userDictionary];
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return strpPlnModel;
}

@end
