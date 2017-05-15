//
//  StoreSelector.h
//  WalkNPay
//
//  Created by Administrator on 12/01/16.
//  Copyright © 2016 Extraslice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreSelector : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *storeSelector;

//@property (weak, nonatomic) IBOutlet UIView *contView;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
- (IBAction)selectStore:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
- (IBAction)cancelPopup:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) NSString *errorText;
@property(strong,nonatomic) NSArray *storeArray;
@property(nonatomic) BOOL notifyAfter;
@property(strong,nonatomic) NSString *requestedFrom;

@end
