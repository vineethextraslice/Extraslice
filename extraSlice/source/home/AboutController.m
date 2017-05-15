//
//  AboutController.m
//  extraSlice
//
//  Created by Administrator on 28/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "AboutController.h"
#import "SmartSpaceDAO.h"
#import "AdminAccountModel.h"
#import "ESliceConstants.h"
@interface AboutController ()
@property(strong,nonatomic) ESliceConstants *wnpConst;
@property(strong,nonatomic) AdminAccountModel *admModel;
@end

@implementation AboutController

- (void)viewDidLoad {
    [super viewDidLoad];
    SmartSpaceDAO *smDAO = [[SmartSpaceDAO alloc]init];

    @try{
        self.admModel = [smDAO getAdminAccount];
        self.aboutText.text = self.admModel.about;
        self.aboutText.numberOfLines=-1;
        self.webserviceVersion.text=self.admModel.webserviceVersion;
    }@catch (NSException *exception) {
        
    }
    self.wnpConst = [[ESliceConstants alloc]init];
    UITapGestureRecognizer *showPPTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showPP:)];
    showPPTap.numberOfTapsRequired = 1;
    showPPTap.numberOfTouchesRequired = 1;
    [self.privacyPolicy setUserInteractionEnabled:YES];
    [self.privacyPolicy addGestureRecognizer:showPPTap];
    
    
    NSMutableAttributedString *urlString = [[NSMutableAttributedString alloc] initWithString:@"Website"];
    [urlString addAttribute:NSLinkAttributeName value:@"http://extraslice.com" range:NSMakeRange(0,urlString.length)];
    self.webSite.attributedText=urlString;
    UITapGestureRecognizer *showWebSiteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showWebSite:)];
    showWebSiteTap.numberOfTapsRequired = 1;
    showWebSiteTap.numberOfTouchesRequired = 1;
    [self.webSite setUserInteractionEnabled:YES];
    [self.webSite addGestureRecognizer:showWebSiteTap];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.appVersion.text=version;
}
-(void) showWebSite:(UITapGestureRecognizer *) rec{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://extraslice.com"]];
}
- (void)showPP:(UITapGestureRecognizer *) rec{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 65, screenRect.size.width, screenRect.size.height)];
    
    webView.tag=55;
    NSURL *url = [NSURL URLWithString:self.admModel.privacyPolicyUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    [self.view addSubview:webView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(closeTC:)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Close" forState:UIControlStateNormal];
    button.frame = CGRectMake(((screenRect.size.width/2)-55), screenRect.size.height-105, 110, 30);
    [button addTarget:self action:@selector(closeTC:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor=[self.wnpConst getThemeBaseColor];
    button.tag=65;
    [self.view addSubview:button];
    [self.view bringSubviewToFront:button];
    
}

- (void)closeTC:(UITapGestureRecognizer *) rec{
    
    [[self.view viewWithTag:55] removeFromSuperview];
    [[self.view viewWithTag:65] removeFromSuperview];
}
- (void)hideKeyBoard:(UITapGestureRecognizer *) rec{
    [self.view endEditing:YES];
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
