//
//  SmartSpaceDAO.h
//  extraSlice
//
//  Created by Administrator on 21/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdminAccountModel.h"
#import "ResourceTypeModel.h"
#import "SmartSpaceModel.h"
#import "ReservationModel.h"
#import "OrganizationModel.h"
static NSMutableArray *smartSpaceList;
static AdminAccountModel *adminAcctMdl;
static OrganizationModel *individualOrg;

@interface SmartSpaceDAO : NSObject
-(NSString *) getPlanAndOrgDetl;
-(OrganizationModel *) getIndividualOrg;
@property(strong, nonatomic) NSMutableArray *orgArray;
@property(strong, nonatomic) NSMutableArray *planArray;
-(NSMutableArray *) getAllSmartSpace ;
-(NSString *) addReservation:(ReservationModel *) model PaymentRefKey:(NSString *) pymntRefKey;
-(NSMutableArray *) getResourceUsageDetailsById:(NSMutableArray *)  orgIdList resourceTypeName:(NSString *) resourceTypeName UserId:(NSNumber *) userId;
-(NSMutableArray *) getCurrentSchedulesForPeriod:(NSString *)startTime EndTime:(NSString *)endTime;
-(AdminAccountModel *) getAdminAccount;
-(NSString *) deleteReservation:(ReservationModel *) model;
-(NSString *) updateReservation:(ReservationModel *) model PaymentRefKey:(NSString *) pymntRefKey;
@end
