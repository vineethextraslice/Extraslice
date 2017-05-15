//
//  ParentViewController.m
//  WalkNPay
//
//  Created by Irshad on 11/24/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "ParentViewController.h"
#import "WnPConstants.h"
#import "PaymentGateway.h"
#import "CartScreenController.h"
#import "PaymentStatus.h"
#import "RecieptController.h"
#import "HomeViewController.h"
#import "StoreSelector.h"
#import "StoreDAO.h"
#import "MyReceipts.h"

static UIViewController *newController;
@interface ParentViewController ()
@property (strong, nonatomic) WnPConstants *wnpCont;
@property (strong, nonatomic) StoreDAO *storeDao;
@property(nonatomic) BOOL orientationChanged;

@end

@implementation ParentViewController

- (void)viewDidLoad {
    self.storeDao = [[StoreDAO alloc]init];
    [super viewDidLoad];
    self.orientationChanged=FALSE;
    NSLog(@"%s%@","current view ",viewName);
    self.wnpCont =[[WnPConstants alloc] init];
    // self.cotView = [[UIView alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeStore:) name:@"ChangeStore" object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   // [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];

   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
#pragma mark - Navigation

/*// In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 UIStoryboard *stryBrd = [UIStoryboard storyboardWi;
 thName:@"HomeScreen" bundle:nil];
 UIViewController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"HomeScreen"];
 if(viewCtrl != nil){
 viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
 viewCtrl = segue.destinationViewController;
 }
 }*/

- (void)loadViewData:(id)sender {
    self.view.backgroundColor=[UIColor whiteColor];
    if(newController != nil){
        newController.view.clearsContextBeforeDrawing=TRUE;
    }
    
    if ([sender isEqualToString:@"Name"]) {
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"WnPUserProfile" bundle:nil];
        HomeViewController *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"WnPUserProfile"];
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.cotView.bounds ;
        [self.cotView setClearsContextBeforeDrawing:TRUE];
        [self.cotView addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    }else if ([sender isEqualToString:@"Home"]) {
        [self clearPreviousView:newController];
        self.stryBrd = [UIStoryboard storyboardWithName:@"WnPHomeScreen" bundle:nil];
        HomeViewController *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"WnPHomeScreen"];
        viewCtrl.resetPwd =self.resetPwd;
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.cotView.bounds ;
        [self.cotView setClearsContextBeforeDrawing:TRUE];
        [self.cotView addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    }else if ([sender isEqualToString:@"Scan"]) {
        
        if([self.wnpCont getSelectedStoreId].intValue > 0){
            [self clearPreviousView:newController];
            [self.cotView willMoveToSuperview:nil];
            self.stryBrd = [UIStoryboard storyboardWithName:@"CartScreen" bundle:nil];
            CartScreenController *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"CartScreen"];
            viewCtrl.loadScanpopup=TRUE;
            [self addChildViewController:viewCtrl];
            viewCtrl.view.frame = self.cotView.bounds ;
            [self.cotView addSubview:viewCtrl.view];
            [viewCtrl didMoveToParentViewController:self];
            newController = viewCtrl;
        }else{
            [self showStoreSelectionPopup:TRUE];
        }
        
    } else if ([sender isEqualToString:@"Cart"]) {
        
        [self clearPreviousView:newController];
        [self.cotView willMoveToSuperview:nil];
        self.stryBrd = [UIStoryboard storyboardWithName:@"CartScreen" bundle:nil];
        CartScreenController *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"CartScreen"];
        viewCtrl.loadScanpopup=false;
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.cotView.bounds ;
        [self.cotView addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
        
    }else if ([sender isEqualToString:@"Change store"]) {
        [self showStoreSelectionPopup:FALSE];
    }else if ([sender isEqualToString:@"Checkout"]) {
       
        NSMutableArray *prodcutArray =[self.wnpCont getItemsFromArray];
        if(prodcutArray.count == 0){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No items added yet" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }else{
            if(self.totalAmount.doubleValue <=0){
                [self calculateTotal];
            }
            
            [self clearPreviousView:newController];
            [self.cotView willMoveToSuperview:nil];
            self.stryBrd = [UIStoryboard storyboardWithName:@"PaymentOption" bundle:nil];
            PaymentGateway *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"PaymentOption"];
            viewCtrl.totalAmount = self.totalAmount;
            [self addChildViewController:viewCtrl];
            viewCtrl.view.frame = self.cotView.bounds ;
            [self.cotView addSubview:viewCtrl.view];
            [viewCtrl didMoveToParentViewController:self];
            newController = viewCtrl;
        }
    }else if ([sender isEqualToString:@"PayStatus"]) {
        [self clearPreviousView:newController];
        [self.cotView willMoveToSuperview:nil];
        self.stryBrd = [UIStoryboard storyboardWithName:@"PaymentStatus" bundle:nil];
        PaymentStatus *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"PaymentStatus"];
        viewCtrl.status = self.status;
        viewCtrl.errorMessage = self.errorMessage;
        viewCtrl.reciept=self.reciept;
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.cotView.bounds ;
        [self.cotView addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
    }else if ([sender isEqualToString:@"Reciept"]) {
        [self clearPreviousView:newController];
        [self.cotView willMoveToSuperview:nil];
        self.stryBrd = [UIStoryboard storyboardWithName:@"Reciept" bundle:nil];
        RecieptController *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"Reciept"];
        viewCtrl.reciept = self.reciept;
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.cotView.bounds ;
        [self.cotView addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    }else if ([sender isEqualToString:@"Wallet"]) {
        [self clearPreviousView:newController];
        [self.cotView willMoveToSuperview:nil];
        self.stryBrd = [UIStoryboard storyboardWithName:@"WalletTab" bundle:nil];
        MyReceipts *viewCtrl=[self.stryBrd instantiateViewControllerWithIdentifier:@"WalletTab"];
        [self addChildViewController:viewCtrl];
        viewCtrl.view.frame = self.cotView.bounds ;
        [self.cotView addSubview:viewCtrl.view];
        [viewCtrl didMoveToParentViewController:self];
        newController = viewCtrl;
    } else if ([sender isEqualToString:@"Logout"]) {
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginScreen" bundle:nil];
        [self.wnpCont setUserId:[NSNumber numberWithInt:-1]];
        [self.wnpCont setUserLatLong:0 Longitude:0];
        [self.wnpCont setUserModel:nil];
        [self.wnpCont setUserName:@""];
        [self.wnpCont setSelectedStoreId:[NSNumber numberWithInt:-1]];
        [self.wnpCont setCurrencySymbol:@""];
        [self.wnpCont setCurrencyCode:@""];
        [self.wnpCont clearItemsArray];
        UIViewController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginScreen"];
        if(viewCtrl != nil){
            viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:viewCtrl animated:YES completion:nil];
        }
    }
    
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
            [self.wnpCont setSelectedStoreId:strMdl.storeId];
            [self.wnpCont setCurrencyCode:strMdl.currencyCode];
            [self.wnpCont setCurrencySymbol:strMdl.currencySymbol];
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
    NSLog(@"%@",[self.wnpCont getSelectedStoreId].stringValue);
    [self loadViewData:viewName];
    
}

-(void)calculateTotal{
    NSMutableArray *prodcutArray =[self.wnpCont getItemsFromArray];
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
- (void) clearPreviousView:(UIViewController * ) newController{
    if(newController !=nil){
        newController.view.clearsContextBeforeDrawing=TRUE;
        for(UIView *view in newController.view.subviews)
        {
            [view removeFromSuperview];
        }
    }
}
-(void)changeOrientation:(NSNotification *)note{
 
   // if(self.orientationChanged){
        UIDevice *device = note.object;
        NSLog(@"%s%ld","new orientaion ",(long)device.orientation);
        switch (device.orientation) {
            case UIDeviceOrientationPortrait:
                [self viewDidLoad];
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                [self viewDidLoad];
                break;
            case UIDeviceOrientationLandscapeLeft:
                [self viewDidLoad];
                break;
            case UIDeviceOrientationLandscapeRight:
                [self viewDidLoad];
                break;
            default:
                break;
    }
   // }
}

-(void )setViewName:(NSString *) newView{
    viewName = newView;
}
@end
