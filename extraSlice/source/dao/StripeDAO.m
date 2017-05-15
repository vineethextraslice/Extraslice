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



@end
