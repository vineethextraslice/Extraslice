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
@property (weak, nonatomic) IBOutlet UIView *innerBorder1;
@property (weak, nonatomic) IBOutlet UIView *innerBorder2;
@property (weak, nonatomic) IBOutlet UIImageView *reserveImg;
@property (weak, nonatomic) IBOutlet UILabel *reserveText;
@property (weak, nonatomic) IBOutlet UIImageView *supportImg;
@property (weak, nonatomic) IBOutlet UILabel *supportText;

@end
