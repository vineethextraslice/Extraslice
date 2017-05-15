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

-(NSString *) doStripePayment:(NSNumber *)amount ID:(NSNumber *)strId CardToken:(NSString *) cardToken Currency:(NSString *) currency Description:(NSString *) description IsDealerAccount:(BOOL) isDealerAcct PlanNames:(NSString *) planNames Addonnames:(NSString *) addonNames{
    
    NSMutableDictionary *strpRequestData = [NSMutableDictionary dictionary];
    [strpRequestData setValue:amount forKey:@"amount"];
    [strpRequestData setValue:currency forKey:@"currency"];
    [strpRequestData setValue:cardToken forKey:@"token"];
    [strpRequestData setValue:description forKey:@"description"];
    [strpRequestData setValue:strId forKey:@"id"];
    if(planNames != nil){
        [strpRequestData setValue:planNames forKey:@"planNames"];
    }
    if(addonNames != nil){
        [strpRequestData setValue:addonNames forKey:@"addons"];
    } [strpRequestData setValue:strId forKey:@"id"];
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
-(NSDictionary *) getStripeCardsForUser:(NSNumber *)userId{
    NSString *urlString =@"custacct/getStripeCustomerDetailsForUser";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:userId forKey:@"userId"];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    return result;
}
-(NSDictionary *) deleteCard:(NSNumber *)userId CustId:(NSString *) custId TokenId:(NSString *) tokenId{
    NSString *urlString =@"custacct/deleteCard";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:userId forKey:@"userId"];
    [request setValue:custId forKey:@"custId"];
    [request setValue:tokenId forKey:@"cardId"];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    return result;
    

}
-(NSDictionary *) addCustomerAndCard:(NSNumber *)userId Email:(NSString *) email CustId:(NSString *) custId TokenId:(NSString *) tokenId NewCard:(BOOL) newcard DefaultCard:(BOOL) defaultCard{
    NSString *urlString =@"custacct/addCustomerAndCard";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:userId forKey:@"userId"];
    [request setValue:email forKey:@"email"];
    [request setValue:custId forKey:@"custId"];
    [request setValue:tokenId forKey:@"cardId"];
    if(newcard){
        [request setValue:@"true" forKey:@"isNewCard"];
    }else{
        [request setValue:@"false" forKey:@"isNewCard"];
    }
    if(defaultCard){
        [request setValue:@"true" forKey:@"isDefaultCard"];
    }else{
        [request setValue:@"false" forKey:@"isDefaultCard"];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    return result;

    
}
-(NSDictionary *) updateStripeCustomerForUser:(NSNumber *)userId OrgId:(NSNumber *) orgId{
    NSString *urlString =@"custacct/updateStripeCustomerForUser";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:userId forKey:@"userId"];
    [request setValue:orgId forKey:@"orgId"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    return result;

}

@end
