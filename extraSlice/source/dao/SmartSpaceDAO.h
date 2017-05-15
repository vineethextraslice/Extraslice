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
static NSMutableArray *addonList;
static NSMutableArray *offerList;

@interface SmartSpaceDAO : NSObject
@property(strong,nonatomic) NSNumber *noOfdaystoSubsDate ;
@property(strong,nonatomic) NSNumber *trialEndsAt ;
@property(strong,nonatomic) NSNumber *firstsubDate;
@property(strong,nonatomic) NSNumber *noOFDaysInMoth ;
@property(strong,nonatomic) NSString *message;
@property(strong,nonatomic) NSNumber *noOfdaystoNextMonth;
-(NSString *) getSignupData;
-(OrganizationModel *) getIndividualOrg;
@property(strong, nonatomic) NSMutableArray *planArray;
-(NSMutableArray *) getAllAddons ;
-(NSMutableArray *) getAllSmartSpace ;
-(NSDictionary *) addReservation:(ReservationModel *) model PaymentRefKey:(NSString *) pymntRefKey;
-(NSMutableArray *) getResourceUsageDetailsById:(NSMutableArray *)  orgIdList resourceTypeName:(NSString *) resourceTypeName UserId:(NSNumber *) userId;
-(NSMutableArray *) getCurrentSchedulesForPeriod:(NSString *)startTime EndTime:(NSString *)endTime;
-(AdminAccountModel *) getAdminAccount;
-(NSString *) deleteReservation:(ReservationModel *) model;
-(NSDictionary *) updateReservation:(ReservationModel *) model CardToken:(NSString *) cardToken TrialPeriod:(NSNumber *) trialPeriods AmountPaid:(NSNumber *) amountPaid GateWay:(NSString *) pymntGateway Agreed:(bool) agreedToPay;
-(void ) reset;
-(NSMutableArray *) getAllOrganizationNames;
-(NSDictionary *) updateReservationStatus:(ReservationModel *)model CardId:(NSString *)cardToken TrialPeriod:(NSNumber *)trialPeriods Amount:(NSNumber *)amountPaid Gateway:(NSString *)gateway;

-(NSString *) updatePlanForOrg:(NSNumber *) userId OrgId:(NSNumber *) orgId PlanIds:(NSNumber *) planIdList CustomerId:(NSString *) customerId SubscriptionId:(NSString *) subscriptionId PlanStartDate:(NSNumber *) planStartDate PlanEndDate:(NSNumber *) planEndDate PymntGateway:(NSString *) pymntGateway EventType:(NSString *) eventType EventId:(NSString *) eventId;

-(NSDictionary *) getSubscriptionData:(NSNumber *)userId OrgId:(NSNumber *)orgId ;
-(NSDictionary *) requestCancelSubscription:(NSNumber *)userId OrgId:(NSNumber *)orgId CancelMeetingsToo:(BOOL )cancelMeetingsToo PlanIdList:(NSMutableArray *)planIdList AddonIds:(NSMutableArray *) addonIds;

-(NSDictionary *) updateOrgUser:(NSArray *) userList;
-(NSDictionary *) deleteUsersFromOrg:(NSArray *) userList;
-(NSDictionary *) addUserToOrg:(NSString *)email OrgId:(NSNumber *)orgId AdminId:(NSNumber *)adminId ;
-(NSMutableArray *) getPlanOffers;
@end
