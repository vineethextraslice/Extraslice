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

@interface UserDAO : NSObject
-(UserModel *) getUser:(NSString *)userName Password:(NSString *)password;
-(UserModel *) createUser:(UserModel *)userModel AddOnList:(NSMutableArray *)addOnList UserRegCode:(NSString *) userCode;
-(NSString *) resetPassword:(NSString *)userName;
-(NSString *) resendVericationCode:(UserModel *)userModel;
-(UserModel *) updateUser:(UserModel *)userModel ;
-(NSString *) addDedicatedMembershipRequest:(UserRequestModel *) userReqModel AddOnList:(NSMutableArray *)addOnList;
-(NSString *) updateUserPlan:(NSNumber *) userId OrgId:(NSNumber *) orgId PlanId:(NSNumber *)planId StartDate:(NSString *) plnStartDate EndtDate:(NSString *) plnEndDate PaymentReference:(NSString *) pymntRefKey;
    -(NSString *) deleteUser:(NSNumber *) userId OrgId:(NSNumber *) orgId;
@end
