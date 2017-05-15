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

@interface SelectPlanController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *gobackView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *goBack;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bcImageHeight;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorViewTop;
@property (weak, nonatomic) IBOutlet UIView *existingMmbrLyt;
@property (weak, nonatomic) IBOutlet UILabel *errorText;
@property (weak, nonatomic) IBOutlet UIImageView *bcImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorViewHeight;
- (IBAction)loadUserData:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *planContainer;
@property (weak, nonatomic) IBOutlet UIImageView *registeredUser;
@property(strong,nonatomic) PlanModel *selectedPlan;
@property(strong,nonatomic) NSMutableArray *orgList;
@property(strong,nonatomic) NSMutableArray *planArray;
@property(strong,nonatomic) AdminAccountModel *adminAcctModel;

@end
