//
//  MenuController.m
//  extraSlice
//
//  Created by Administrator on 27/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "MenuController.h"
#import "ESliceConstants.h"
#import "HomeScreen.h"
#import "ReserveConfRoom.h"
#import "Utilities.h"
#import "WnPUtilities.h"
#import "SupportController.h"
#import "AboutController.h"
#import "MyConfRoomReservations.h"
#import "OrganizationModel.h"
#import "SmartSpaceDAO.h"
#import "ProfileScreen.h"
#import "ForumScreen.h"
#import "HomeViewController.h"
#import "CartScreenController.h"
#import "PaymentGateway.h"
#import "PaymentStatus.h"
#import "RecieptController.h"
#import "MyReceipts.h"
#import "StoreSelector.h"
#import "StoreDAO.h"
#import "WnPUserDAO.h"
#import "SelectPlanController.h"

static UIViewController *newController;
@interface MenuController ()
@property (strong, nonatomic) IBOutlet UITableView *navTable;
@property (strong, nonatomic) NSMutableArray *navItems;
@property (strong, nonatomic) NSMutableArray *navItemsImg;
@property (strong, nonatomic) ESliceConstants *wnpCont;
@property (strong, nonatomic) WnPConstants *storeCont;
@property(strong,nonatomic) Utilities *utils;
@property(strong,nonatomic) WnPUtilities *wnpUtils;

@property (strong, nonatomic) StoreDAO *storeDao;
@end

@implementation MenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wnpCont =[[ESliceConstants alloc] init];
     self.storeCont =[[WnPConstants alloc] init];
    self.utils = [[Utilities alloc]init];
    self.wnpUtils= [[WnPUtilities alloc]init];
    self.navItems = [[NSMutableArray alloc]init];
    self.storeDao = [[StoreDAO alloc]init];
    [self.navItems addObject:@""];
    self.navItemsImg= [[NSMutableArray alloc]init];
    [self.navItemsImg addObject:@"ic_drawer2.png"];
  

    if([[self.utils getLoggedinUser].userType.lowercaseString isEqualToString:@"member"]){
        [self.navItems addObject:@"Name"];
        [self.navItems addObject:@"Home"];
        [self.navItems addObject:@"Reservation"];
        [self.navItems addObject:@"My Reservations"];
        [self.navItems addObject:@"Support"];
        [self.navItems addObject:@"walkNpay store"];
        [self.navItems addObject:@"About"];
        [self.navItems addObject:@"Logout"];
        
        [self.navItemsImg addObject:@"defaultprofilepic.png"];
        [self.navItemsImg addObject:@"home_black.png"];
        [self.navItemsImg addObject:@"calendar.png"];
        [self.navItemsImg addObject:@"mybookings.png"];
        [self.navItemsImg addObject:@"headset.png"];
        [self.navItemsImg addObject:@"walknpay2.png"];
        [self.navItemsImg addObject:@"about13.png"];
        [self.navItemsImg addObject:@"logout_black.png"];
        
    }else{
        [self.navItems addObject:@"walkNpay store"];
        [self.navItems addObject:@"Join extraSlice"];
        [self.navItems addObject:@"Support"];
        [self.navItems addObject:@"About"];
        [self.navItems addObject:@"Logout"];
        
        [self.navItemsImg addObject:@"walknpay2.png"];
        [self.navItemsImg addObject:@"joinslice.png"];
        [self.navItemsImg addObject:@"headset.png"];
        [self.navItemsImg addObject:@"about13.png"];
        [self.navItemsImg addObject:@"logout_black.png"];
    }
    
   
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showHideMenu)];
     singleTap.numberOfTapsRequired = 1;
     singleTap.numberOfTouchesRequired = 1;
     [self.menuIcon setUserInteractionEnabled:YES];
     [self.menuIcon addGestureRecognizer:singleTap];
     CGRect screenRect1 = [[UIScreen mainScreen] bounds];
     self.navTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0, (screenRect1.size.width*0.75), (screenRect1.size.height))];
     self.navTable.dataSource=self;
     self.navTable.delegate=self;
     self.navTable.rowHeight=55;
     self.navTable.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
     [self.view addSubview:self.navTable];
     self.navTable.hidden=TRUE;
     self.navTable.separatorStyle=UITableViewCellSeparatorStyleNone;
     self.navTable.scrollEnabled=false;
     CATransition *animation = [CATransition animation];
     animation.type = kCATransitionFromLeft;
     animation.duration = 0.5;
     [self.navTable.layer addAnimation:animation forKey:nil];
     UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
     recognizer.direction = UISwipeGestureRecognizerDirectionRight;
     recognizer.numberOfTouchesRequired = 1;
     recognizer.delegate = self;
     [self.navTable setUserInteractionEnabled:true];
     [self.navTable addGestureRecognizer:recognizer];
     [self loadViewData:viewName];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void )setViewName:(NSString *) newView{
    viewName = newView;
}
- (void) SwipeRecognizer:(UISwipeGestureRecognizer *)sender {
    if ( sender.direction == UISwipeGestureRecognizerDirectionLeft ){
        if(!self.navTable.hidden){
            [self showHideMenu];
        }
    }
}



- (void)hideMenu {
    self.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=1.0;
        [subViews setUserInteractionEnabled:YES];
    }
    self.navTable.alpha =0.0;
    self.navTable.hidden=TRUE;
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFromTop;
    animation.duration = 0.6;
    [self.view.layer addAnimation:animation forKey:nil];
}
- (void)showHideMenu {
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideMenu)];
    tapView.numberOfTapsRequired = 1;
    tapView.numberOfTouchesRequired = 1;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapView];
    
    if(self.navTable.hidden){
        self.view.backgroundColor=[UIColor grayColor];
        for(UIView *subViews in [self.view subviews]){
            subViews.alpha=0.2;
            [subViews setUserInteractionEnabled:FALSE];
            
        }
        self.menuIcon.alpha=1.0;
        self.menuIcon.userInteractionEnabled=true;
        self.navTable.alpha =1.0;
        self.navTable.hidden=FALSE;
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFromTop;
        animation.duration = 0.6;
        [self.view.layer addAnimation:animation forKey:nil];
        [self.navTable setUserInteractionEnabled:YES];
        
    }else{
        self.view.backgroundColor=[UIColor whiteColor];
        for(UIView *subViews in [self.view subviews]){
            subViews.alpha=1.0;
            [subViews setUserInteractionEnabled:YES];
        }
        self.navTable.alpha =0.0;
        self.navTable.hidden=TRUE;
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFromTop;
        animation.duration = 0.6;
        [self.view.layer addAnimation:animation forKey:nil];
    }
}
- (void)displayView:(UIGestureRecognizer *)recognizer  {
    NSString *fncs = [self.navItems objectAtIndex:recognizer.view.tag];
    NSLog(@"displayView methosd");
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=1.0;
        [subViews setUserInteractionEnabled:YES];
    }
    self.navTable.alpha =0.0;
    self.navTable.hidden=TRUE;
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFromTop;
    animation.duration = 0.6;
    [self.view.layer addAnimation:animation forKey:nil];
    [self loadViewData:fncs];
}
- (void) clearPreviousView:(UIViewController * ) newController{
    if(newController !=nil){
        newController.view.clearsContextBeforeDrawing=TRUE;
        for(UIView *view in newController.view.subviews)
        {
            [view removeFromSuperview];
        }
    }
}
- (void)loadViewData:(id)sender {
    self.view.backgroundColor=[UIColor whiteColor];
    if(newController != nil){
        newController.view.clearsContextBeforeDrawing=TRUE;
    }
    
    if ([sender isEqualToString:@"Name"]) {
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"ProfileScreen" bundle:nil];
        ProfileScreen *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"ProfileScreen"];
        [self addChildViewController:viewCtrl];
      //  viewCtrl.view.frame = self.containerFrame.bounds ;
        [self.containerFrame setClearsContextBeforeDrawing:TRUE];
        [self.containerFrame addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;

    }else if ([sender isEqualToString:@"walkNpay store"]) {
        if([self.storeCont getUserModel] == nil){
            WnPUserDAO *wnpUsrDao = [[WnPUserDAO alloc]init];
            [self.storeCont setUserModel:[wnpUsrDao authenticateESliceUser:[self.utils getLoggedinUser]]];
            [self.storeCont setUserId:[self.storeCont getUserModel].userId];
            [self.storeCont setUserName:[self.storeCont getUserModel].userName];
        }
        
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"WnPHomeScreen" bundle:nil];
        HomeViewController *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"WnPHomeScreen"];
        //viewCtrl.resetPwd =self.resetPwd;
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.containerFrame.bounds ;
        [self.containerFrame setClearsContextBeforeDrawing:TRUE];
        [self.containerFrame addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    }else if ([sender isEqualToString:@"Home"]) {
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"HomeScreen" bundle:nil];
        HomeScreen *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"HomeScreen"];
        //viewCtrl.resetPwd =self.resetPwd;
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.containerFrame.bounds ;
        [self.containerFrame setClearsContextBeforeDrawing:TRUE];
        [self.containerFrame addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    }else if ([sender isEqualToString:@"Reservation"]) {
        BOOL isActivated = FALSE;
        if([self.utils getLoggedinUser].orgList !=nil){
            for(NSDictionary *dic in [self.utils getLoggedinUser].orgList){
                OrganizationModel *org=[[OrganizationModel alloc]init];
                org=[org initWithDictionary:dic];
                if(org.approved){
                    isActivated=TRUE;
                    break;
                }
            }
        }
        if(isActivated){
            [self clearPreviousView:newController];
            self.stryBrd = [UIStoryboard storyboardWithName:@"ReserveConfRoom" bundle:nil];
            ReserveConfRoom *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"ReserveConfRoom"];
            //viewCtrl.resetPwd =self.resetPwd;
            [self addChildViewController:viewCtrl];
            viewCtrl.view.frame = self.containerFrame.bounds ;
            [self.containerFrame setClearsContextBeforeDrawing:TRUE];
            [self.containerFrame addSubview:viewCtrl.view];
            [viewCtrl didMoveToParentViewController:self];
            newController = viewCtrl;
        }else{
            UIAlertAction *alert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"Please update your plan/Organization details" preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:alert];
            [self presentViewController:controller animated:YES completion:nil];
            self.stryBrd = [UIStoryboard storyboardWithName:@"HomeScreen" bundle:nil];
            HomeScreen *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"HomeScreen"];
            //viewCtrl.resetPwd =self.resetPwd;
            [self addChildViewController:viewCtrl];
            viewCtrl.view.frame = self.containerFrame.bounds ;
            [self.containerFrame setClearsContextBeforeDrawing:TRUE];
            [self.containerFrame addSubview:viewCtrl.view];
            [viewCtrl didMoveToParentViewController:self];
            newController = viewCtrl;
        }
        
        
    }else if ([sender isEqualToString:@"Support"]) {
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"Support" bundle:nil];
        SupportController *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"Support"];
        //viewCtrl.resetPwd =self.resetPwd;
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.containerFrame.bounds ;
        [self.containerFrame setClearsContextBeforeDrawing:TRUE];
        [self.containerFrame addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    }else if ([sender isEqualToString:@"Forum"]) {
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"ForumScreen" bundle:nil];
        ForumScreen *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"ForumScreen"];
        //viewCtrl.resetPwd =self.resetPwd;
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.containerFrame.bounds ;
        [self.containerFrame setClearsContextBeforeDrawing:TRUE];
        [self.containerFrame addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    }else if ([sender isEqualToString:@"About"]) {
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"About" bundle:nil];
        AboutController *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"About"];
        //viewCtrl.resetPwd =self.resetPwd;
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.containerFrame.bounds ;
        [self.containerFrame setClearsContextBeforeDrawing:TRUE];
        [self.containerFrame addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    }else if ([sender isEqualToString:@"MyConfBookings"]) {
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"MyConfReservations" bundle:nil];
        MyConfRoomReservations *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"MyConfReservations"];
        viewCtrl.currSchedules =self.currSchedules;
        viewCtrl.selectedDate=self.selectedDate;
        viewCtrl.selectedDayType =self.selectedDayType;
        
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.containerFrame.bounds ;
        [self.containerFrame setClearsContextBeforeDrawing:TRUE];
        [self.containerFrame addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    }else if([sender isEqualToString:@"My Reservations"]) {
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"MyConfReservations" bundle:nil];
        MyConfRoomReservations *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"MyConfReservations"];

        viewCtrl.selectedDayType =@"Day";
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.containerFrame.bounds ;
        [self.containerFrame setClearsContextBeforeDrawing:TRUE];
        [self.containerFrame addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    }
    else if ([sender isEqualToString:@"Logout"]) {
        [self clearPreviousView:newController];
        SmartSpaceDAO *smDAO = [[SmartSpaceDAO alloc] init];
        [self.utils setLoggedinUser:nil];
        
        [smDAO reset];
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginController" bundle:nil];
        UIViewController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginController"];
        [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
    }else if ([sender isEqualToString:@"Scan"]) {
        
        if([self.storeCont getSelectedStoreId].intValue > 0){
            [self clearPreviousView:newController];
            self.stryBrd = [UIStoryboard storyboardWithName:@"CartScreen" bundle:nil];
            CartScreenController *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"CartScreen"];
            viewCtrl.loadScanpopup=true;
            [self addChildViewController:viewCtrl];
            viewCtrl.view.frame = self.containerFrame.bounds ;
            [self.containerFrame setClearsContextBeforeDrawing:TRUE];
            [self.containerFrame addSubview:viewCtrl.view];
            [viewCtrl didMoveToParentViewController:self];
            newController = viewCtrl;
        }else{
            [self showStoreSelectionPopup:TRUE];
        }
        
    } else if ([sender isEqualToString:@"Cart"]) {
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"CartScreen" bundle:nil];
        CartScreenController *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"CartScreen"];
         viewCtrl.loadScanpopup=false;
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.containerFrame.bounds ;
        [self.containerFrame setClearsContextBeforeDrawing:TRUE];
        [self.containerFrame addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;

        
    }else if ([sender isEqualToString:@"Change store"]) {
        [self showStoreSelectionPopup:FALSE];
    }else if ([sender isEqualToString:@"Checkout"]) {
        
        NSMutableArray *prodcutArray =[self.storeCont getItemsFromArray];
        if(prodcutArray.count == 0){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No items added yet" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }else{
            if(self.totalAmount.doubleValue <=0){
                [self calculateTotal];
            }
            [self clearPreviousView:newController];
            self.stryBrd = [UIStoryboard storyboardWithName:@"PaymentOption" bundle:nil];
            PaymentGateway *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"PaymentOption"];
            [self addChildViewController:viewCtrl];
            viewCtrl.totalAmount = self.totalAmount;
            viewCtrl.view.frame = self.containerFrame.bounds ;
            [self.containerFrame setClearsContextBeforeDrawing:TRUE];
            [self.containerFrame addSubview:viewCtrl.view];
            [viewCtrl didMoveToParentViewController:self];
            newController = viewCtrl;
        }
    }else if ([sender isEqualToString:@"PayStatus"]) {
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"PaymentStatus" bundle:nil];
        PaymentStatus *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"PaymentStatus"];
        viewCtrl.status = self.status;
        viewCtrl.errorMessage = self.errorMessage;
        viewCtrl.reciept=self.reciept;

        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.containerFrame.bounds ;
        [self.containerFrame setClearsContextBeforeDrawing:TRUE];
        [self.containerFrame addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    }else if ([sender isEqualToString:@"Reciept"]) {
        
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"Reciept" bundle:nil];
        RecieptController *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"Reciept"];
        [self addChildViewController:viewCtrl];
        viewCtrl.reciept = self.reciept;
        viewCtrl.view.frame = self.containerFrame.bounds ;
        [self.containerFrame setClearsContextBeforeDrawing:TRUE];
        [self.containerFrame addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    }else if ([sender isEqualToString:@"Wallet"]) {
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"WalletTab" bundle:nil];
        MyReceipts *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"WalletTab"];
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.containerFrame.bounds ;
        [self.containerFrame setClearsContextBeforeDrawing:TRUE];
        [self.containerFrame addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    }else if([sender isEqualToString:@"Join extraSlice"]){
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"SelectPlan" bundle:nil];
        SelectPlanController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"SelectPlan"];
        [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
    }

}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.navItems.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *celId =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:celId];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
    }
    CGRect screenRect1 = [[UIScreen mainScreen] bounds];
     if([[self.utils getLoggedinUser].userType.lowercaseString isEqualToString:@"member"]){
         if(indexPath.row ==0){
             
             
             UIImageView *itemIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 30 , 30, 30)];
             [itemIcon setImage:[UIImage imageNamed:[self.navItemsImg objectAtIndex:indexPath.row]]];
             itemIcon.clipsToBounds =TRUE;
             [itemIcon setUserInteractionEnabled:YES];
             
             UITapGestureRecognizer *iconRecgnizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideMenu)];
             itemIcon.tag = indexPath.row;
             [iconRecgnizer setNumberOfTapsRequired:1];
             [itemIcon addGestureRecognizer:iconRecgnizer];
             [cell addSubview:itemIcon];
             
             
             cell.backgroundColor=[UIColor whiteColor];
             
         }else if(indexPath.row ==1){
             
             UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(10, 10 ,  ((screenRect1.size.width*0.75)-50), 30)];
             UIFont *txtFont = [code.font fontWithSize:14.0];
             code.font = txtFont;
             [code setUserInteractionEnabled:TRUE];
             [code setEnabled:YES];
             UITapGestureRecognizer *textRecgnizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayView:)];
             code.tag = indexPath.row;
             [textRecgnizer setNumberOfTapsRequired:1];
             [code addGestureRecognizer:textRecgnizer];
             code.text=[self.utils getLoggedinUser].email;
             code.textColor=[UIColor whiteColor];
             //[code sizeToFit];
             [cell addSubview:code];
             
             UIImageView *itemIcon = [[UIImageView alloc] initWithFrame:CGRectMake((code.frame.origin.x+code.frame.size.width+5), 10 , 30, 30)];
             [itemIcon setImage:[UIImage imageNamed:[self.navItemsImg objectAtIndex:indexPath.row]]];
             itemIcon.clipsToBounds =TRUE;
             [itemIcon setUserInteractionEnabled:YES];
             
             UITapGestureRecognizer *iconRecgnizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayView:)];
             itemIcon.tag = indexPath.row;
             [iconRecgnizer setNumberOfTapsRequired:1];
             [itemIcon addGestureRecognizer:iconRecgnizer];
             [cell addSubview:itemIcon];
             
             UITapGestureRecognizer *cellRecog=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayView:)];
             cell.tag = indexPath.row;
             [cellRecog setNumberOfTapsRequired:1];
             [cell addGestureRecognizer:cellRecog];
             
             cell.backgroundColor=[self.utils getThemeLightBlue];
             
         }else{
             UIImageView *itemIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10 , 30, 30)];
             [itemIcon setImage:[UIImage imageNamed:[self.navItemsImg objectAtIndex:indexPath.row]]];
             itemIcon.clipsToBounds =TRUE;
             [itemIcon setUserInteractionEnabled:YES];
             
             UITapGestureRecognizer *iconRecgnizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayView:)];
             itemIcon.tag = indexPath.row;
             [iconRecgnizer setNumberOfTapsRequired:1];
             [itemIcon addGestureRecognizer:iconRecgnizer];
             [cell addSubview:itemIcon];
             
             
             
             UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(55, 10 ,  ((screenRect1.size.width*0.75)-50), 30)];
             UIFont *txtFont = [code.font fontWithSize:14.0];
             code.font = txtFont;
             [code setUserInteractionEnabled:TRUE];
             [code setEnabled:YES];
             UITapGestureRecognizer *textRecgnizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayView:)];
             code.tag = indexPath.row;
             [textRecgnizer setNumberOfTapsRequired:1];
             [code addGestureRecognizer:textRecgnizer];
             
             
             code.text=[self.navItems objectAtIndex:indexPath.row];
             [cell addSubview:code];
             
             UITapGestureRecognizer *cellRecog=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayView:)];
             cell.tag = indexPath.row;
             [cellRecog setNumberOfTapsRequired:1];
             [cell addGestureRecognizer:cellRecog];
         }

     }else{
         if(indexPath.row ==0){
             
             
             UIImageView *itemIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 30 , 30, 30)];
             [itemIcon setImage:[UIImage imageNamed:[self.navItemsImg objectAtIndex:indexPath.row]]];
             itemIcon.clipsToBounds =TRUE;
             [itemIcon setUserInteractionEnabled:YES];
             
             UITapGestureRecognizer *iconRecgnizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideMenu)];
             itemIcon.tag = indexPath.row;
             [iconRecgnizer setNumberOfTapsRequired:1];
             [itemIcon addGestureRecognizer:iconRecgnizer];
             [cell addSubview:itemIcon];
             
             
             cell.backgroundColor=[self.wnpCont getThemeBaseColor];
             
         }else{
             UIImageView *itemIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10 , 30, 30)];
             [itemIcon setImage:[UIImage imageNamed:[self.navItemsImg objectAtIndex:indexPath.row]]];
             itemIcon.clipsToBounds =TRUE;
             [itemIcon setUserInteractionEnabled:YES];
         
             UITapGestureRecognizer *iconRecgnizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayView:)];
             itemIcon.tag = indexPath.row;
             [iconRecgnizer setNumberOfTapsRequired:1];
             [itemIcon addGestureRecognizer:iconRecgnizer];
             [cell addSubview:itemIcon];
         
         
         
             UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(55, 10 ,  ((screenRect1.size.width*0.75)-50), 30)];
             UIFont *txtFont = [code.font fontWithSize:14.0];
             code.font = txtFont;
             [code setUserInteractionEnabled:TRUE];
             [code setEnabled:YES];
             UITapGestureRecognizer *textRecgnizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayView:)];
             code.tag = indexPath.row;
             [textRecgnizer setNumberOfTapsRequired:1];
             [code addGestureRecognizer:textRecgnizer];
         
         
             code.text=[self.navItems objectAtIndex:indexPath.row];
             [cell addSubview:code];
         
             UITapGestureRecognizer *cellRecog=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayView:)];
             cell.tag = indexPath.row;
             [cellRecog setNumberOfTapsRequired:1];
             [cell addGestureRecognizer:cellRecog];
         }
     }
    
    self.navTable.rowHeight=55;
    
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(5, 55 ,  ((screenRect1.size.width*0.75)-10), 1)];
    [seperator setBackgroundColor:[self.wnpCont getThemeHeaderColor]];
    [cell addSubview:seperator];
    
    return cell;
}
- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *) newIndexPath{
    //UITextField* tf = (UITextField *) [tableView viewWithTag:newIndexPath.row+1000];
    
}
- (void) showStoreSelectionPopup:(BOOL ) notifyAfter{
    NSArray *storeArray = [[NSArray alloc]init];
    NSString *error=nil;
    BOOL showPopup=false;
    @try {
        storeArray = [self.storeDao  getAllStoresForDealerByLocation:@1];
        if (storeArray == nil || storeArray.count ==0) {
            error=@"No store found";
            showPopup=false;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No stores found" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            
            [alert show];
        }else if(storeArray.count ==1){
            if(!notifyAfter){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Only one store available" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                
                [alert show];
            }
            StoreModel *strMdl = [storeArray objectAtIndex:0];
            [self.storeCont setSelectedStoreId:strMdl.storeId];
            [self.storeCont setCurrencyCode:strMdl.currencyCode];
            [self.storeCont setCurrencySymbol:strMdl.currencySymbol];
            showPopup=false;
        }else{
            showPopup=true;
        }
    }
    @catch (NSException *exception) {
        showPopup=true;
        error=exception.description;
    }
    if(showPopup){
        self.view.backgroundColor=[UIColor grayColor];
        for(UIView *subViews in [self.view subviews]){
            subViews.alpha=0.2;
        }
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"StoreSelector" bundle:nil];
        StoreSelector *viewController=[stryBrd instantiateViewControllerWithIdentifier:@"StoreSelector"];
        viewController.errorText=error;
        viewController.storeArray=storeArray;
        viewController.notifyAfter=notifyAfter;
        [self addChildViewController:viewController];
        [self.view addSubview:viewController.view];
        [self.view bringSubviewToFront:viewController.view];
        [viewController.view setUserInteractionEnabled:YES];
        viewController.view.center = self.view.center;
        for(UIView *uisv in [viewController.view subviews]){
            [uisv setUserInteractionEnabled:YES];
        }
    }else{
        if(notifyAfter){
            [self loadViewData:@"Scan"];
        }
    }
}
-(IBAction) changeStore:(UIGestureRecognizer *)recognizer{
    self.view.backgroundColor=[UIColor whiteColor];
    NSLog(@"%@",[self.storeCont getSelectedStoreId].stringValue);
    [self loadViewData:viewName];
    
}

-(void)calculateTotal{
    NSMutableArray *prodcutArray =[self.storeCont getItemsFromArray];
    //  [prodcutArray ]
    NSNumber *subtotal =@0;
    NSNumber *tax = @0;
    self.totalAmount=[NSNumber numberWithInt:0];
    if(prodcutArray.count > 0){
        for(ProductModel* model in prodcutArray){
            subtotal = [NSNumber numberWithDouble:(subtotal.doubleValue + (model.price.doubleValue * model.purchasedQuantity.doubleValue))];
            tax = [NSNumber numberWithDouble:(tax.doubleValue + (model.taxPercentage.doubleValue * model.price.doubleValue* model.purchasedQuantity.integerValue/100) )];
        }
    }
    self.totalAmount =[NSNumber numberWithDouble:(subtotal.doubleValue + tax.doubleValue)];
    
}

@end
