//
//  UserDAO.h
//  WalkNPay
//
//  Created by Administrator on 17/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
#import "UserRequestModel.h"
#import "PlanOfferModel.h"
#import "CustAcctModel.h"

@interface UserDAO : NSObject
-(UserModel *) getUser:(NSString *)userName Password:(NSString *)password;
-(UserModel *) createUser:(UserModel *)userModel OfferModel: (PlanOfferModel *)offerModel AddOnList:(NSMutableArray *)addOnList UserRegCode:(NSString *) userCode CardToken:(NSString *) cardToken PlanIds:(NSArray *) planIdList TrialEndsAt:(NSNumber *) trialEndAt TrailDays:(NSNumber *) trialDays Gateway:(NSString *) gateway;
-(NSString *) resetPassword:(NSString *)userName;
-(NSString *) resendVericationCode:(UserModel *)userModel;
-(UserModel *) updateUser:(UserModel *)userModel ;
-(NSString *) addDedicatedMembershipRequest:(UserRequestModel *) userReqModel OfferModel: (PlanOfferModel *)offerModel AddOnList:(NSMutableArray *)addOnList;
-(NSString *) deleteUser:(NSNumber *) userId OrgId:(NSNumber *) orgId;
-(NSString *) getCustomerAccount:(NSNumber *) userId StrpAcct:(NSNumber *) strpAcct;

@end
