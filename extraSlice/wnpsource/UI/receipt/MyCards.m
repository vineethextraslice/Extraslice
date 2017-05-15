//
//  MyCards.m
//  walkNPay
//
//  Created by Administrator on 03/02/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "MyCards.h"
#import "CouponDAO.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"
#import "DealerDAO.h"
#import "DealerModel.h"

@interface MyCards ()
@property (strong,nonatomic) CouponDAO *cpnDAO;
@property(strong,nonatomic) WnPConstants *wnpCont;
@property(strong,nonatomic) WnPUtilities *utils;
@end

@implementation MyCards

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cpnDAO=[[CouponDAO alloc]init];
    self.wnpCont=[[WnPConstants alloc]init];
    self.utils=[[WnPUtilities alloc]init];
 

    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.rechargeLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Recharge" attributes:underlineAttribute];
    UITapGestureRecognizer *linkTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    linkTap.numberOfTapsRequired = 1;
    linkTap.numberOfTouchesRequired = 1;
    [self.rechargeLabel setUserInteractionEnabled:YES];
    [self.rechargeLabel addGestureRecognizer:linkTap];
    self.rechargeLabel.textColor=[self.wnpCont getThemeBaseColor];
    
    @try{
        NSNumber *prepaidBal=[self.cpnDAO getPrepaidBalance:[self.wnpCont getUserId]];
        self.availableLabel.text = [NSString stringWithFormat:@"%s%@%@","Available balance ",[self.wnpCont getCurrencySymbol],[self.utils getNumberFormatter:prepaidBal.doubleValue]];;
    }
    @catch (NSException *exception) {
        self.availableLabel.text = [NSString stringWithFormat:@"%s%@%s","Available balance ",[self.wnpCont getCurrencySymbol],"00.00"];
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) tapDetected:(UIGestureRecognizer *)recognizer{
    @try{
        self.view.backgroundColor=[UIColor grayColor];
        DealerDAO *dlrDAO=[[DealerDAO alloc]init];
        NSArray *dealerArray=[dlrDAO getAllDealer];
        DealerModel *dlrModel = [dealerArray objectAtIndex:0];
        NSString *publicKey=[self.utils decode:dlrModel.stripePublushKey];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshPrepaidData" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPrepaidData) name:@"refreshPrepaidData" object:nil];
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"PrepaidPopup" bundle:nil];
        PrepaidPopup *viewController=[stryBrd instantiateViewControllerWithIdentifier:@"PrepaidPopup"];
        
        viewController.strpPubKey= publicKey ;
        viewController.paypalEnv=dlrModel.paypalEnv;
        viewController.paypalClientId=dlrModel.paypalClientId;
        viewController.currencyCode=@"USD";
        viewController.custRechMinAmt=dlrModel.minRechargeAmt;
    
        UIView *dashboardView = viewController.view;
        [dashboardView setFrame:CGRectMake(self.view.bounds.origin.x-155,self.view.bounds.origin.x-180,310,360)];
    
        [self.view addSubview:dashboardView];
        [self addChildViewController:viewController];
        for(UIView *subViews in [self.view subviews]){
            subViews.alpha=0.2;
            [subViews setUserInteractionEnabled:NO];
        }
        
        for(UIView *subViews in [self.parentViewController.view subviews]){
            if ([subViews isKindOfClass:[UILabel class]]) {
                subViews.alpha=0.2;
                [subViews setUserInteractionEnabled:NO];
            }
           
        }
    
        dashboardView.alpha=1;
        [dashboardView setUserInteractionEnabled:YES];
        //dashboardView.center = self.view.center;
        dashboardView.center = CGPointMake(self.view.center.x, self.view.center.y-100);
    }@catch (NSException *exception) {
        self.view.backgroundColor=[UIColor whiteColor];
        self.availableLabel.text = [NSString stringWithFormat:@"%s%@%s","Available balance ",[self.wnpCont getCurrencySymbol],"00.00"];
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
    }
}

- (void) refreshPrepaidData{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshPrepaidData" object:nil];
    @try{
        NSNumber *prepaidBal=[self.cpnDAO getPrepaidBalance:[self.wnpCont getUserId]];
        self.availableLabel.text = [NSString stringWithFormat:@"%s%@%@","Available balance ",[self.wnpCont getCurrencySymbol],prepaidBal.stringValue];;
    }
    @catch (NSException *exception) {
        self.availableLabel.text = [NSString stringWithFormat:@"%s%@%s","Available balance ",[self.wnpCont getCurrencySymbol],"00.00"];
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
    }
}
@end
