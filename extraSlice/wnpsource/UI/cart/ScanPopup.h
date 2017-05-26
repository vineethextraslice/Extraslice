//
//  ScanPopup.h
//  WalkNPay
//
//  Created by Administrator on 20/01/16.
//  Copyright © 2016 Extraslice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanPopup : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *previewArea;
@property (weak, nonatomic) IBOutlet UITextField *manualBarcode;
@property (weak, nonatomic) IBOutlet UIButton *manualSubmitBtn;
- (IBAction)submitManualBarcode:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *closeBtn;

@end
