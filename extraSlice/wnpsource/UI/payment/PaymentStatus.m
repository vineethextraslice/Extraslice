//
//  PaymentStatus.m
//  WalkNPay
//
//  Created by Irshad on 11/25/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "PaymentStatus.h"
#import "MenuController.h"

@interface PaymentStatus ()

@end

@implementation PaymentStatus

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.status){
        self.statusText.text = @"Transaction successful";
       [self.statusImage setImage:[UIImage imageNamed:@"success.png"]];
        self.statsMessage.text=[NSString stringWithFormat:@"%s%@", "Your transaction id is ", self.reciept.orderId.stringValue];
        self.additonalMessage.text=@"Enjoy your item(s)";
        [self.nextBtbImg setImage:[UIImage imageNamed:@"mail.png"]];
        self.btnText.text=@"Reciept";
                              
    }else{
        self.statusText.text = @"Transaction failed";
        [self.statusImage setImage:[UIImage imageNamed:@"failed.png"]];
        self.statsMessage.text=[NSString stringWithFormat:@"%s%@", "Error :", self.errorMessage];
        self.additonalMessage.hidden=TRUE;
        [self.nextBtbImg setImage:[UIImage imageNamed:@"cart.png"]];
        self.btnText.text=@"Cart";

    }
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showReciept:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.nextBtbImg setUserInteractionEnabled:YES];
    [self.nextBtbImg addGestureRecognizer:singleTap];
}

- (void)didReceiveMemoryWarning {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)showReciept:(id)sender {
    if(self.status){
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
        MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
        if(viewCtrl != nil){
            viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
            [viewCtrl setViewName:@"Reciept"];
            viewCtrl.reciept=self.reciept;
            [self presentViewController:viewCtrl animated:YES completion:nil];
        }
    }else{
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
        MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
        if(viewCtrl != nil){
            viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
            [viewCtrl setViewName:@"Cart"];
            [self presentViewController:viewCtrl animated:YES completion:nil];
        }
        
        
        
    }
}
@end
