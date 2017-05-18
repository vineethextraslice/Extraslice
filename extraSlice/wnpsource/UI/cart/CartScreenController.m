//
//  CartScreenController.m
//  WalkNPay
//
//  Created by Irshad on 11/24/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "CartScreenController.h"
#import "WnPConstants.h"
#import "WebServiceDAO.h"
#import "PaymentGateway.h"
#import "ProductDAO.h"
#import <AVFoundation/AVFoundation.h>
#import "StoreSelector.h"
#import "ScanPopup.h"
#import "StoreDAO.h"
@interface CartScreenController ()

@property (nonatomic, strong)StoreDAO *storeDao;
@property (nonatomic, strong)NSIndexPath *selectedIndexPath;
@property (nonatomic, strong)NSNumberFormatter *formatter;

//@property (nonatomic, strong)UITapGestureRecognizer *contViewSel;
@end

@implementation CartScreenController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.storeDao = [[StoreDAO alloc]init];
    self.wnpCont =[[WnPConstants alloc] init];
    self.formatter= [[NSNumberFormatter alloc] init];
    [self.formatter setPositiveFormat:@"0.##"];
    self.ScanLyt.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.seperator.backgroundColor= [self.wnpCont getThemeBaseColor];
    self.ScanLyt.layer.borderWidth = 1.0f;
    UIBarButtonItem *bbtnBack = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStyleBordered target:self action:@selector(confirmDelete:)];
    [self.navigationItem setBackBarButtonItem: bbtnBack];
    
    self.PayLyt.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.PayLyt.layer.borderWidth = 1.0f;
    
    UITapGestureRecognizer *scanTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    scanTapRecognizer.numberOfTapsRequired = 1;
    scanTapRecognizer.numberOfTouchesRequired = 1;
    [self.scanImage setUserInteractionEnabled:YES];
    [self.scanImage addGestureRecognizer:scanTapRecognizer];
    
    UITapGestureRecognizer *payTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    payTapRecognizer.numberOfTapsRequired = 1;
    payTapRecognizer.numberOfTouchesRequired = 1;
    [self.payImage setUserInteractionEnabled:YES];
    [self.payImage addGestureRecognizer:payTapRecognizer];
    
    //self.tableView = [[UITableView alloc] initWithFrame:self.tableView.bounds];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.rowHeight=29;
    self.tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    [self.tableLyt addSubview:self.tableView];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width-40;
    
    //  self.headerView.backgroundColor=[UIColor clearColor];
    UIView *testView = [[UIView alloc]initWithFrame:CGRectMake(self.headerView.bounds.origin.x, self.headerView.bounds.origin.y, screenRect.size.width, 30)];
    [testView setBackgroundColor:[self.wnpCont getThemeHeaderColor]];
    [self.headerView addSubview:testView];
    UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(5, 2 , (tableWidth*0.5f), 25)];
    code.text=@"Item";
    UIFont *txtFont = [code.font fontWithSize:wnpFontSize];
    code.font = txtFont;
    code.backgroundColor=[UIColor clearColor];
    [testView addSubview:code];
    
    
    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(((tableWidth*0.5f)+2), 2 , (tableWidth*0.25f), 25)];
    desc.text=@"Qty";
    desc.font = txtFont;
    desc.textAlignment=NSTextAlignmentCenter;
    desc.backgroundColor=[UIColor clearColor];
    [testView addSubview:desc];
    
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(((tableWidth*0.75f)+2), 2 , (tableWidth*0.25f), 25)];
    price.text=@"Amount";
    price.font = txtFont;
    price.textAlignment=NSTextAlignmentCenter;
    price.backgroundColor=[UIColor clearColor];
    [testView addSubview:price];
    
    
    NSMutableArray *productArray = [self.wnpCont getItemsFromArray];
    if([productArray count] ==0){
        self.noItemLabel.hidden=FALSE;
    }else{
        self.noItemLabel.hidden=TRUE;
    }
    self.headerView.backgroundColor=[self.wnpCont getThemeHeaderColor];

    
    
    UITapGestureRecognizer *tableSel=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeFocus:)];
    [tableSel setNumberOfTapsRequired:1];
    [self.tableView addGestureRecognizer:tableSel];
    UITapGestureRecognizer *tableViewSel=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeFocus:)];
    [tableViewSel setNumberOfTapsRequired:1];
    [self.tableLyt addGestureRecognizer:tableViewSel];
    [self calculateTotal];
}


-(void)viewWillAppear:(BOOL)animated{
    if(self.loadScanpopup ){
        if([self.wnpCont getSelectedStoreId].intValue > 0){
            [self showScanPopup];
        }else{
            [self showStoreSelectionPopup];
        }
    }else{
        for(UIView *subViews in [self.view subviews]){
            subViews.alpha=1.0;
            [subViews setUserInteractionEnabled:YES];
        }
    }
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)tapDetected:(UIGestureRecognizer *)recognizer {
    if(recognizer.view.tag ==0){
        if([self.wnpCont getSelectedStoreId].intValue > 0){
            [self showScanPopup];
        }else{
            [self showStoreSelectionPopup];
        }
    }else{
        for(UIView *subViews in [self.view subviews]){
            subViews.alpha=1.0;
        }
        if(self.grosTotal.doubleValue == 0){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No items added yet" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }else{
            UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
            MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
            if(viewCtrl != nil){
                viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                viewCtrl.viewName=@"Checkout";
                viewCtrl.totalAmount = self.grosTotal;
                [self presentViewController:viewCtrl animated:YES completion:nil];
            }
        }
        
    }
}
-(UIModalPresentationStyle) adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSMutableArray *productArray = [self.wnpCont getItemsFromArray];
    if (productArray == nil){
        return 0;
    }else{
        return productArray.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableArray *productArray = [self.wnpCont getItemsFromArray];
    ProductModel *model = [productArray objectAtIndex:indexPath.item];
    NSString *celId =[NSString stringWithFormat:@"%s%ld","Cell",(long)indexPath.item];;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:celId];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
    }else{
        for (UIView *sv in [cell subviews]){
            [sv removeFromSuperview];
        }
    }
    
    UITapGestureRecognizer *cellSel=[[UITapGestureRecognizer alloc] init];
    [cellSel setNumberOfTapsRequired:1];
    [cell addGestureRecognizer:cellSel];
    
    [cell setUserInteractionEnabled:TRUE];
    [tableView setUserInteractionEnabled:YES];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width-40;
    
    UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(5, 2 , (tableWidth*0.5f), 25)];
    UIFont *txtFont = [code.font fontWithSize:wnpFontSize];
    code.font = txtFont;
    [code setUserInteractionEnabled:TRUE];
    [code setEnabled:YES];
    UITapGestureRecognizer *codeSel=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeFocus:)];
    [codeSel setNumberOfTapsRequired:1];
    [code addGestureRecognizer:codeSel];
    code.text=model.name;
    [cell addSubview:code];
    
    UITextField *countLbl = [[UITextField alloc] initWithFrame:CGRectMake(((tableWidth*0.5f)+1), 2 ,((tableWidth*0.25f)-3), 25)];
    
    countLbl.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    countLbl.layer.borderWidth = 1.0f;
    countLbl.text=model.purchasedQuantity.stringValue;
    countLbl.font = txtFont;
    //countLbl.delegate = self;
    countLbl.textAlignment=NSTextAlignmentCenter;
    [countLbl setEnabled:YES];
    [countLbl setKeyboardType:UIKeyboardTypeNumberPad];
    //[countLbl becomeFirstResponder];
    [countLbl addTarget:self action:@selector(editQuantity:) forControlEvents: UIControlEventEditingDidEnd] ;
    [countLbl resignFirstResponder];
    countLbl.tag=indexPath.item;
    [cell addSubview:countLbl];
    
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(((tableWidth*0.75f)), 2 , (tableWidth*0.25f), 25)];
    [price setUserInteractionEnabled:TRUE];
    [price setEnabled:YES];
    
    price.font = txtFont;
    price.text=[self.formatter stringFromNumber:[NSNumber numberWithDouble:(model.price.doubleValue*model.purchasedQuantity.doubleValue)]];
    price.textAlignment=NSTextAlignmentCenter;
    UITapGestureRecognizer *priceSel=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeFocus:)];
    
    [priceSel setNumberOfTapsRequired:1];
    [price addGestureRecognizer:priceSel];
    
    [cell addSubview:price];
    
    
    UIImageView *del = [[UIImageView alloc] initWithFrame:CGRectMake(((tableWidth)+2), 2 , 28, 25)];
    [del setImage:[UIImage imageNamed:@"delete.png"]];
    [del setUserInteractionEnabled:YES];
    UITapGestureRecognizer *delSelected=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(confirmDelete:)];
    [delSelected setNumberOfTapsRequired:1];
    [del addGestureRecognizer:delSelected];
    
    // [del fi];
    [cell addSubview:del];
    
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 29 , tableWidth+40, 1)];
    [seperator setBackgroundColor:[self.wnpCont getThemeHeaderColor]];
    [cell addSubview:seperator];
    //cell.textLabel.text=@"Not items added yet";
    self.tableView.rowHeight=29;
    return cell;
}
- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *) newIndexPath{
    //UITextField* tf = (UITextField *) [tableView viewWithTag:newIndexPath.row+1000];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"ooooooooo");
    [textField resignFirstResponder];
    return NO;
}
-(IBAction) editQuantity:(UITextField *)textView{
    if(textView.text.intValue<=0){
        textView.text=@"1";
    }
    
    NSMutableArray *prodcutArray =[self.wnpCont getItemsFromArray];
    int selectedIndexPath = (int)textView.tag;
    ProductModel *model = [prodcutArray objectAtIndex:selectedIndexPath];
    if([textView isFirstResponder]) {
        //self.noItemLabel.hidden=FALSE;
    }else{
        self.noItemLabel.hidden=TRUE;
        
        
        int availableCount = 0;
        
        ProductDAO *dao = [[ProductDAO alloc]init];
        @try {
            self.noItemLabel.hidden=TRUE;
            ProductModel *modelnew= [[ProductModel alloc]init];
            modelnew = [dao getProductForStoreByCode:model.code StoreId:model.storeId StatusFilter:@"ACTIVE"];
            if(modelnew.availableQty.intValue >0){
                if(modelnew.availableQty.intValue >= textView.text.intValue){
                    
                    availableCount = textView.text.intValue;
                    model.purchasedQuantity =[NSNumber numberWithInt:availableCount];
                }else{
                    availableCount = modelnew.availableQty.intValue;
                    
                    model.purchasedQuantity =[NSNumber numberWithInt:availableCount];
                    textView.text = [NSString stringWithFormat:@"%d", availableCount];
                    /*UIAlertAction *alert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"Sorry we could accomodate only availableCount" preferredStyle:UIAlertControllerStyleAlert];
                    [controller addAction:alert];
                    [self presentViewController:controller animated:YES completion:nil];*/
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%s%d","Sorry, we could accomodate only: ",availableCount] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                    
                }
                [self calculateTotal];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Item not available" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                /*UIAlertAction *alert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"Item not available" preferredStyle:UIAlertControllerStyleAlert];
                [controller addAction:alert];
                [self presentViewController:controller animated:YES completion:nil];*/
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Caught exception %@", exception);
            UIAlertAction *alert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:exception.reason preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:alert];
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
    
    /*[self.tableView beginUpdates];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [textView setEnabled:YES];
    [textView setUserInteractionEnabled:YES];
    NSIndexPath *indexPath =[NSIndexPath indexPathForItem:selectedIndexPath inSection:0];
    [array addObject:indexPath];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    for(UIView *view1 in [cell subviews]){
        [view1 removeFromSuperview];
    }
    
    [cell clearsContextBeforeDrawing];
    [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];*/
    [self.tableView reloadData];
    NSLog(@"end ......................................");
    
}
-(IBAction) changeFocus:(UIGestureRecognizer *)recognizer{
    NSLog(@"hjhsdjfhsjkdfhjksdhfahfdhahfjhsdjhfjhfjhjahfdsfhdsah");
    [self.view endEditing:YES];
    
}

-(IBAction) removeItem:(NSIndexPath *)selectedIndexPath{
    
    
    NSMutableArray *prodcutArray =[self.wnpCont getItemsFromArray];
    ProductModel *model = [prodcutArray objectAtIndex:(selectedIndexPath.row)];
    [self.wnpCont removeItemFromArray:model];
   /* NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array insertObject:selectedIndexPath atIndex:0];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    for(UIView *view1 in [cell subviews]){
        [view1 removeFromSuperview];
    }
    
    [cell clearsContextBeforeDrawing];    [self.tableView beginUpdates];
    
    [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];*/
    [self.tableView reloadData];
    [self calculateTotal];
    
}




- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    
    NSMutableArray *prodcutArray =[self.wnpCont getItemsFromArray];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    ProductModel *model = [prodcutArray objectAtIndex:selectedIndexPath.row];
    if([textView isFirstResponder]) {
        
    }else{
        NSLog(@"22222");
        model.availableQty = [NSNumber numberWithInteger:textView.text.integerValue];
        [self calculateTotal];
    }
    return YES;
}


-(void)calculateTotal{
    
    NSMutableArray *prodcutArray =[self.wnpCont getItemsFromArray];
    //  [prodcutArray ]
    self.subtotal =[NSNumber numberWithDouble:0];
    self.tax = @0;
    self.grosTotal=@0;
    if(prodcutArray.count > 0){
        for(ProductModel* model in prodcutArray){
            self.subtotal = [NSNumber numberWithDouble:(self.subtotal.doubleValue + (model.price.doubleValue * model.purchasedQuantity.doubleValue))];
            self.tax = [NSNumber numberWithDouble:(self.tax.doubleValue + (model.taxPercentage.doubleValue * model.price.doubleValue* model.purchasedQuantity.doubleValue/100) )];
        }
    }
    self.grosTotal =[NSNumber numberWithDouble:(self.subtotal.doubleValue + self.tax.doubleValue)];
    self.subTotalView.text=[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter numberFromString:self.subtotal.stringValue ]];
    self.totalTaxView.text=[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter numberFromString:self.tax.stringValue]];
    self.totalView.text=[NSString stringWithFormat:@"%@%@",[self.wnpCont getCurrencySymbol],[self.formatter numberFromString:self.grosTotal.stringValue]];
    NSLog(@"@%.20f",self.subtotal.floatValue);
}


/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 NSLog(@"hhfljkshgjkdghdlksjfgjlk;djbgsdgjkmjdsl;kbghksd;ldh");
 UITouch *touch = [[event allTouches] anyObject];
 
 if (![[touch view] isKindOfClass:[UITextField class]]) {
 [self.view endEditing:YES];
 }
 [self.parentViewController touchesBegan:touches withEvent:event];
 [self.tableView touchesBegan:touches withEvent:event];
 
 }*/

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}


- (void)checkScannedItem:(NSNotification*)notification{
    
    
    ProductDAO *dao = [[ProductDAO alloc]init];
    @try {
        self.noItemLabel.hidden=TRUE;
        NSDictionary* userInfo = notification.userInfo;
        NSString* barcode = (NSString*)userInfo[@"barcode"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"checkScannedItem" object:nil];
        ProductModel *modelnew= [[ProductModel alloc]init];
        modelnew = [dao getProductForStoreByCode:barcode StoreId:[self.wnpCont getSelectedStoreId]  StatusFilter:@"ACTIVE"];
        if(modelnew.availableQty.intValue >0){
            Boolean found=false;
            int index=0;
            for(ProductModel *model in [self.wnpCont getItemsFromArray]){
                if(model.id.intValue==modelnew.id.intValue){
                    if(model.purchasedQuantity.intValue == model.availableQty.intValue){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%s%d","Sorry, we could accomodate only: ",model.availableQty.intValue] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                        [alert show];
                        modelnew = model;
                    }else{
                        model.purchasedQuantity=[NSNumber numberWithDouble:(model.purchasedQuantity.doubleValue+1)];
                        modelnew = model;
                    }
                    found=true;
                    break;
                }
                index++;
            }
            if(!found){
                modelnew.purchasedQuantity=[NSNumber numberWithDouble:1.0f];
                [self.wnpCont addItemToArray:modelnew];
                NSMutableArray *productArray = [self.wnpCont getItemsFromArray];
                if (productArray != nil){
                    NSMutableArray *s = [[NSMutableArray alloc]init];
                    [s addObject:[NSIndexPath indexPathForItem:productArray.count-1 inSection:0]];
                    /*[self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:s withRowAnimation:(UITableViewRowAnimationFade)];
                    [self.tableView endUpdates];*/
                }
            }else{
                [self calculateTotal];
                
                /*[self.tableView beginUpdates];
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [array addObject:[NSIndexPath indexPathForItem:index inSection:0]];
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
                for(UIView *view1 in [cell subviews]){
                    [view1 removeFromSuperview];
                }
                
                [cell clearsContextBeforeDrawing];
                [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];*/
               
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Item not available" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        self.view.backgroundColor=[UIColor whiteColor];
    }
    @catch (NSException *exception) {
        NSLog(@"Caught exception %@", exception);
        UIAlertAction *alert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:exception.reason preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:alert];
        [self presentViewController:controller animated:YES completion:nil];
    }
    
    [self calculateTotal];
     [self.tableView reloadData];
    /*for(UIView *subViews in [self.view subviews]){
     subViews.alpha=1.0;
     }*/
    
    self.view.backgroundColor=[UIColor whiteColor];
}

- (IBAction)cancelPopup:(id)sender {
    self.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=1.0;
    }
    
    // self.scanpopup.alpha=0.0;
    // self.scanpopup.hidden=TRUE;
}






- (void) showStoreSelectionPopup{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeStore:) name:@"ChangeStoreFromCart" object:nil];
    NSArray *storeArray = [[NSArray alloc]init];
    NSString *error=nil;
    BOOL showPopup=false;
    @try {
        storeArray = [self.storeDao  getAllStoresForDealerByLocation:@1];
        if (storeArray == nil || storeArray.count ==0) {
            error=@"No store found";
            showPopup=true;
        }else if(storeArray.count ==1){
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
        viewController.notifyAfter=TRUE;
        viewController.requestedFrom=@"Cart";
        [self addChildViewController:viewController];
        [self.view addSubview:viewController.view];
        [self.view bringSubviewToFront:viewController.view];
        [viewController.view setUserInteractionEnabled:YES];
        viewController.view.center = self.view.center;
        for(UIView *uisv in [viewController.view subviews]){
            [uisv setUserInteractionEnabled:YES];
        }
        
    }else{
         [self showScanPopup];
    }
}
- (void) confirmDelete:(UIGestureRecognizer *)recognizer{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Do you want to delete?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    self.selectedIndexPath = [self.tableView indexPathForRowAtPoint:[recognizer locationInView:self.tableView]];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            //do something?
            break;
        case 1: //"Yes" pressed
            [self removeItem:self.selectedIndexPath];
            break;
    }
}

- (void) showScanPopup{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkScannedItem:)
                                                 name:@"checkScannedItem" object:nil];
    
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
    }
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"ScanPopup" bundle:nil];
    ScanPopup *viewController=[stryBrd instantiateViewControllerWithIdentifier:@"ScanPopup"];
    // UIView *dashboardView = viewController.view;
    // [dashboardView setFrame:CGRectMake(self.view.bounds.origin.x-90,self.view.bounds.origin.y-100,180,200)];
    viewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [self.view bringSubviewToFront:viewController.view];
    [viewController.view setUserInteractionEnabled:YES];

    for(UIView *uisv in [viewController.view subviews]){
        [uisv setUserInteractionEnabled:YES];
    }
}




-(IBAction) changeStore:(UIGestureRecognizer *)recognizer{
    self.view.backgroundColor=[UIColor whiteColor];
    NSLog(@"%@",[self.wnpCont getSelectedStoreId].stringValue);
    [self showScanPopup];
    
}


@end
