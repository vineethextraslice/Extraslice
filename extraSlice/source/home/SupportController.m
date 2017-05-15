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
