//
//  HomeScreen.m
//  extraSlice
//
//  Created by Administrator on 25/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "HomeScreen.h"
#import "ESliceConstants.h"
#import "MenuController.h"


@interface HomeScreen ()
@property(strong,nonatomic) ESliceConstants *wnpConst;
@end

@implementation HomeScreen

- (void)viewDidLoad {
    self.wnpConst = [[ESliceConstants alloc]init];
    [super viewDidLoad];
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat rowHeight = (screenRect.size.height-125)/3;
    CGFloat rowWidth = screenRect.size.width-40;
    
    self.innerBorder1= [[UIView alloc] initWithFrame:CGRectMake(20, 20, rowWidth, rowHeight)];
    self.innerBorder2= [[UIView alloc] initWithFrame:CGRectMake(20, (30+rowHeight), rowWidth, rowHeight)];
    self.innerBoarder3= [[UIView alloc] initWithFrame:CGRectMake(20, (40+2*rowHeight), rowWidth/2, rowHeight)];
    self.innerBoarder32= [[UIView alloc] initWithFrame:CGRectMake(19+rowWidth/2, (40+2*rowHeight), rowWidth/2, rowHeight)];
    UIView *view1 =nil;
    UIView *view2 =nil;
    UIView *view3 =nil;
    UIView *view32 =nil;
    
    if(rowHeight <140){
        view1= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-100)/2, rowWidth, 100)];
        view2= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-100)/2, rowWidth, 100)];
        view3= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-100)/2, rowWidth/2, 100)];
        view32= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-100)/2, rowWidth/2, 100)];
        
        self.reserveText = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, rowWidth, 30)];
        self.supportText = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, rowWidth, 30)];
        self.walletTxt= [[UILabel alloc] initWithFrame:CGRectMake(0, 70, rowWidth/2, 30)];
        self.wnpText = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, rowWidth/2, 30)];
        
        self.wnpImage = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/4)-30, 0, 60, 60)];
        self.wallet = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/4)-30, 0, 60, 60)];
        self.supportImg = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/2)-30, 0, 60, 60)];
        self.reserveImg = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/2)-30, 0, 60, 60)];

    }else{
        view1= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-120)/2, rowWidth, 120)];
        view2= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-120)/2, rowWidth, 120)];
        view3= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-120)/2, rowWidth/2, 120)];
        view32= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-120)/2, rowWidth/2, 120)];
        
        self.reserveText = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, rowWidth, 30)];
        self.supportText = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, rowWidth, 30)];
        self.wnpText = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, rowWidth/2, 30)];
        self.walletTxt = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, rowWidth/2, 30)];
        
        self.wnpImage = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/4)-40, 0, 80, 80)];
        self.wallet = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/4)-40, 0, 80, 80)];
        self.supportImg = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/2)-40, 0, 80, 80)];
        self.reserveImg = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/2)-40, 0, 80, 80)];
    }
    
    [self.wnpImage setImage:[UIImage imageNamed:@"walknpay2.png"]];
    [self.supportImg setImage:[UIImage imageNamed:@"headset.png"]];
    [self.reserveImg setImage:[UIImage imageNamed:@"calendar.png"]];
    [self.wallet setImage:[UIImage imageNamed:@"purse.png"]];
    
    self.reserveText.textAlignment=NSTextAlignmentCenter;
    self.supportText.textAlignment=NSTextAlignmentCenter;
    self.wnpText.textAlignment=NSTextAlignmentCenter;
    self.walletTxt.textAlignment=NSTextAlignmentCenter;


    self.reserveText.text=@"Reserve a conference room";
    self.supportText.text=@"Support";
    self.wnpText.text=@"walkNPay store";
    self.walletTxt.text=@"Wallet";;
    
    [self.reserveText setFont:[UIFont boldSystemFontOfSize:17.0]];
    [self.supportText setFont:[UIFont boldSystemFontOfSize:17.0]];
    [self.wnpText setFont:[UIFont boldSystemFontOfSize:17.0]];
    [self.walletTxt setFont:[UIFont boldSystemFontOfSize:17.0]];
    
    [view1 addSubview:self.reserveImg];
    [view2 addSubview:self.supportImg];
    [view3 addSubview:self.wnpImage];
    [view32 addSubview:self.wallet];
    
    [view1 addSubview:self.reserveText];
    [view2 addSubview:self.supportText];
    [view3 addSubview:self.wnpText];
    [view32 addSubview:self.walletTxt];

    
    [self.innerBorder1 addSubview:view1];
    [self.innerBorder2 addSubview:view2];
    [self.innerBoarder3 addSubview:view3];
    [self.innerBoarder32 addSubview:view32];
    
    
    [self.view addSubview:self.innerBorder1];
    [self.view addSubview:self.innerBorder2];
    [self.view addSubview:self.innerBoarder3];
    [self.view addSubview:self.innerBoarder32];
    self.outerBorder.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.outerBorder.layer.borderWidth = 1.0f;
    self.innerBorder1.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.innerBorder1.layer.borderWidth = 1.0f;
    self.innerBorder2.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.innerBorder2.layer.borderWidth = 1.0f;
    self.innerBoarder3.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.innerBoarder3.layer.borderWidth = 1.0f;
    self.innerBoarder32.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.innerBoarder32.layer.borderWidth = 1.0f;
    
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
    
    UITapGestureRecognizer *wnpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(loadWnpStorePage:)];
    wnpTap.numberOfTapsRequired = 1;
    wnpTap.numberOfTouchesRequired = 1;
    [self.wnpImage setUserInteractionEnabled:YES];
    [self.wnpImage addGestureRecognizer:wnpTap];
    
    UITapGestureRecognizer *wnpTextTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(loadWnpStorePage:)];
    wnpTextTap.numberOfTapsRequired = 1;
    wnpTextTap.numberOfTouchesRequired = 1;
    [self.wnpText setUserInteractionEnabled:YES];
    [self.wnpText addGestureRecognizer:wnpTextTap];
    
    UITapGestureRecognizer *walletTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(loadWallet:)];
    walletTap.numberOfTapsRequired = 1;
    walletTap.numberOfTouchesRequired = 1;
    [self.wallet setUserInteractionEnabled:YES];
    [self.wallet addGestureRecognizer:walletTap];
    
    UITapGestureRecognizer *walletTextTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(loadWallet:)];
    walletTextTap.numberOfTapsRequired = 1;
    walletTextTap.numberOfTouchesRequired = 1;
    [self.walletTxt setUserInteractionEnabled:YES];
    [self.walletTxt addGestureRecognizer:walletTextTap];
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
-(void)loadWnpStorePage:(UITapGestureRecognizer *) rec{
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
    MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
    if(viewCtrl != nil){
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        viewCtrl.viewName=@"walkNpay store";
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }
}

-(void)loadWallet:(UITapGestureRecognizer *) rec{
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
    MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
    if(viewCtrl != nil){
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        viewCtrl.viewName=@"Wallet";
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
