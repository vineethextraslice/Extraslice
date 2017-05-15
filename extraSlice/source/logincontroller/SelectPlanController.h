//
//  ShowPlansController.h
//  extraSlice
//
//  Created by Administrator on 19/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdminAccountModel.h"
#import "OrganizationModel.h"
#import "PlanModel.h"
#import "PlanOfferModel.h"

@interface SelectPlanController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *gobackView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *goBack;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorViewTop;
@property (weak, nonatomic) IBOutlet UIView *existingMmbrLyt;
@property (weak, nonatomic) IBOutlet UILabel *errorText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorViewHeight;
@property(strong,nonatomic) AdminAccountModel *adminAcctModel;
@property (weak, nonatomic) IBOutlet UIView *planContainer;
@property (weak, nonatomic) IBOutlet UIImageView *registeredUser;
@property (weak, nonatomic) IBOutlet UILabel *mainHeader;

@property(strong,nonatomic) NSMutableArray *planArray;
@property(strong,nonatomic) NSMutableArray *addonList;
@property(strong,nonatomic) NSMutableArray *offerList;
@property(strong,nonatomic) NSNumber *noOfdaystoSubsDate ;
@property(strong,nonatomic) NSNumber *trialEndsAt ;
@property(strong,nonatomic) NSNumber *firstsubDate;
@property(strong,nonatomic) NSNumber *noOFDaysInMoth ;
@property(strong,nonatomic) NSString *message;
@property(strong,nonatomic) NSNumber *noOfdaystoNextMonth;
@end
