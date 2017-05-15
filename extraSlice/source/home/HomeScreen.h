//
//  HomeScreen.h
//  extraSlice
//
//  Created by Administrator on 25/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeScreen : UIViewController
@property (weak, nonatomic) IBOutlet UIView *outerBorder;
@property (strong, nonatomic) IBOutlet UIView *innerBorder1;
@property (strong, nonatomic) IBOutlet UIView *innerBorder2;
@property (strong, nonatomic) IBOutlet UIImageView *reserveImg;
@property (strong, nonatomic) IBOutlet UILabel *reserveText;
@property (strong, nonatomic) IBOutlet UIImageView *supportImg;
@property (strong, nonatomic) IBOutlet UILabel *supportText;
@property (strong, nonatomic) IBOutlet UIView *innerBoarder3;
@property (strong, nonatomic) IBOutlet UIImageView *wnpImage;
@property (strong, nonatomic) IBOutlet UILabel *wnpText;
@property (strong, nonatomic) IBOutlet UIView *innerBoarder32;
@property (strong, nonatomic) IBOutlet UIImageView *wallet;
@property (strong, nonatomic) IBOutlet UILabel *walletTxt;

@end
