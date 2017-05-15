//
//  SupportController.m
//  extraSlice
//
//  Created by Administrator on 28/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "SupportController.h"
#import "SmartSpaceDAO.h"
#import "AdminAccountModel.h"

@interface SupportController ()

@end

@implementation SupportController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*SmartSpaceDAO *smDAO = [[SmartSpaceDAO alloc]init];
    AdminAccountModel *admModel = nil;
    NSMutableAttributedString *urlString = [[NSMutableAttributedString alloc] initWithString:@"Support"];
    [urlString addAttribute:NSLinkAttributeName value:@"http://extraslice.com/support" range:NSMakeRange(0,urlString.length)];
    self.supportUrl.attributedText=urlString;
    UITapGestureRecognizer *showSuppportTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showSuppport:)];
    showSuppportTap.numberOfTapsRequired = 1;
    showSuppportTap.numberOfTouchesRequired = 1;
    [self.supportUrl setUserInteractionEnabled:YES];
    [self.supportUrl addGestureRecognizer:showSuppportTap];

    
    @try{
        admModel = [smDAO getAdminAccount];
        self.phoneNo.text = admModel.contactNo;
        self.emailAddr.text = admModel.contactEmail;
    }@catch (NSException *exception) {
        
    }*/
    
    NSURL *url = [NSURL URLWithString:@"https://docs.google.com/forms/d/e/1FAIpQLSdyWUIshrIGHrexvkZkG_bohxwagIt6biX0ZySBTy9EhyaNSg/viewform?embedded=true"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}
-(void) showSuppport:(UITapGestureRecognizer *) rec{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://extraslice.com/support"]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
