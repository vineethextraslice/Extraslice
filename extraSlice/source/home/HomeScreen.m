//
//  HomeScreen.m
//  extraSlice
//
//  Created by Administrator on 25/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "HomeScreen.h"
#import "WnPConstants.h"
#import "MenuController.h"


@interface HomeScreen ()
@property(strong,nonatomic) WnPConstants *wnpConst;
@end

@implementation HomeScreen

- (void)viewDidLoad {
    self.wnpConst = [[WnPConstants alloc]init];
    [super viewDidLoad];
    self.outerBorder.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.outerBorder.layer.borderWidth = 1.0f;
    self.innerBorder1.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.innerBorder1.layer.borderWidth = 1.0f;
    self.innerBorder2.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.innerBorder2.layer.borderWidth = 1.0f;
    
    UITapGestureRecognizer *resevetap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(loadReservationPage:)];
    resevetap.numberOfTapsRequired = 1;
    resevetap.numberOfTouchesRequired = 1;
    [self.reserveImg setUserInteractionEnabled:YES];
    [self.reserveImg addGestureRecognizer:resevetap];
    
    UITapGestureRecognizer *reseveTxttap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(loadReservationPage:)];
    reseveTxttap.numberOfTapsRequired = 1;
    reseveTxttap.numberOfTouchesRequired = 1;
    [self.reserveText setUserInteractionEnabled:YES];
    [self.reserveText addGestureRecognizer:reseveTxttap];
    
    UITapGestureRecognizer *supportTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(loadSupportPage:)];
    supportTap.numberOfTapsRequired = 1;
    supportTap.numberOfTouchesRequired = 1;
    [self.supportImg setUserInteractionEnabled:YES];
    [self.supportImg addGestureRecognizer:supportTap];
    
    UITapGestureRecognizer *supportTxtTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(loadSupportPage:)];
    supportTxtTap.numberOfTapsRequired = 1;
    supportTxtTap.numberOfTouchesRequired = 1;
    [self.supportText setUserInteractionEnabled:YES];
    [self.supportText addGestureRecognizer:supportTxtTap];
}
-(void)loadReservationPage:(UITapGestureRecognizer *) rec{
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
    MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
    if(viewCtrl != nil){
              viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        viewCtrl.viewName=@"Reservation";
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }

}
-(void)loadSupportPage:(UITapGestureRecognizer *) rec{
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
    MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
    if(viewCtrl != nil){
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        viewCtrl.viewName=@"Support";
        [self presentViewController:viewCtrl animated:YES completion:nil];
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
