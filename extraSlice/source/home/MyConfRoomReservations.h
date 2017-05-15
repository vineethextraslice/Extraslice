//
//  MyConfRoomReservations.h
//  extraSlice
//
//  Created by Administrator on 28/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StripePaymentViewController;

@protocol StripePaymentViewControllerDelegate<NSObject>

- (void)stripePaymentViewController:(StripePaymentViewController *)controller didFinish:(NSError *)error;

@end
@interface MyConfRoomReservations : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *dayTypeHeader;
@property (weak, nonatomic) IBOutlet UILabel *dayDescription;
@property(strong,nonatomic)NSMutableArray *currSchedules;
@property (weak, nonatomic) IBOutlet UIImageView *nextImage;
@property (weak, nonatomic) IBOutlet UIImageView *previousImage;
@property(strong,nonatomic) NSDate *selectedDate;
@end
