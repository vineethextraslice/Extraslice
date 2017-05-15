//
//  CouponDAO.m
//  WalkNPay
//
//  Created by Administrator on 29/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import "CouponDAO.h"
#import "CouponModel.h"
#import "WnPWebServiceDAO.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"
#import "WnPConstants.h"

@implementation CouponDAO



-(NSMutableArray *) getAllCouponsForPurchase:(NSNumber *)userId StoreId:(NSNumber *)storeId {
    WnPConstants *wnpConst = [[WnPConstants alloc]init];
    NSMutableArray *couponList =  [[NSMutableArray alloc]init];
    NSString *urlString =@"coupon/getAllCouponsForPurchase";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:storeId forKey:@"storeId"];
    [request setValue:userId forKey:@"userId"];
    NSMutableArray *itemList= [[NSMutableArray alloc]init];
    NSMutableArray *productArray =[wnpConst getItemsFromArray];
    for(ProductModel* model in productArray){
        NSDictionary *prdMdlAsDic = [model dictionaryWithPropertiesOfObject:model];
        [itemList addObject:prdMdlAsDic];
    }
    [request setValue:itemList forKey:@"itemList"];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get product details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSArray *couponListDic =[result objectForKey:@"CouponList"];
        for(NSDictionary *couponDic in couponListDic){
            CouponModel *cpnModel = [[CouponModel alloc]init];
            cpnModel = [cpnModel initWithDictionary:couponDic];
            if(![cpnModel.couponType isEqualToString:@"prepaid"]){
                [cpnModel calcualteOfferAmount:FALSE reallocate:FALSE];
            }
            [couponList addObject:cpnModel];
        }
        
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return couponList;
}
-(NSMutableArray *) getAllPrepaidCoupons:(NSNumber *)userId StoreId:(NSNumber *)storeId {
    NSMutableArray *couponList =  [[NSMutableArray alloc]init];
    NSString *urlString =@"coupon/getAllPrepaidCoupons";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:storeId forKey:@"storeId"];
    [request setValue:userId forKey:@"userId"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get product details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSArray *couponListDic =[result objectForKey:@"CouponList"];
        for(NSDictionary *couponDic in couponListDic){
            CouponModel *cpnModel = [[CouponModel alloc]init];
            cpnModel = [cpnModel initWithDictionary:couponDic];
            [couponList addObject:cpnModel];
        }
        
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return couponList;
}
-(NSNumber *) getPrepaidBalance:(NSNumber *)userId {
    NSString *urlString =@"coupon/getPrepaidBalanceOfUser";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:userId forKey:@"userId"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get product details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    NSNumber *prepaidBalance = nil;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        prepaidBalance = [result objectForKey:@"PREPAID_BALANCE"]    ;
        // NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        // f.numberStyle = NSNumberFormatterDecimalStyle;
        // prepaidBalance = [f numberFromString:prepaidBalanceStr];
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return prepaidBalance;
}
-(TransactionModel *) addPrepaidBalance:(NSNumber *)userId CoupunIds:(NSMutableArray *) cpnIdArray CustomeCouponModel:(CouponModel *)couponModel StoreId:(NSNumber *) storeId PayWith:(NSString *) payWith{
    NSString *urlString =@"coupon/addPrepaidBalance";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    NSMutableArray *userList = [[NSMutableArray alloc]init];
    [userList addObject:userId];
    [request setValue:userList forKey:@"userList"];
    [request setValue:cpnIdArray forKey:@"couponIds"];
    [request setValue:userId forKey:@"userId"];
    [request setValue:storeId forKey:@"storeId"];
    [request setValue:payWith forKey:@"payWith"];
    [request setValue:[couponModel dictionaryWithPropertiesOfObject:couponModel] forKey:@"CouponModel"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get product details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"];
    TransactionModel *trxnModel = [[TransactionModel alloc]init];
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSDictionary *resultAsDictionary =[result objectForKey:@"Transaction"];
        trxnModel = [trxnModel initWithDictionary:resultAsDictionary];
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return trxnModel;
}

-(NSNumber *) reAllocatePrepaid:(NSNumber *)userId StoreId:(NSNumber *)storeId  OrderId:(NSNumber *)orderId{
    NSString *urlString =@"coupon/reallocatePrepaid";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:userId forKey:@"userId"];
    [request setValue:storeId forKey:@"storeId"];
    [request setValue:orderId forKey:@"TransactionId"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get product details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    NSNumber *prepVale = [NSNumber numberWithDouble:0];
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        prepVale = [result objectForKey:@"PREPAID_BALANCE"] ;
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return prepVale;
    
}

-(NSNumber *) updatePrepaidToComplete:(NSNumber *)userId StoreId:(NSNumber *)storeId  OrderId:(NSNumber *)orderId{
    NSString *urlString =@"coupon/updatePrepaidToComplete";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:userId forKey:@"userId"];
    [request setValue:storeId forKey:@"storeId"];
    [request setValue:orderId forKey:@"TransactionId"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get product details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    NSNumber *prepVale = [NSNumber numberWithDouble:0];
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        prepVale = [result objectForKey:@"PREPAID_BALANCE"] ;
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return prepVale;
    
}


-(NSMutableArray *) applyAllCoupons:(NSNumber *)userId StoreId:(NSNumber *)storeId CouponList:(NSArray *) cpnList{
    WnPConstants *wnpConst = [[WnPConstants alloc]init];
    NSMutableArray *couponList =  [[NSMutableArray alloc]init];
    NSString *urlString =@"coupon/applyAllCoupons";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *trxnModel = [NSMutableDictionary dictionary];
    NSMutableArray *prdArray=[[NSMutableArray alloc]init];
    
    [trxnModel setValue:storeId forKey:@"storeId"];
    [trxnModel setValue:userId forKey:@"userId"];
    NSMutableArray *itemList= [[NSMutableArray alloc]init];
    NSMutableArray *productArray =[wnpConst getItemsFromArray];
    for(ProductModel* model in productArray){
        NSDictionary *prdMdlAsDic = [model dictionaryWithPropertiesOfObject:model];
        [itemList addObject:prdMdlAsDic];
    }
    [trxnModel setValue:prdArray forKey:@"itemList"];
    
    NSMutableArray *cpnDicArray = [[NSMutableArray alloc]init];
    for(CouponModel *cpn in cpnList){
        [cpnDicArray addObject:[cpn dictionaryWithPropertiesOfObject:cpn]];
    }
    [request setValue:cpnDicArray forKey:@"couponList"];
    
    [request setValue:storeId forKey:@"storeId"];
    [request setValue:userId forKey:@"userId"];
    [request setValue:trxnModel forKey:@"TransactionModel"];
    [request setValue:@"0" forKey:@"totalAmount"];
    [request setValue:@"0" forKey:@"totalCount"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get product details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSArray *couponListDic =[result objectForKey:@"CouponList"];
        for(NSDictionary *couponDic in couponListDic){
            CouponModel *cpnModel = [[CouponModel alloc]init];
            cpnModel = [cpnModel initWithDictionary:couponDic];
            [couponList addObject:cpnModel];
        }
        
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return couponList;
}



@end
