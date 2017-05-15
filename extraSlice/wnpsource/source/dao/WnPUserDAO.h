//
//  UserDAO.h
//  WalkNPay
//
//  Created by Administrator on 17/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WnPUserModel.h"
#import "UserModel.h"

@interface WnPUserDAO : NSObject
-(WnPUserModel *) getUser:(NSString *)userName Password:(NSString *)password;
-(WnPUserModel *) createUser:(NSString *)userName Password:(NSString *)password;
-(NSString *) resetPassword:(NSString *)userName;
-(NSString *) resendVericationCode:(WnPUserModel *)userModel;
-(WnPUserModel *) updateUser:(WnPUserModel *)userModel ;
-(NSString *) updateESliceUser:(UserModel *)userModel;
-(WnPUserModel *) authenticateESliceUser:(UserModel *)userModel;

    


@end
