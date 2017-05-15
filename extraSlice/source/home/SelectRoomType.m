//
//  SelectRoomType.m
//  extraSlice
//
//  Created by Administrator on 02/03/17.
//  Copyright © 2017 Extraslice Inc. All rights reserved.
//

#import "SelectRoomType.h"
#import "MenuController.h"

@interface SelectRoomType ()

@end

@implementation SelectRoomType

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *conftap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(loadReservationPage:)];
    conftap.numberOfTapsRequired = 1;
    conftap.numberOfTouchesRequired = 1;
    [self.confRoom setUserInteractionEnabled:YES];
    [self.confRoom addGestureRecognizer:conftap];
    
    
    UITapGestureRecognizer *trainTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(loadReservationPage:)];
    trainTap.numberOfTapsRequired = 1;
    trainTap.numberOfTouchesRequired = 1;
    [self.trainingRoom setUserInteractionEnabled:YES];
    [self.trainingRoom addGestureRecognizer:trainTap];
    
    
    UITapGestureRecognizer *eventTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(loadReservationPage:)];
    eventTap.numberOfTapsRequired = 1;
    eventTap.numberOfTouchesRequired = 1;
    [self.eventRoom setUserInteractionEnabled:YES];
    [self.eventRoom addGestureRecognizer:eventTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)loadReservationPage:(UITapGestureRecognizer *) rec{
    int tag = rec.view.tag;
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
    MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
    if(viewCtrl != nil){
        if(tag == 3){
            viewCtrl.selectedRoomType=@"Event Room Usage";
        }else if(tag == 2){
            viewCtrl.selectedRoomType=@"Training Room Usage";
        }else{
            viewCtrl.selectedRoomType=@"Conference room";
        }
        
        
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        viewCtrl.viewName=@"ReserveNow";
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }
    
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
