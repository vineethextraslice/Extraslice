//
//  CartScreenController.h
//  WalkNPay
//
//  Created by Irshad on 11/24/15.
//  Copyright © 2015 extraslice. All rights reserved.
//


#import "MenuController.h"
#import "WnPConstants.h"


@interface CartScreenController :UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *ScanLyt;
@property (weak, nonatomic) IBOutlet UIView *PayLyt;
@property (weak, nonatomic) IBOutlet UIImageView *scanImage;
@property (weak, nonatomic) IBOutlet UIImageView *payImage;
@property (weak, nonatomic) IBOutlet UILabel *lbl1;
@property (weak, nonatomic) IBOutlet UIView *tableLyt;
- (IBAction)cancelPopup:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *noItemLabel;
@property (weak, nonatomic) IBOutlet UIView *scanpopup;
@property (weak, nonatomic) IBOutlet UILabel *totalTaxView;
@property (weak, nonatomic) IBOutlet UILabel *totalView;

@property (weak, nonatomic) IBOutlet UILabel *subTotalView;
@property (strong, nonatomic) NSNumber *subtotal;
@property (strong, nonatomic) NSNumber *tax;
@property (strong, nonatomic) NSNumber *grosTotal;
@property (nonatomic) BOOL loadScanpopup;
-(void)calculateTotal;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property(strong,nonatomic) WnPConstants *wnpCont;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIView *seperator;
@property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;

@end
