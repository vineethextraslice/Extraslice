//
//  StoreDAO.m
//  WalkNPay
//
//  Created by Administrator on 18/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import "StoreDAO.h"
#import "StoreModel.h"
#import "WnPWebServiceDAO.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"

@implementation StoreDAO
-(NSArray *) getAllStoresForDealer:(NSNumber *)dealerId {
    NSMutableArray *strArray = [[NSMutableArray alloc]init];
    NSString *urlString =@"store/getAllStoresForDealer";
    
    NSMutableDictionary *storeModel = [NSMutableDictionary dictionary];
    [storeModel setValue:dealerId forKey:@"dealerId"];
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:storeModel forKey:@"StoreModel"];
    [request setValue:@"ACTIVE" forKey:@"StatusFilter"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get store details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSArray *storeArrayObj =[result objectForKey:@"StoreList"];
        for(NSDictionary *i in storeArrayObj){
            StoreModel *strMdl = [[StoreModel alloc]init];
            strMdl = [strMdl initWithDictionary:i];
            [strArray addObject:strMdl];
        }
        
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return strArray;
    
}
-(NSArray *) getAllStoresForDealerByLocation:(NSNumber *)dealerId{
    WnPConstants *wnpConst =[[WnPConstants alloc]init];
    double userLat=[wnpConst getUserLat];
    double userLong =[wnpConst getUserLong];
    if(userLat == 0 && userLong == 0){
        return [self getAllStoresForDealer:dealerId];
        
    }else{
        NSMutableArray *strArray = [[NSMutableArray alloc]init];
        NSString *urlString =@"store/getAllStoresForDealerByLocation";
        
        NSMutableDictionary *storeModel = [NSMutableDictionary dictionary];
        [storeModel setValue:dealerId forKey:@"dealerId"];
        
        NSMutableDictionary *request = [NSMutableDictionary dictionary];
        [request setValue:storeModel forKey:@"StoreModel"];
        [request setValue:@"ACTIVE" forKey:@"StatusFilter"];
        [request setValue:[NSNumber numberWithDouble:userLat] forKey:@"latitude"];
        [request setValue:[NSNumber numberWithDouble:userLong] forKey:@"longitude"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
        NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
        if(result == nil || [result objectForKey:@"STATUS"]==nil){
            NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get store details" userInfo:nil];
            @throw e;
        }
        NSString *statusStr = [result objectForKey:@"STATUS"]    ;
        if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
            NSArray *storeArrayObj =[result objectForKey:@"StoreList"];
            for(NSDictionary *i in storeArrayObj){
                StoreModel *strMdl = [[StoreModel alloc]init];
                strMdl = [strMdl initWithDictionary:i];
                [strArray addObject:strMdl];
            }
            if(strArray.count == 0){
                return [self getAllStoresForDealer:dealerId];
                
            }
        }else{
            return [self getAllStoresForDealer:dealerId];
        }
        return strArray;
    }
    
    
}
-(StoreModel *) getStoreById:(NSNumber *)storeId{
    StoreModel *storeModel = [[StoreModel alloc]init];
    NSString *urlString =@"store/getStoreById";
    storeModel.storeId=storeId;
    
    
    NSString *jsonString= [storeModel convertObjectToJsonString:YES];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get store details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSDictionary *storeObj =[result objectForKey:@"Store"];
        storeModel = [storeModel initWithDictionary:storeObj];
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return storeModel;
}

@end
