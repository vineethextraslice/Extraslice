//
//  ForumScreen.m
//  extraSlice
//
//  Created by Administrator on 27/09/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "ForumScreen.h"
#import "UserModel.h"
#import "Utilities.h"
@interface ForumScreen ()

@end

@implementation ForumScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    Utilities *utils = [[Utilities alloc]init];
    UserModel *model = [utils getLoggedinUser];
    NSString *userName = model.email;
    NSRange range = [userName rangeOfString:@"." options:NSBackwardsSearch];
    userName = [userName substringToIndex:range.location];
    userName = [userName stringByReplacingOccurrencesOfString:@"@" withString:@"_"];
    
    
    NSURL *url = [NSURL URLWithString: @"http://extraslicedev04.cloudapp.net/phpbb/autologin.php"];
    NSString *body = [NSString stringWithFormat: @"username=%@&password=%@", userName,[utils decode:model.password]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [self.forumWebview loadRequest: request];
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
