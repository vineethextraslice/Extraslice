//
//  TransactionDAO.m
//  WalkNPay
//
//  Created by Administrator on 17/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import "TransactionDAO.h"
#import "WnPWebServiceDAO.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"
#import "CouponModel.h"

@implementation TransactionDAO

-(TransactionModel *) addTransaction:(NSNumber *)userId StoreId:(NSNumber *)storeId Coupon:(NSMutableArray *) couponList PayMethod:(NSString *) payMethod {
    NSMutableArray *couponDictionaryList = [[NSMutableArray alloc]init];
    WnPConstants *wnpConst = [[WnPConstants alloc]init];
    TransactionModel *trxnModel = [[TransactionModel alloc]init];
    trxnModel =[trxnModel init];
    trxnModel.userId=[wnpConst getUserId];
    trxnModel.storeId = [wnpConst getSelectedStoreId];
    trxnModel.payMethod=payMethod;
    NSMutableArray *itemList= [[NSMutableArray alloc]init];
    NSNumber *subTotal = 0;
    NSNumber *taxTotal = 0;
    NSNumber *grossTotal = 0;
    NSMutableArray *productArray =[wnpConst getItemsFromArray];
    for(ProductModel* model in productArray){
        subTotal = [NSNumber numberWithDouble:(subTotal.doubleValue + (model.price.doubleValue*model.purchasedQuantity.doubleValue))];
        taxTotal = [NSNumber numberWithDouble:(taxTotal.doubleValue + ((model.price.doubleValue*model.purchasedQuantity.doubleValue*model.taxPercentage.doubleValue)/100.00f))];
        model.rewardsAmount=@0;
        model.taxAmount=[NSNumber numberWithDouble:((model.price.doubleValue*model.taxPercentage.doubleValue)/100.00f)];
        
        model.offerAppliedQty=@0;
        model.offerAppliedAmt=@0;
        NSDictionary *prdMdlAsDic = [model dictionaryWithPropertiesOfObject:model];
        [itemList addObject:prdMdlAsDic];
    }
    trxnModel.itemList =itemList;
    grossTotal = [NSNumber numberWithDouble:(subTotal.doubleValue+taxTotal.doubleValue)];
    
    NSNumber *offerTotal =[NSNumber numberWithInt:0];
    NSNumber *payableTotal =[NSNumber numberWithInt:0];
    for(CouponModel *cpn in couponList){
        offerTotal = [NSNumber numberWithDouble:(offerTotal.doubleValue + cpn.applicableAmount.doubleValue)];
        [couponDictionaryList addObject:[cpn dictionaryWithPropertiesOfObject:cpn]];
    }
    payableTotal = [NSNumber numberWithDouble:(grossTotal.doubleValue - offerTotal.doubleValue)];
    trxnModel.totalTax=taxTotal.stringValue;
    trxnModel.subTotal=subTotal.stringValue;
    trxnModel.grossTotal=grossTotal.stringValue;
    trxnModel.offerTotal=offerTotal.stringValue;
    trxnModel.payableTotal=payableTotal.stringValue;
    
    trxnModel.orderId=[NSNumber numberWithInt:0];
    trxnModel.userName=@"";
    trxnModel.orderDate=@"";
    trxnModel.storeName=@"";
    trxnModel.couponList=couponDictionaryList;
    trxnModel.recieptStore=[[NSDictionary alloc]init];
    NSLog(@"%@",trxnModel);
    NSString *urlString =@"transaction/addTransaction";
    NSString *jsonString = [trxnModel convertObjectToJsonString:YES];
    WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
    NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
    
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed get product details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSDictionary *resultAsDictionary =[result objectForKey:@"Transaction"];
        trxnModel = [trxnModel initWithDictionary:resultAsDictionary];
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return trxnModel;
}

-(NSString *) deleteTransaction:(NSNumber *)userId OrderId:(NSNumber *)orderId{
    NSString *urlString =@"transaction/deleteTransactionById";
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
        WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
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
-(NSString *) updateTransactionToPurchase:(NSNumber *)userId OrderId:(NSNumber *)orderId{
    NSString *urlString =@"transaction/updateTransactionToPurchase";
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
        WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
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
        WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
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


-(NSDictionary *) getAllRecieptsForuser:(NSNumber *)userId SoreId:(NSNumber *)storeId{
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    
    NSLog(@"%s%@","started ..........",dateString);;
    NSMutableDictionary *recptList=[[NSMutableDictionary alloc]init];
    NSString *urlString =@"transaction/getAllTransactionForUser";
    NSMutableDictionary *trxn = [[NSMutableDictionary alloc] init];
    [trxn setObject:userId forKey:@"userId"];
    [trxn setObject:storeId forKey:@"storeId"];
    
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setObject:trxn forKey:@"TransactionModel"];
    [request setObject:@10 forKey:@"noOfReceipts"];
    
    BOOL prettyPrint=YES;
    NSError *error;
    NSMutableString *status= nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    if (! jsonData) {
        status = [NSMutableString stringWithFormat:@"Error while creating request"];
        [recptList setObject:@"FAILED" forKey:@"STATUS"];
        [recptList setObject:@"Error while creating request" forKey:@"ERRORMESSAGE"];
        return recptList;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
        NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
        dateString = [formatter stringFromDate:[NSDate date]];
        
        NSLog(@"%s%@","end ..........",dateString);;
        return result;
    }
    
}

-(NSDictionary *) getAllRecieptsForuserWithOffset:(NSNumber *)userId StoreId:(NSNumber *)storeId Limit:(int) limit Offset:(int ) offset{
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    
    NSLog(@"%s%@","started ..........",dateString);;
    NSMutableDictionary *recptList=[[NSMutableDictionary alloc]init];
    NSString *urlString =@"transaction/getAllTransactionForUserWithOffset";
    NSMutableDictionary *trxn = [[NSMutableDictionary alloc] init];
    [trxn setObject:userId forKey:@"userId"];
    [trxn setObject:storeId forKey:@"storeId"];
    
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setObject:trxn forKey:@"TransactionModel"];
    [request setObject:[NSNumber numberWithInt:limit] forKey:@"noOfReceipts"];
    [request setObject:[NSNumber numberWithInt:offset] forKey:@"offset"];
    
    BOOL prettyPrint=YES;
    NSError *error;
    NSMutableString *status= nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    if (! jsonData) {
        status = [NSMutableString stringWithFormat:@"Error while creating request"];
        [recptList setObject:@"FAILED" forKey:@"STATUS"];
        [recptList setObject:@"Error while creating request" forKey:@"ERRORMESSAGE"];
        return recptList;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        WnPWebServiceDAO *wbDAO = [[WnPWebServiceDAO alloc]init];
        NSDictionary *result = [wbDAO getDataFromWebService:urlString requestJson:jsonString];
        dateString = [formatter stringFromDate:[NSDate date]];
        
        NSLog(@"%s%@","end ..........",dateString);;
        return result;
    }
    
}


@end
