//
//  SmartSpaceDAO.m
//  extraSlice
//
//  Created by Administrator on 21/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "SmartSpaceDAO.h"
#import "WebServiceDAO.h"
#import "WnPConstants.h"
#import "AdminAccountModel.h"
#import "OrganizationModel.h"
#import "PlanModel.h"
#import "Utilities.h"
@implementation SmartSpaceDAO
    -(OrganizationModel *) getIndividualOrg{
        return individualOrg;
    }
    -(NSString *) getPlanAndOrgDetl{
        self.planArray = [[NSMutableArray alloc]init];
        self.orgArray = [[NSMutableArray alloc]init];
        NSString *urlString =@"smSpace/getPlanAndOrgDetl";
        NSString *jsonString = @"";
        WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
        NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
        if(result == nil || [result objectForKey:@"STATUS"]==nil){
            NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to get plan details" userInfo:nil];
            @throw e;
        }
        NSString *statusStr = [result objectForKey:@"STATUS"]    ;
        if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
            NSArray *planObjArray =[result objectForKey:@"PlanList"];
            for(NSDictionary *i in planObjArray){
                PlanModel *planModel = [[PlanModel alloc]init];
                planModel = [planModel initWithDictionary:i];
                [self.planArray addObject:planModel];
            }
            
            NSArray *orgObjArray =[result objectForKey:@"OrganizationList"];
            for(NSDictionary *i in orgObjArray){
                OrganizationModel *orgModel = [[OrganizationModel alloc]init];
                orgModel = [orgModel initWithDictionary:i];
                if(orgModel.individualRefOrg){
                    individualOrg = orgModel;
                }else{
                    [self.orgArray addObject:orgModel];
                }
            }
            NSDictionary *admAcctDic =[result objectForKey:@"AdminAccountModel"];
            adminAcctMdl = [[AdminAccountModel alloc]init];
            adminAcctMdl = [adminAcctMdl initWithDictionary:admAcctDic];
            
            
        }else{
            NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
            @throw e;
        }
        return @"SUCCESS";
    }



-(AdminAccountModel *) getAdminAccount{
    if(adminAcctMdl == (id)[NSNull null] || adminAcctMdl == nil){
        NSString *urlString =@"smSpace/getAdminAccount";
        NSString *jsonString = @"";
        WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
        NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
        if(result == nil || [result objectForKey:@"STATUS"]==nil){
            NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to get plan details" userInfo:nil];
            @throw e;
        }
        NSString *statusStr = [result objectForKey:@"STATUS"]    ;
        if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
            NSDictionary *admAcctDic =[result objectForKey:@"AdminAccountModel"];
            adminAcctMdl = [[AdminAccountModel alloc]init];
            adminAcctMdl = [adminAcctMdl initWithDictionary:admAcctDic];
        
        
        }else{
            NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
            @throw e;
        }
    }
    return adminAcctMdl;
}



-(NSMutableArray *) getAllSmartSpace {
    if(smartSpaceList == (id)[NSNull null] || smartSpaceList == nil){
        smartSpaceList = [[NSMutableArray alloc]init];
        NSString *urlString =@"smSpace/getAllSmartSpace";
        NSString *jsonString = @"";
        WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
        NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
        if(result == nil || [result objectForKey:@"STATUS"]==nil){
            NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to get plan details" userInfo:nil];
            @throw e;
        }
        NSString *statusStr = [result objectForKey:@"STATUS"]    ;
        if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
            NSArray *smartSpaceObjArray =[result objectForKey:@"SmartSpaceList"];
            for(NSDictionary *i in smartSpaceObjArray){
                SmartSpaceModel *smModel = [[SmartSpaceModel alloc]init];
                smModel = [smModel initWithDictionary:i];
                [smartSpaceList addObject:smModel];
            }
        
            NSDictionary *admAcctDic =[result objectForKey:@"AdminAccountModel"];
            adminAcctMdl = [[AdminAccountModel alloc]init];
            adminAcctMdl = [adminAcctMdl initWithDictionary:admAcctDic];
        
        
        }else{
            NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
            @throw e;
        }
    }
    return smartSpaceList;
}



-(NSMutableArray *) getCurrentSchedulesForPeriod:(NSString *)startTime EndTime:(NSString *)endTime{
    
    NSMutableArray *smartSpaceArray = [[NSMutableArray alloc]init];
    NSString *urlString =@"smSpace/getCurrentSchedulesForPeriod";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:startTime forKey:@"startTime"];
    [request setValue:endTime forKey:@"endTime"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to get plan details" userInfo:nil];
        @throw e;
    }

    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSArray *smartSpaceObjArray =[result objectForKey:@"ReservationList"];
        for(NSDictionary *i in smartSpaceObjArray){
            ReservationModel *smModel = [[ReservationModel alloc]init];
            smModel = [smModel initWithDictionary:i];
            [smartSpaceArray addObject:smModel];
        }
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return smartSpaceArray;
    
}


-(NSString *) addReservation:(ReservationModel *) model PaymentRefKey:(NSString *) pymntRefKey{
    NSString *urlString =@"smSpace/addReservation";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:pymntRefKey forKey:@"pymntRefKey"];
    [request setValue:[model convertObjectToJsonString:YES] forKey:@"ReservationModel"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonString);
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    NSLog(@"%@",result);
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to update reservation" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
     NSLog(@"%@",statusStr);
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        return  statusStr;
    }else{
        NSLog(@"%@",[result objectForKey:@"ERRORMESSAGE"] );
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    
}

-(NSString *) deleteReservation:(ReservationModel *) model{
    NSString *urlString =@"smSpace/deleteReservation";
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:[model convertObjectToJsonString:YES] ];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to update reservation" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        return statusStr;
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    
}

-(NSString *) updateReservation:(ReservationModel *) model PaymentRefKey:(NSString *) pymntRefKey{
    NSString *urlString =@"smSpace/updateReservation";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:pymntRefKey forKey:@"pymntRefKey"];
    [request setValue:[model convertObjectToJsonString:YES] forKey:@"ReservationModel"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to update reservation" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
       return statusStr;
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
}



-(NSArray *) getResourceUsageDetails:(NSNumber *) orgId {
    NSString *urlString =@"smSpace/getResourceUsageDetailsById";
    NSMutableArray *resTypeArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:orgId forKey:@"orgId"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to get plan details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSArray *resTypeObjArray =[result objectForKey:@"ResourceTypeList"];
        for(NSDictionary *i in resTypeObjArray){
            ResourceTypeModel *resTypeModel = [[ResourceTypeModel alloc]init];
            resTypeModel = [resTypeModel initWithDictionary:i];
            [resTypeArray addObject:resTypeModel];
        }
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return resTypeArray;
}
-(NSArray *) getResourceUsageDetailsById:(NSMutableArray *)  orgIdList resourceTypeName:(NSString *) resourceTypeName UserId:(NSNumber *) userId{
    NSString *urlString =@"smSpace/getResourceUsageDetailsById";
    NSMutableArray *resTypeArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:orgIdList forKey:@"orgIdList"];
    [request setValue:resourceTypeName forKey:@"resourceTypeName"];
    [request setValue:userId forKey:@"userId"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to get plan details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSArray *resTypeObjArray =[result objectForKey:@"ResourceTypeList"];
        for(NSDictionary *i in resTypeObjArray){
            ResourceTypeModel *resTypeModel = [[ResourceTypeModel alloc]init];
            resTypeModel = [resTypeModel initWithDictionary:i];
            [resTypeArray addObject:resTypeModel];
        }
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return resTypeArray;
}
-(NSMutableArray *) getResourcseTypesForPlan:(NSNumber *)planId {
    NSMutableArray *resTypeArray = [[NSMutableArray alloc]init];
    NSString *urlString =@"smSpace/getResourcseTypesForPlan";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:planId forKey:@"planId"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to get plan details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        NSArray *resTypeObjArray =[result objectForKey:@"ResourceTypeList"];
        for(NSDictionary *i in resTypeObjArray){
            ResourceTypeModel *resTypeModel = [[ResourceTypeModel alloc]init];
            resTypeModel = [resTypeModel initWithDictionary:i];
            [resTypeArray addObject:resTypeModel];
        }
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return resTypeArray;
}
@end
