//
//  ShowPlansController.m
//  extraSlice
//
//  Created by Administrator on 19/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "SelectPlanController.h"
#import "UserDataController.h"
#import "LoginController.h"
#import "SmartSpaceDAO.h"
#import "AdminAccountModel.h"
#import "OrganizationModel.h"
#import "PlanModel.h"
#import "WnPConstants.h"
#import "ResourceTypeModel.h"
#import "Utilities.h"
#import "PlanDetails.h"
#import "PlanOfferModel.h"

int screenWidth=0;
@interface SelectPlanController ()
@property(strong,nonatomic) WnPConstants *wnpConst;
@property(strong,nonatomic) SmartSpaceDAO *smartSpaceDAO;
@property(strong,nonatomic) Utilities *utils;





@end

@implementation SelectPlanController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.utils = [[Utilities alloc]init];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth=screenRect.size.width;
    self.wnpConst = [[WnPConstants alloc]init];
    self.headerView.backgroundColor=[self.wnpConst getThemeBaseColor];
    self.errorViewHeight.constant = 0;
    self.errorText.text= @"";
    self.errorView.hidden = true;
    self.errorViewTop.constant=0;
    
    UITapGestureRecognizer *gobackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(goBack:)];
    gobackTap.numberOfTapsRequired = 1;
    gobackTap.numberOfTouchesRequired = 1;
    [self.goBack setUserInteractionEnabled:YES];
    [self.goBack addGestureRecognizer:gobackTap];
    
    
    UITapGestureRecognizer *gobackViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(goBack:)];
    gobackViewTap.numberOfTapsRequired = 1;
    gobackViewTap.numberOfTouchesRequired = 1;
    [self.gobackView setUserInteractionEnabled:YES];
    [self.gobackView addGestureRecognizer:gobackViewTap];
    [self.view bringSubviewToFront:self.gobackView];
    
    UITapGestureRecognizer *regUserTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(loadRegisteredUserData:)];
    regUserTap.numberOfTapsRequired = 1;
    regUserTap.numberOfTouchesRequired = 1;
    [self.registeredUser setUserInteractionEnabled:YES];
    [self.registeredUser addGestureRecognizer:regUserTap];
     self.scrollViewHeight.constant=0;
    if(self.adminAcctModel == nil || self.planArray == nil || self.addonList == nil){
        [self performBackgroundTask];
    }else{
        [self collpasePlan];
    }
    
}
-(void) viewDidAppear:(BOOL)animated{
    
}
- (void)collpasePlan{
    
    int index = 0;
    
    int hedHeight = 64;
    self.scrollViewHeight.constant=self.planArray.count*64;

    for(UIView *sv in self.planContainer.subviews){
        [sv removeFromSuperview];
    }
    UIColor *bgColor =[self.wnpConst getThemeBaseColor];
    NSMutableDictionary *planOfferMap =[[NSMutableDictionary alloc]init];
    for(PlanOfferModel *offerMdl in self.offerList){
        NSArray* foo = [offerMdl.applicableTo componentsSeparatedByString: @","];
        for(NSString *plnIdStr in foo){
            NSNumber *plnId = [NSNumber numberWithInt:plnIdStr.intValue];
            NSMutableArray *offerIdArray = [[NSMutableArray alloc]init];
            if(![planOfferMap.allKeys containsObject:plnId]){
                [planOfferMap setObject:offerIdArray forKey:plnId];
            }
             offerIdArray =[planOfferMap objectForKey:plnId];
            [offerIdArray addObject:offerMdl.offerId];
        }
    }
    
    
    
    
    for(PlanModel *plnModel in self.planArray){
        
        if(index%2 == 0){
            
            bgColor =[self.wnpConst getThemeBaseColor];
        }else{
            bgColor=[self.wnpConst getThemeColorWithTransparency:0.5];
        }
        int detlWidth= (screenWidth-hedHeight);
        int detlStart= 5;
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, (index*hedHeight)+2 , screenWidth, hedHeight)];
        UIView *addPlanView =nil;

        addPlanView = [[UIView alloc] initWithFrame:CGRectMake((screenWidth-hedHeight), 0 , hedHeight, hedHeight)];
        [topView addSubview: addPlanView];
        UIImageView *expandImage = [[UIImageView alloc] initWithFrame:CGRectMake(hedHeight-35, (hedHeight-30)/2 , 30, 30)];
        [expandImage setImage:[UIImage imageNamed:@"next.png"]];
        [addPlanView addSubview: expandImage];
        
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(detlStart, 0 , detlWidth, 30)];
        [topView setBackgroundColor:bgColor];
        header.text = plnModel.planName;
        header.textColor =[UIColor whiteColor];
        [topView addSubview: header];
        UIFont *txtFont = [header.font fontWithSize:18];
        header.font = txtFont;
        
       
        
        UITapGestureRecognizer *selectPlnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(expandPlan:)];
        selectPlnTap.numberOfTapsRequired = 1;
        selectPlnTap.numberOfTouchesRequired = 1;
        [addPlanView setUserInteractionEnabled:YES];
        [addPlanView addGestureRecognizer:selectPlnTap];
        addPlanView.tag = index;
        UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(detlStart, 32 , detlWidth, 30)];
        double minAmount = plnModel.planPrice.doubleValue;
        NSArray *offerArray = [planOfferMap objectForKey:plnModel.planId];
        for(PlanOfferModel *offerMdl in self.offerList){
            if([offerArray containsObject:offerMdl.offerId]){
                double currOfferAmt = plnModel.planPrice.doubleValue -(plnModel.planPrice.doubleValue*offerMdl.offerValue.doubleValue/100.00);
                if(currOfferAmt < minAmount){
                    minAmount = currOfferAmt;
                }
            }
            
        }
        
        desc.text = [NSString stringWithFormat:@"%s%@","Starts from $",[self.utils getNumberFormatter:minAmount]];
        desc.textColor =[UIColor whiteColor];
        
        [topView addSubview: desc];
        UIFont *desctxtFont = [desc.font fontWithSize:15];
        desc.font = desctxtFont;
         UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, (index*hedHeight)+hedHeight , screenWidth, 2)];
        [divider setBackgroundColor:[UIColor whiteColor]];

        [self.planContainer addSubview:topView];
        [self.planContainer addSubview:divider];
        
        index++;
        
    }

}
- (void)expandPlan:(UITapGestureRecognizer *) rec{
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"PlanDetails" bundle:nil];
    PlanDetails *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"PlanDetails"];
    viewCtrl.selectedPlnModel = [self.planArray objectAtIndex:rec.view.tag];
    viewCtrl.addonList = self.addonList;
    viewCtrl.planArray = self.planArray;
    viewCtrl.adminAcctModel=self.adminAcctModel;
    viewCtrl.offerList=self.offerList;
    viewCtrl.noOfdaystoSubsDate = self.noOfdaystoSubsDate;
    viewCtrl.trialEndsAt = self.trialEndsAt;
    viewCtrl.firstsubDate  = self.firstsubDate;
    viewCtrl.noOFDaysInMoth  = self.noOFDaysInMoth;
    viewCtrl.message = self.message;
    viewCtrl.noOfdaystoNextMonth = self.noOfdaystoNextMonth;
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)goBack:(UITapGestureRecognizer *) rec{
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginController" bundle:nil];
    LoginController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginController"];
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
    
}
- (void)loadRegisteredUserData:(UITapGestureRecognizer *) rec{
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"UserData" bundle:nil];
    UserDataController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"UserData"];
    viewCtrl.selectedPlanArray = nil;
    viewCtrl.adminAcctModel = self.adminAcctModel;
    viewCtrl.planArray= self.planArray;
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
    
}

- (void)performBackgroundTask
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *error = nil;
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGAffineTransform transform = CGAffineTransformMakeScale(2.0f, 2.0f);
        indicator.transform = transform;
        indicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
        indicator.center = self.view.center;
        [self.view addSubview:indicator];
        [indicator bringSubviewToFront:self.view];
        [indicator startAnimating];
        @try{
            self.smartSpaceDAO = [[SmartSpaceDAO alloc]init];
            [self.smartSpaceDAO getSignupData];
            self.adminAcctModel=[self.smartSpaceDAO getAdminAccount];
            self.planArray = self.smartSpaceDAO.planArray ;
            self.addonList = [self.smartSpaceDAO getAllAddons];
            self.offerList = [self.smartSpaceDAO getPlanOffers];
            self.noOfdaystoSubsDate = self.smartSpaceDAO.noOfdaystoSubsDate;
            self.trialEndsAt = self.smartSpaceDAO.trialEndsAt;
            self.firstsubDate  = self.smartSpaceDAO.firstsubDate;
            self.noOFDaysInMoth  = self.smartSpaceDAO.noOFDaysInMoth;
            self.message = self.smartSpaceDAO.message;
            self.noOfdaystoNextMonth = self.smartSpaceDAO.noOfdaystoNextMonth;
        }@catch(NSException *exp){
            error =exp.description;;
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            if(error != nil){
                self.errorViewHeight.constant = 30;
                self.errorText.text= error;
                self.errorView.hidden = false;
                self.errorViewTop.constant=5;
                self.existingMmbrLyt.hidden=true;
            }else{

                
                [self collpasePlan];
                
            }
        });
    });
}


@end
