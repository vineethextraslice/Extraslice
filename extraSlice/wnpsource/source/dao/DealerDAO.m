//
//  DealerDAO.m
//  walkNPay
//
//  Created by Administrator on 04/02/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "DealerDAO.h"
#import "DealerModel.h"
#import "WnPWebServiceDAO.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"
@implementation DealerDAO
-(NSArray *) getAllDealer{
    NSMutableArray *dealerArray = [[NSMutableArray alloc]init];
    NSString *urlString =@"dealer/getAllDealers";
    NSString *jsonString = @"";
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to get dealer details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSArray *dealerArrayObj =[result objectForKey:@"DealerList"];
        for(NSDictionary *i in dealerArrayObj){
            DealerModel *dlrMdl = [[DealerModel alloc]init];
            dlrMdl = [dlrMdl initWithDictionary:i];
            [dealerArray addObject:dlrMdl];
        }
        
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return dealerArray;
}
@end
