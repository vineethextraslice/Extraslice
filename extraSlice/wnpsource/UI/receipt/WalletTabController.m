//
//  WalletTabController.m
//  walkNPay
//
//  Created by Administrator on 03/02/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "WalletTabController.h"
#import "MyReceipts.h"
#import "WnPConstants.h"
#import "MyCards.h"
#import "Utilities.h"

@interface WalletTabController ()
@property(strong,nonatomic) WnPConstants *wnpCont;
@property(strong,nonatomic) UIViewController *previousController;
@property(strong,nonatomic) UITapGestureRecognizer *rcptTap;
@property(strong,nonatomic) Utilities *utils;
@end

@implementation WalletTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.previousController=nil;
    self.wnpCont=[[WnPConstants alloc]init];
    self.utils=[[Utilities alloc]init];
    self.myRcpttab.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.myCardTab.backgroundColor=[UIColor grayColor];
    
    self.rcptTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    self.rcptTap.numberOfTapsRequired = 1;
    self.rcptTap.numberOfTouchesRequired = 1;
    self.myRcpttab.tag=100;
    [self.myRcpttab setUserInteractionEnabled:YES];
    [self.myRcpttab addGestureRecognizer:self.rcptTap];
    
    UITapGestureRecognizer *cartTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    cartTap.numberOfTapsRequired = 1;
    cartTap.numberOfTouchesRequired = 1;
    [self.myCardTab setUserInteractionEnabled:YES];
    [self.myCardTab addGestureRecognizer:cartTap];
    
    self.seperator.backgroundColor=[self.wnpCont getThemeHeaderColor];
   

}
-(void)viewDidAppear:(BOOL)animated{
      [super viewWillAppear:animated];
     [self tapDetected:self.rcptTap];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void) tapDetected:(UIGestureRecognizer *)recognizer{
    if(self.previousController != nil){
        self.previousController.view.clearsContextBeforeDrawing=TRUE;
        for(UIView *view in self.previousController.view.subviews)
        {
            [view removeFromSuperview];
        }
    }
    if(recognizer.view.tag==100){
        self.myRcpttab.backgroundColor=[self.wnpCont getThemeBaseColor];
        self.myRcpttab.textColor=[UIColor whiteColor];
        self.myCardTab.backgroundColor=[self.utils getLightGray];
        self.myCardTab.textColor=[UIColor blackColor];
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MyReceipts" bundle:nil];
        MyReceipts *viewController=[stryBrd instantiateViewControllerWithIdentifier:@"MyReceipts"];
        [self addChildViewController:viewController];
        [self.tabContentView addSubview:viewController.view];
        [viewController.view setUserInteractionEnabled:YES];
        self.previousController=viewController;
    }else{
        self.myCardTab.backgroundColor=[self.wnpCont getThemeBaseColor];
        self.myCardTab.textColor=[UIColor whiteColor];
        self.myRcpttab.backgroundColor=[self.utils getLightGray];
        self.myRcpttab.textColor=[UIColor blackColor];
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MyCards" bundle:nil];
        MyCards *viewController=[stryBrd instantiateViewControllerWithIdentifier:@"MyCards"];
        [self addChildViewController:viewController];
        [self.tabContentView addSubview:viewController.view];
        [viewController.view setUserInteractionEnabled:YES];
        self.previousController=viewController;
    }
}

@end
