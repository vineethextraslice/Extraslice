//
//  WebServiceDAO.m
//  WalkNPay
//
//  Created by Irshad on 11/27/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "WebServiceDAO.h"
#import "ESliceConstants.h"

@implementation WebServiceDAO
-(NSDictionary *)getDataFromWebService:(NSString *)urlString requestJson:(NSString *)requestString{
    @try{
        NSString *finalUrl=[NSString stringWithFormat:@"%@%@",urlStartsWith,urlString];
        NSLog(@"%s%@","finalUrl ............. ",finalUrl);
        NSURL *url=[NSURL URLWithString:finalUrl];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req setHTTPMethod:@"POST"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [req setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [req setValue:@"json" forHTTPHeaderField:@"dataType"];
        NSData *reqData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
        [req setHTTPBody:reqData];
        NSURLResponse *resp =[[NSURLResponse alloc] init];
        NSError *theError =nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&theError];
       // NSLog(@"%s%@","response ............. ",data);
        if(data == nil){
            NSMutableDictionary *errorDic = [[NSMutableDictionary alloc]init];
            [errorDic setObject:@"FAILED" forKey:@"STATUS"];
            [errorDic setObject:@"Could not connect to server" forKey:@"ERRORMESSAGE"];
            return errorDic;
        }
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        
        if(error){
            NSMutableDictionary *errorDic = [[NSMutableDictionary alloc]init];
            [errorDic setObject:@"FAILED" forKey:@"STATUS"];
            [errorDic setObject:error.description forKey:@"ERRORMESSAGE"];
            NSLog(@"%s%@","response error............. ",errorDic);
            return errorDic;
        }else{
            return json;
        }
    }@catch(NSError *exp){
        NSMutableDictionary *errorDic = [[NSMutableDictionary alloc]init];
        [errorDic setObject:@"FAILED" forKey:@"STATUS"];
        [errorDic setObject:exp.description forKey:@"ERRORMESSAGE"];
        NSLog(@"%s%@","response error2............. ",errorDic);
        return errorDic;
    }
}


@end
