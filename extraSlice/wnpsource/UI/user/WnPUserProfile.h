//
//  UserProfile.h
//  walkNPay
//
//  Created by Administrator on 28/01/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WnPUserProfile : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *autoEmail;
@property (weak, nonatomic) IBOutlet UILabel *changePwd;
@property (weak, nonatomic) IBOutlet UILabel *updateProfile;
@property (weak, nonatomic) IBOutlet UIView *preference1;
@property (weak, nonatomic) IBOutlet UIView *preference2;
@property (weak, nonatomic) IBOutlet UIView *preference3;

@end
