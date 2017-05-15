//
//  UserProfile.m
//  walkNPay
//
//  Created by Administrator on 28/01/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "WnPUserProfile.h"
#import "WnPConstants.h"
#import "MenuController.h"
#import "WnPUpdateProfile.h"
#import "WnPChangePassword.h"

#import "WnPUtilities.h"
#import "WnPUserDAO.h"




@interface WnPUserProfile ()
@property(strong,nonatomic) WnPConstants *wnpCont;
@property(strong,nonatomic) WnPUtilities *utils;

@end

@implementation WnPUserProfile

- (void)viewDidLoad {
    self.wnpCont= [[WnPConstants alloc] init];
    [super viewDidLoad];
    UITapGestureRecognizer *theme1Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(changeTheme:)];
    theme1Tap.numberOfTapsRequired = 1;
    theme1Tap.numberOfTouchesRequired = 1;
    [self.preference1 setUserInteractionEnabled:YES];
    [self.preference1 addGestureRecognizer:theme1Tap];
    
    UITapGestureRecognizer *theme2Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(changeTheme:)];
    theme2Tap.numberOfTapsRequired = 1;
    theme2Tap.numberOfTouchesRequired = 1;
    [self.preference2 setUserInteractionEnabled:YES];
    [self.preference2 addGestureRecognizer:theme2Tap];
    
    UITapGestureRecognizer *theme3Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(changeTheme:)];
    theme3Tap.numberOfTapsRequired = 1;
    theme3Tap.numberOfTouchesRequired = 1;
    [self.preference3 setUserInteractionEnabled:YES];
    [self.preference3 addGestureRecognizer:theme3Tap];
    self.preference1.backgroundColor=[self.wnpCont getColor:0];
    self.preference2.backgroundColor=[self.wnpCont getColor:1];
    self.preference3.backgroundColor=[self.wnpCont getColor:2];
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.updateProfile.attributedText = [[NSAttributedString alloc] initWithString:@"Update" attributes: underlineAttribute];
    self.changePwd.attributedText = [[NSAttributedString alloc] initWithString:@"Change" attributes: underlineAttribute];
    self.updateProfile.textColor=[self.wnpCont getThemeBaseColor];
    self.changePwd.textColor=[self.wnpCont getThemeBaseColor];
    
    UITapGestureRecognizer *updateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(updateProfile:)];
    updateTap.numberOfTapsRequired = 1;
    updateTap.numberOfTouchesRequired = 1;
    [self.updateProfile setUserInteractionEnabled:YES];
    [self.updateProfile addGestureRecognizer:updateTap];
    
    UITapGestureRecognizer *pwdTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(changePassword:)];
    pwdTap.numberOfTapsRequired = 1;
    pwdTap.numberOfTouchesRequired = 1;
    [self.changePwd setUserInteractionEnabled:YES];
    [self.changePwd addGestureRecognizer:pwdTap];
    self.autoEmail.onTintColor=[self.wnpCont getThemeBaseColor];
    [self.autoEmail setOn:[self.wnpCont getUserModel].autoEmail];
    [self.autoEmail addTarget:self action:@selector(changeAutoEmail:) forControlEvents:UIControlEventValueChanged];
    
    
}
- (void)changeTheme:(UIGestureRecognizer *)recognizer {
    int index = (int)recognizer.view.tag;
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:index forKey:@"theme"];
    [self.wnpCont setColor:index];
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
    MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
    if(viewCtrl != nil){
        viewCtrl.loadScanpopup =YES;
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        viewCtrl.viewName=@"Name";
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }

}
- (void)changePassword:(UIGestureRecognizer *)recognizer {
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
    }
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"WnPChangePassword" bundle:nil];
    WnPChangePassword *viewController=[stryBrd instantiateViewControllerWithIdentifier:@"WnPChangePassword"];
    // UIView *dashboardView = viewController.view;
    // [dashboardView setFrame:CGRectMake(self.view.bounds.origin.x-90,self.view.bounds.origin.y-100,180,200)];
    
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [self.view bringSubviewToFront:viewController.view];
    [viewController.view setUserInteractionEnabled:YES];
    viewController.view.center = self.view.center;
    for(UIView *uisv in [viewController.view subviews]){
        [uisv setUserInteractionEnabled:YES];
    }
    
}
- (void)updateProfile:(UIGestureRecognizer *)recognizer {
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
    }
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"WnPUpdateProfile" bundle:nil];
    WnPUpdateProfile *viewController=[stryBrd instantiateViewControllerWithIdentifier:@"WnPUpdateProfile"];
    // UIView *dashboardView = viewController.view;
    // [dashboardView setFrame:CGRectMake(self.view.bounds.origin.x-90,self.view.bounds.origin.y-100,180,200)];
    
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [self.view bringSubviewToFront:viewController.view];
    [viewController.view setUserInteractionEnabled:YES];
    viewController.view.center = self.view.center;
    for(UIView *uisv in [viewController.view subviews]){
        [uisv setUserInteractionEnabled:YES];
    }

    
}





- (void)changeAutoEmail:(id)sender{
    //UISwitch swt = [UISwitch]
    BOOL switchVal =[sender isOn];
    WnPUserModel *model=[self.wnpCont getUserModel];
    model.autoEmail=switchVal;
    @try {
        WnPUserDAO *userDao=[[WnPUserDAO alloc]init];
        model= [userDao updateUser:model];
        [self.wnpCont setUserModel:model];
    }
    @catch (NSException *exception) {
        [self.autoEmail setOn:!switchVal];
    }
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

@end
