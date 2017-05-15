//
//  MenuController.h
//  extraSlice
//
//  Created by Administrator on 27/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionModel.h"
#import "StoreModel.h"
static  NSString *viewName;
@interface MenuController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) UIStoryboard *stryBrd;
@property(nonatomic) BOOL status;
@property(nonatomic) BOOL resetPwd;
@property (weak, nonatomic) IBOutlet UIView *mainHeader;


@property(weak,nonatomic) NSString *errorMessage;
@property (weak, nonatomic) IBOutlet UIView *containerFrame;
@property (weak, nonatomic) IBOutlet UIImageView *menuIcon;
@property(strong,nonatomic)NSMutableArray *currSchedules;
@property(nonatomic) Boolean *paymentStatus;
@property (weak,nonatomic)NSNumber *totalAmount;
@property (weak,nonatomic)NSNumber *payableAmount;
@property(nonatomic) BOOL loadScanpopup;

@property(strong,nonatomic) StoreModel *storeModel;
@property(weak,nonatomic) TransactionModel *reciept;

-(void )setViewName:(NSString *) newView;
- (void)loadViewData:(id)sender;
@property(strong,nonatomic) NSDate *selectedDate;
@property(strong,nonatomic) NSString *selectedDayType;
@end
