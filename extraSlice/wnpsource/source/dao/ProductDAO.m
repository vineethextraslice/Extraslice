//
//  ProductDAO.m
//  WalkNPay
//
//  Created by Administrator on 17/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import "ProductDAO.h"
#import "WnPWebServiceDAO.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"
@implementation ProductDAO

-(ProductModel *) getProductForStoreByCode:(NSString *)code StoreId:(NSNumber *)storeId StatusFilter:(NSString *) statusFilter{
    NSString *urlString =@"products/getProductsForStoreByCode";
    ProductModel *productModel = [[ProductModel alloc] init];
    
    NSMutableDictionary *product = [NSMutableDictionary dictionary];
    [product setValue:storeId forKey:@"storeId"];
    [product setValue:code forKey:@"code"];
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:product forKey:@"ProductModel"];
    [request setValue:statusFilter forKey:@"StatusFilter"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get product details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSDictionary *prodDictionary =[result objectForKey:@"Product"];
        productModel = [productModel initWithDictionary:prodDictionary];
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return productModel;
    
}
@end
