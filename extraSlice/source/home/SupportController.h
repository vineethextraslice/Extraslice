//
//  SupportController.h
//  extraSlice
//
//  Created by Administrator on 28/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SupportController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *phoneNo;
@property (weak, nonatomic) IBOutlet UILabel *emailAddr;
@property (weak, nonatomic) IBOutlet UILabel *supportUrl;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
