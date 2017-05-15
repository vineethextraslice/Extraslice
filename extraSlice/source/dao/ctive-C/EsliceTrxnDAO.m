//
//  EsliceTrxnDAO.m
//  extraSlice
//
//  Created by Administrator on 17/04/17.
//  Copyright © 2017 Extraslice Inc. All rights reserved.
//

#import "EsliceTrxnDAO.h"
#import "WebServiceDAO.h"
@interface EsliceTrxnDAO ()

@end

@implementation EsliceTrxnDAO



-(NSDictionary *) getEsliceReceipts:(NSNumber *)userId StartDate:(NSString *)startDate EndDate:(NSString *)endDate{
    NSString *urlString =@"transaction/getAllReceipts";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:userId forKey:@"userId"];
    [request setValue:startDate forKey:@"startDate"];
    [request setValue:endDate forKey:@"endDate"];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    return result;
}
-(NSString *) sendReceiptByEmail:(NSNumber *)userId OrderId:(NSNumber *)orderId{
    NSString *urlString =@"transaction/sendReceiptByMail";
    NSMutableDictionary *input = [[NSMutableDictionary alloc] init];
    [input setObject:userId forKey:@"userId"];
    [input setObject:orderId forKey:@"orderId"];
    BOOL prettyPrint=YES;
    NSError *error;
    NSMutableString *status= nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:input
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    if (! jsonData) {
        status = [NSMutableString stringWithFormat:@"Error while creating request"];
        
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
        NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
        if(result == nil){
            status = [NSMutableString stringWithFormat:@"Error while while updating purchase"];
        }else if([@"SUCCESS"  isEqual: [result objectForKey:@"STATUS"]]){
            status = [NSMutableString stringWithFormat:@"SUCCESS"];
        }else{
            status = [NSMutableString stringWithString:[result objectForKey:@"ERRORMESSAGE"]];
        }
    }
    return status;
}
@end
