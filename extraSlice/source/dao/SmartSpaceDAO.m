//
//  SmartSpaceDAO.m
//  extraSlice
//
//  Created by Administrator on 21/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "SmartSpaceDAO.h"
#import "WebServiceDAO.h"
#import "ESliceConstants.h"
#import "AdminAccountModel.h"
#import "OrganizationModel.h"
#import "PlanModel.h"
#import "Utilities.h"
#import "PlanOfferModel.h"
@implementation SmartSpaceDAO

-(OrganizationModel *) getIndividualOrg{
    if(individualOrg == (id)[NSNull null] || individualOrg == nil){
        NSString *urlString =@"smSpace/getIndividualOrg";
        NSString *jsonString = @"";
        WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
        NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
        if(result == nil || [result objectForKey:@"STATUS"]==nil){
            NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to get plan details" userInfo:nil];
            @throw e;
        }
        NSString *statusStr = [result objectForKey:@"STATUS"]    ;
        if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
            NSDictionary *orgModelDic =[result objectForKey:@"OrganizationModel"];
            individualOrg = [[OrganizationModel alloc]init];
            individualOrg = [individualOrg initWithDictionary:orgModelDic];
            
        }else{
            NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
            @throw e;
        }
        
    }
    return individualOrg;
}

    -(void ) reset{
        adminAcctMdl = nil;
        
    }
    -(NSString *) getSignupData{
        self.planArray = [[NSMutableArray alloc]init];
       
        NSString *urlString =@"smSpace/getSignupData";
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
            
            NSDictionary *admAcctDic =[result objectForKey:@"AdminAccountModel"];
            adminAcctMdl = [[AdminAccountModel alloc]init];
            adminAcctMdl = [adminAcctMdl initWithDictionary:admAcctDic];
            if(addonList == (id)[NSNull null] || addonList == nil){
                addonList = [[NSMutableArray alloc]init];
                NSArray *addonArray =[result objectForKey:@"AddonList"];
                for(NSDictionary *i in addonArray){
                    ResourceTypeModel *resModel = [[ResourceTypeModel alloc]init];
                    resModel = [resModel initWithDictionary:i];
                    [addonList addObject:resModel];
                }
               
            }
            @try {
                if(offerList == (id)[NSNull null] || offerList == nil){
                    offerList = [[NSMutableArray alloc]init];
                    NSArray *offerArray =[result objectForKey:@"OfferList"];
                    for(NSDictionary *i in offerArray){
                        PlanOfferModel *offerModel = [[PlanOfferModel alloc]init];
                        offerModel = [offerModel initWithDictionary:i];
                        [offerList addObject:offerModel];
                    }
                    
                }
            }@catch (NSException *exp) {
               offerList = [[NSMutableArray alloc]init];
            }
            self.noOfdaystoSubsDate = [result objectForKey:@"noOfdaystoSubsDate"];
            self.trialEndsAt = [result objectForKey:@"trialEndsAt"];
            self.firstsubDate = [result objectForKey:@"firstsubDate"];
            self.noOFDaysInMoth = [result objectForKey:@"noOFDaysInMoth"];
            self.message = [result objectForKey:@"message"];
            self.noOfdaystoNextMonth = [result objectForKey:@"noOfdaystoNextMonth"];
            
        }else{
            NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
            @throw e;
        }
        return @"SUCCESS";
    }

-(NSMutableArray *) getAllOrganizationNames{

    NSMutableArray *orgArray= [[NSMutableArray alloc]init];
    NSString *urlString =@"smSpace/getAllOrganizationNames";
    NSString *jsonString = @"";
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    if(result == nil || [result objectForKey:@"STATUS"]==nil){
        NSException *e = [NSException exceptionWithName:@"UserException" reason:@"Error. Failed to get plan details" userInfo:nil];
        @throw e;
    }
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        
        
        NSArray *orgObjArray =[result objectForKey:@"OrganizationNameList"];
        for(NSDictionary *orgName in orgObjArray){
            [orgArray addObject:orgName];
        }
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }
    return orgArray;
}


-(NSMutableArray *) getAllAddons{
    return addonList;
}

-(NSMutableArray *) getPlanOffers{
    return offerList;
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


-(NSDictionary *) addReservation:(ReservationModel *) model PaymentRefKey:(NSString *) pymntRefKey{
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
    return result;
    
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

-(NSString *) updatePlanForOrg:(NSNumber *) userId OrgId:(NSNumber *) orgId PlanIds:(NSMutableArray *) planIdList CustomerId:(NSString *) customerId SubscriptionId:(NSString *) subscriptionId PlanStartDate:(NSNumber *) planStartDate PlanEndDate:(NSNumber *) planEndDate PymntGateway:(NSString *) pymntGateway EventType:(NSString *) eventType EventId:(NSString *) eventId{
    NSString *urlString =@"smSpace/updatePlanForOrg";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:userId forKey:@"userId"];
    [request setValue:orgId forKey:@"orgId"];
    [request setValue:planIdList forKey:@"planIdList"];
    [request setValue:customerId forKey:@"customerId"];
    [request setValue:subscriptionId forKey:@"subscriptionId"];
    [request setValue:planStartDate forKey:@"planStartDate"];
    [request setValue:planEndDate forKey:@"planEndDate"];
    [request setValue:pymntGateway forKey:@"pymntGateway"];
    [request setValue:eventType forKey:@"eventType"];
    [request setValue:eventId forKey:@"eventId"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
        return statusStr;
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }

}

-(NSDictionary *) updateReservation:(ReservationModel *) model CardToken:(NSString *) cardToken TrialPeriod:(NSNumber *) trialPeriods AmountPaid:(NSNumber *) amountPaid GateWay:(NSString *) pymntGateway Agreed:(bool) agreedToPay;{
    NSString *urlString =@"smSpace/updateReservation";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:cardToken forKey:@"cardToken"];
    [request setValue:[NSNumber numberWithBool:agreedToPay] forKey:@"agreeToPay"];
    [request setValue:trialPeriods forKey:@"trialPeriods"];
    [request setValue:amountPaid forKey:@"paidAmount"];
    [request setValue:pymntGateway forKey:@"gateWay"];
    [request setValue:[model convertObjectToJsonString:YES] forKey:@"ReservationModel"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)                                                 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    return result;
    
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

-(NSDictionary *) updateReservationStatus:(ReservationModel *)model CardId:(NSString *)cardToken TrialPeriod:(NSNumber *)trialPeriods Amount:(NSNumber *)amountPaid Gateway:(NSString *)gateway{
    NSString *urlString =@"smSpace/updateReservationStatus";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:trialPeriods forKey:@"trialPeriods"];
    [request setValue:cardToken forKey:@"cardToken"];
    [request setValue:amountPaid forKey:@"amountPaid"];
    [request setValue:gateway forKey:@"pymntGateway"];
    [request setValue:[model convertObjectToJsonString:YES] forKey:@"ReservationModel"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    return result;
}
-(NSDictionary *) getSubscriptionData:(NSNumber *)userId OrgId:(NSNumber *)orgId {
    NSString *urlString =@"smSpace/getProfileData";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:userId forKey:@"userId"];
    [request setValue:orgId forKey:@"orgId"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
         return result;
    }else{
        NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
        @throw e;
    }

   

}
-(NSDictionary *) requestCancelSubscription:(NSNumber *)userId OrgId:(NSNumber *)orgId CancelMeetingsToo:(BOOL )cancelMeetingsToo PlanIdList:(NSMutableArray *)planIdList AddonIds:(NSMutableArray *) addonIds{
    NSString *urlString =@"custacct/requestCancelSubscription";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:userId forKey:@"userId"];
    [request setValue:orgId forKey:@"orgId"];
    [request setValue:[NSNumber numberWithBool:cancelMeetingsToo] forKey:@"cancelMeetingsToo"];
    [request setValue:planIdList forKey:@"planIdList"];
    [request setValue:addonIds forKey:@"addonIds"];
  
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    return result;

}

-(NSDictionary *) updateOrgUser:(NSArray *) userList{
    NSString *urlString =@"smSpace/updateOrgUser";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:userList forKey:@"UserList"];

    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    return result;

}
-(NSDictionary *) deleteUsersFromOrg:(NSArray *) userList{
    NSString *urlString =@"smSpace/deleteUsersFromOrg";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:userList forKey:@"UserList"];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    return result;
    
}
-(NSDictionary *) addUserToOrg:(NSString *)email OrgId:(NSNumber *)orgId AdminId:(NSNumber *)adminId{
    NSString *urlString =@"smSpace/addUserToOrg";
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    [request setValue:email forKey:@"email"];
    [request setValue:orgId forKey:@"orgId"];
    [request setValue:adminId forKey:@"adminId"];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:(NSJSONWritingOptions) (NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    WebServiceDAO *wbDAO = [[WebServiceDAO alloc]init];
    NSDictionary *result =[wbDAO getDataFromWebService:urlString requestJson:jsonString];
    return result;
    
}

@end
