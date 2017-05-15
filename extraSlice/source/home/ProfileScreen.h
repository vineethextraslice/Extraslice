//
//  ProfileScreen.h
//  extraSlice
//
//  Created by Administrator on 06/09/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileScreen : UIViewController
@property (weak, nonatomic) IBOutlet UIView *orgLyt;
@property (weak, nonatomic) IBOutlet UITableView *orgDropdown;
@property (weak, nonatomic) IBOutlet UILabel *orgName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orgLytHeight;
@property (weak, nonatomic) IBOutlet UIView *orgHeader;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *planScrViewHt;
@property (weak, nonatomic) IBOutlet UIView *plnBenHeader;
@property (weak, nonatomic) IBOutlet UIImageView *plnBenfExp;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *plnBenfDetlHt;

@property (weak, nonatomic) IBOutlet UILabel *plnBenfHeader;
@property (weak, nonatomic) IBOutlet UIScrollView *plnBenfDetl;





@property (weak, nonatomic) IBOutlet UILabel *header;

@property (weak, nonatomic) IBOutlet UIView *errorLayout;
@property (weak, nonatomic) IBOutlet UILabel *errorText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorLytHeight;

@property (weak, nonatomic) IBOutlet UILabel *userHeader;
@property (weak, nonatomic) IBOutlet UIView *userLyt;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userScrViewHt;
@property (weak, nonatomic) IBOutlet UIScrollView *userScrView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userLytHeight;
@property (weak, nonatomic) IBOutlet UIView *subscriptionHeaderLyt;
@property (weak, nonatomic) IBOutlet UIView *userHeaderLyt;
@property (weak, nonatomic) IBOutlet UIScrollView *planScrView;
@property (nonatomic) BOOL expandPln;
@property (nonatomic) BOOL expandPlnBen;
@property (nonatomic) BOOL expandUsr;


@property (weak, nonatomic) IBOutlet UIImageView *expandSubscView;
@property (weak, nonatomic) IBOutlet UIImageView *expandUserView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscrHeaderHt;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *plnHeaderHt;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userHeaderHt;




@end
