//
//  PlanDetails.h
//  extraSlice
//
//  Created by Administrator on 28/09/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlanModel.h"
#import "AdminAccountModel.h"
#import "PlanOfferModel.h"

@interface PlanDetails : UIViewController
@property (weak, nonatomic) IBOutlet UIView *goBack;
@property (weak, nonatomic) IBOutlet UILabel *planNameTV;
@property (weak, nonatomic) IBOutlet UIScrollView *planDetlScrView;
@property (weak, nonatomic) IBOutlet UIScrollView *addonScrView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addonScrHeight;
@property (weak, nonatomic) IBOutlet UILabel *addonHeader;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addonHeaderHeight;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *planDetlHieght;
@property (weak, nonatomic) IBOutlet UILabel *planShortDesc;
@property (weak, nonatomic) IBOutlet UIView *resourceHeader;
@property (weak, nonatomic) IBOutlet UIButton *addToCartBtn;
@property (weak, nonatomic) IBOutlet UILabel *planCost;
@property(strong,nonatomic) AdminAccountModel *adminAcctModel;
@property (weak, nonatomic) IBOutlet UILabel *offerHeader;
@property (weak, nonatomic) IBOutlet UIScrollView *offerScrView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offerScrHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offerHeaderHeight;
@property (weak, nonatomic) IBOutlet UILabel *resourceMainHeader;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resorceHeaderHeight;


@property (strong, nonatomic) PlanModel *selectedPlnModel;
@property(strong,nonatomic) NSMutableArray *addonList;
@property(strong,nonatomic) NSMutableArray *planArray;
@property(strong,nonatomic) NSMutableArray *offerList;
@property(strong,nonatomic) NSMutableArray *offertagArray;
@property(strong,nonatomic) NSNumber *noOfdaystoSubsDate ;
@property(strong,nonatomic) NSNumber *trialEndsAt ;
@property(strong,nonatomic) NSNumber *firstsubDate;
@property(strong,nonatomic) NSNumber *noOFDaysInMoth ;
@property(strong,nonatomic) NSString *message;
@property(strong,nonatomic) NSNumber *noOfdaystoNextMonth;


- (IBAction)addToCart:(id)sender;

@end
