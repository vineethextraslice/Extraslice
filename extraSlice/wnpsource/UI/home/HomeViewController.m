//
//  HomeViewController.m
//  WalkNPay
//
//  Created by Irshad on 11/17/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "HomeViewController.h"
#import "WnPConstants.h"
#import "MenuController.h"
#import "StoreSelector.h"
#import "StoreDAO.h"
#import "StoreModel.h"
@interface HomeViewController ()
@property (strong, nonatomic) NSMutableArray *navItems;
@property (strong, nonatomic) NSMutableArray *navItemsImg;
@property (strong, nonatomic) NSMutableArray *navItemsFunctions;
@property(strong,nonatomic) StoreDAO *storeDao;
@property(strong,nonatomic) WnPConstants *wnpCont;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self performSelectorInBackground:@selector(backgroundMethod)
                           withObject:@"test"];
    
}

-(void)backgroundMethod
{
    self.storeDao = [[StoreDAO alloc]init];
    self.wnpCont= [[WnPConstants alloc] init];
    [self.wnpCont setColor:0];
    self.containerView.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.containerView.layer.borderWidth = 1.0f;
    
    self.navItems = [[NSMutableArray alloc]init];
    
    [self.navItems addObject:@"Scan"];
    [self.navItems addObject:@"Cart"];
    [self.navItems addObject:@"Checkout"];
    
    self.navItemsImg= [[NSMutableArray alloc]init];
    
    [self.navItemsImg addObject:@"qr_scanner.png"];
    [self.navItemsImg addObject:@"cart.png"];
    [self.navItemsImg addObject:@"checkout.png"];
    
    
    self.navItemsFunctions= [[NSMutableArray alloc]init];
    
    [self.navItemsFunctions addObject:@"qr_scanner.png"];
    [self.navItemsFunctions addObject:@"cart.png"];
    [self.navItemsFunctions addObject:@"checkout.png"];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat rowHeight = (screenRect.size.height-115)/3;
    CGFloat rowWidth = screenRect.size.width-30;
    
    self.inner11= [[UIView alloc] initWithFrame:CGRectMake(10, 10, rowWidth, rowHeight)];
    self.inner20= [[UIView alloc] initWithFrame:CGRectMake(10, (20+rowHeight), rowWidth, rowHeight)];
    self.inner21= [[UIView alloc] initWithFrame:CGRectMake(10, (20+rowHeight), rowWidth/2, rowHeight)];
    self.inner22= [[UIView alloc] initWithFrame:CGRectMake(9+rowWidth/2, (20+rowHeight), rowWidth/2, rowHeight)];
    self.inner31= [[UIView alloc] initWithFrame:CGRectMake(10, (30+2*rowHeight), rowWidth, rowHeight)];
    
    UIView *view1 =nil;
    UIView *view20 =nil;
    UIView *view21 =nil;
    UIView *view22 =nil;
    UIView *view31 =nil;
    
    if(rowHeight <140){
        view1= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-100)/2, rowWidth, 100)];
        view20= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-100)/2, rowWidth, 100)];
        view21= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-100)/2, rowWidth/2, 100)];
        view22= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-100)/2, rowWidth/2, 100)];
        view31= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-100)/2, rowWidth, 100)];
        
        
        
        self.storeTxt = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, rowWidth, 30)];
        self.scanTxt = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, rowWidth/2, 30)];
        self.cart1Txt = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, rowWidth/2, 30)];
        self.cart2Txt = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, rowWidth, 30)];
        self.checkoutTxt = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, rowWidth, 30)];
        
        
        self.store = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/2)-30, 0, 60, 60)];
        self.scan = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/4)-30, 0, 60, 60)];
        self.cart1 = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/4)-30, 0, 60, 60)];
        self.cart2 = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/2)-30, 0, 60, 60)];
        self.checkout = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/2)-30, 0, 60, 60)];
        
        
    }else{
        view1= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-120)/2, rowWidth, 120)];
        view20= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-120)/2, rowWidth/2, 120)];
        view21= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-120)/2, rowWidth/2, 120)];
        view22= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-120)/2, rowWidth/2, 120)];
        view31= [[UIView alloc] initWithFrame:CGRectMake(0, (rowHeight-120)/2, rowWidth, 120)];
        
        
        self.storeTxt = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, rowWidth, 30)];
        self.scanTxt = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, rowWidth/2, 30)];
        self.cart1Txt = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, rowWidth/2, 30)];
        self.cart2Txt = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, rowWidth, 30)];
        self.checkoutTxt = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, rowWidth, 30)];
        
        /*self.reserveText = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, rowWidth, 30)];
         self.supportText = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, rowWidth, 30)];
         self.wnpText = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, rowWidth, 30)];
         
         self.wnpImage = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/2)-40, 0, 80, 80)];
         self.supportImg = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/2)-40, 0, 80, 80)];
         self.reserveImg = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/2)-40, 0, 80, 80)];*/
        self.store = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/2)-40, 0, 80, 80)];
        self.scan = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/4)-40, 0, 80, 80)];
        self.cart1 = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/4)-40, 0, 80, 80)];
        self.cart2 = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/2)-40, 0, 80, 80)];
        self.checkout = [[UIImageView alloc] initWithFrame:CGRectMake((rowWidth/2)-40, 0, 80, 80)];
        
    }
    [self showStoreSelectionPopup:FALSE];
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.scan setImage:[UIImage imageNamed:@"qr_scanner.png"]];
    [self.cart1 setImage:[UIImage imageNamed:@"cart.png"]];
    [self.cart2 setImage:[UIImage imageNamed:@"cart.png"]];
    [self.checkout setImage:[UIImage imageNamed:@"checkout.png"]];
    
    self.store.tag=0;
    self.scan.tag=1;
    self.cart1.tag=2;
    self.cart2.tag=2;
    self.checkout.tag=3;
    
    
    
    
    self.scanTxt.textAlignment=NSTextAlignmentCenter;
    self.scanTxt.text=@"Scan";
    [self.scanTxt setFont:[UIFont boldSystemFontOfSize:17.0]];
    [view21 addSubview:self.scanTxt];
    
    self.cart1Txt.textAlignment=NSTextAlignmentCenter;
    self.cart1Txt.text=@"Cart";
    [self.cart1Txt setFont:[UIFont boldSystemFontOfSize:17.0]];
    [view22 addSubview:self.cart1Txt];
    
    self.cart2Txt.textAlignment=NSTextAlignmentCenter;
    self.cart2Txt.text=@"Cart";
    [self.cart2Txt setFont:[UIFont boldSystemFontOfSize:17.0]];
    [view20 addSubview:self.cart2Txt];
    
    
    self.checkoutTxt.textAlignment=NSTextAlignmentCenter;
    self.checkoutTxt.text=@"Checkout";
    [self.checkoutTxt setFont:[UIFont boldSystemFontOfSize:17.0]];
    [view31 addSubview:self.checkoutTxt];
    
    
    
    
    
    [view1 addSubview:self.store];
    [view20 addSubview:self.cart2];
    [view21 addSubview:self.scan];
    [view22 addSubview:self.cart1];
    [view31 addSubview:self.checkout];
    
    
    
    [self.inner11 addSubview:view1];
    [self.inner20 addSubview:view20];
    [self.inner21 addSubview:view21];
    [self.inner22 addSubview:view22];
    [self.inner31 addSubview:view31];
    
    
    if([self.wnpCont getNumberOfStores].intValue> 1){
        [self.store setImage:[UIImage imageNamed:@"store_home.png"]];
        self.store.tag=0;
        self.storeTxt.textAlignment=NSTextAlignmentCenter;
        self.storeTxt.text=@"Change store";
        [self.storeTxt setFont:[UIFont boldSystemFontOfSize:17.0]];
        [view1 addSubview:self.storeTxt];
        [self.containerView addSubview:self.inner21];
        [self.containerView addSubview:self.inner22];
    }else{
        [self.store setImage:[UIImage imageNamed:@"qr_scanner.png"]];
        self.store.tag=1;
        self.storeTxt.textAlignment=NSTextAlignmentCenter;
        self.storeTxt.text=@"Scan";
        [self.storeTxt setFont:[UIFont boldSystemFontOfSize:17.0]];
        [view1 addSubview:self.storeTxt];
        [self.containerView addSubview:self.inner20];
    }
    
    
    [self.containerView addSubview:self.inner11];
    [self.containerView addSubview:self.inner31];
    
    
    self.inner11.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.inner11.layer.borderWidth = 1.0f;
    self.inner20.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.inner20.layer.borderWidth = 1.0f;
    self.inner21.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.inner21.layer.borderWidth = 1.0f;
    self.inner22.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.inner22.layer.borderWidth = 1.0f;
    self.inner31.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.inner31.layer.borderWidth = 1.0f;
    
    });
    
    
    
    
    
    
    UITapGestureRecognizer *singleTap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    singleTap0.numberOfTapsRequired = 1;
    singleTap0.numberOfTouchesRequired = 1;
    [self.store setUserInteractionEnabled:YES];
    [self.store addGestureRecognizer:singleTap0];
    
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    singleTap1.numberOfTapsRequired = 1;
    singleTap1.numberOfTouchesRequired = 1;
    [self.scan setUserInteractionEnabled:YES];
    [self.scan addGestureRecognizer:singleTap1];
    
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    singleTap2.numberOfTapsRequired = 1;
    singleTap2.numberOfTouchesRequired = 1;
    [self.cart1 setUserInteractionEnabled:YES];
    [self.cart1 addGestureRecognizer:singleTap2];
    
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    singleTap3.numberOfTapsRequired = 1;
    singleTap3.numberOfTouchesRequired = 1;
    [self.cart2 setUserInteractionEnabled:YES];
    [self.cart2 addGestureRecognizer:singleTap3];
    
    UITapGestureRecognizer *singleTap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    singleTap4.numberOfTapsRequired = 1;
    singleTap4.numberOfTouchesRequired = 1;
    [self.checkout setUserInteractionEnabled:YES];
    [self.checkout addGestureRecognizer:singleTap4];
    
    UITapGestureRecognizer *singleTap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    singleTap5.numberOfTapsRequired = 1;
    singleTap5.numberOfTouchesRequired = 1;
    
    
    self.resetPwdPopup.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.resetPwdPopup.layer.borderWidth = 1.0f;
    
    self.resetNewPwd.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.resetNewPwd.layer.borderWidth = 1.0f;
    self.resetConfPwd.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.resetConfPwd.layer.borderWidth = 1.0f;
    self.resetPwdSubmit.layer.backgroundColor = [self.wnpCont getThemeBaseColor].CGColor;
 
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(self.resetPwd){
        self.resetPwdPopup.hidden=FALSE;
        
        
        for(UIView *subViews in [self.containerView subviews]){
            subViews.alpha=0.1;
            [subViews setUserInteractionEnabled:false];
        }
        
        [self.resetNewPwd becomeFirstResponder];
        [[UITextField appearance] setTintColor:[UIColor blackColor]];
        self.resetPwdPopup.hidden=FALSE;
        self.resetPwdPopup.alpha=1.0;
        
    }else{
        for(UIView *subViews in [self.containerView subviews]){
            subViews.alpha=1.0;
            [subViews setUserInteractionEnabled:true];
        }
        self.resetPwdPopup.hidden=TRUE;
        self.resetPwdPopup.alpha=0;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tapDetected:(UIGestureRecognizer *)recognizer {
    UIButton *btn = (UIButton *)recognizer.view;

    int tag = (int)btn.tag;
    switch (tag) {
        case 0:
        {
            [self showStoreSelectionPopup:TRUE];
            break;
        }
        case 1:
        {
            UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
            MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
            if(viewCtrl != nil){
                viewCtrl.loadScanpopup =NO;
                viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                viewCtrl.viewName=@"Scan";
                [self presentViewController:viewCtrl animated:YES completion:nil];
                break;
            }
        }
        case 2:
        {
            UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
            MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
            if(viewCtrl != nil){
                viewCtrl.loadScanpopup =NO;
                viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                viewCtrl.viewName=@"Cart";
                [self presentViewController:viewCtrl animated:YES completion:nil];
                break;
            }
        }
        case 3:
        {
            NSMutableArray *prodcutArray =[self.wnpCont getItemsFromArray];
            if(prodcutArray.count == 0){
                UIAlertAction *alert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"No items added yet" preferredStyle:UIAlertControllerStyleAlert];
                [controller addAction:alert];
                [self presentViewController:controller animated:YES completion:nil];
            }else{
                [self calculateTotal];
                UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
                MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
                viewCtrl.totalAmount = self.totalAmount;
                if(viewCtrl != nil){
                    viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                    viewCtrl.viewName=@"Checkout";
                    [self presentViewController:viewCtrl animated:YES completion:nil];
                    
                }
            }
            break;
        }
        

        case 4:
        {
            UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
            MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
            if(viewCtrl != nil){
                viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                viewCtrl.viewName=@"Wallet";
                [self presentViewController:viewCtrl animated:YES completion:nil];
                break;
            }
            break;
        }

        default:
            break;
    }
}

- (void) showStoreSelectionPopup:(BOOL ) forcePopup{
    NSArray *storeArray = [[NSArray alloc]init];
    NSString *error=nil;
    BOOL showPopup=false;
    @try {
        storeArray = [self.storeDao  getAllStoresForDealerByLocation:@1];
        [self.wnpCont setNumberOfStores:[NSNumber numberWithInt:(int)(storeArray.count)]];
        if (storeArray == nil || storeArray.count ==0) {
            error=@"No store found";
            showPopup=false;
            if(forcePopup){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No stores found" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            
                [alert show];
            }
        }else if(storeArray.count ==1){
            StoreModel *strMdl = [storeArray objectAtIndex:0];
            [self.wnpCont setSelectedStoreId:strMdl.storeId];
            [self.wnpCont setCurrencyCode:strMdl.currencyCode];
            [self.wnpCont setCurrencySymbol:strMdl.currencySymbol];
            showPopup=false;
        }else{
            if(forcePopup){
                showPopup=true;
            }
        }
    }
    @catch (NSException *exception) {
        if(forcePopup){
            showPopup=true;
            error=exception.description;
        }
        
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
        [self addChildViewController:viewController];
        [self.view addSubview:viewController.view];
        [self.view bringSubviewToFront:viewController.view];
        [viewController.view setUserInteractionEnabled:YES];
        viewController.view.center = self.view.center;
        for(UIView *uisv in [viewController.view subviews]){
            [uisv setUserInteractionEnabled:YES];
        }
    }else{
        
    }
}

-(void)calculateTotal{
    NSMutableArray *prodcutArray =[self.wnpCont getItemsFromArray];
    //  [prodcutArray ]
    NSNumber *subtotal =@0;
    NSNumber *tax = @0;
    self.totalAmount=@0;
    if(prodcutArray.count > 0){
        for(ProductModel* model in prodcutArray){
            subtotal = [NSNumber numberWithDouble:(subtotal.doubleValue + (model.price.doubleValue * model.purchasedQuantity.doubleValue))];
            tax = [NSNumber numberWithDouble:(tax.doubleValue + (model.taxPercentage.doubleValue * model.price.doubleValue* model.purchasedQuantity.integerValue/100) )];
        }
    }
    self.totalAmount =[NSNumber numberWithDouble:(subtotal.doubleValue + tax.doubleValue)];
    
}

@end
