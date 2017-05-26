//
//  ScanPopup.m
//  WalkNPay
//
//  Created by Administrator on 20/01/16.
//  Copyright © 2016 Extraslice. All rights reserved.
//

#import "ScanPopup.h"
#import <AVFoundation/AVFoundation.h>
#import "WnPConstants.h"

@interface ScanPopup ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureLayer;
@property (strong, nonatomic) WnPConstants *wnpCont;
@end

@implementation ScanPopup

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wnpCont =[[WnPConstants alloc] init];
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
             NSLog(@"Permission asked");
            // Will get here on both iOS 7 & 8 even though camera permissions weren't required
            // until iOS 8. So for iOS 7 permission will always be granted.
            if (granted) {
                 NSLog(@"Permission granted");
                // Permission has been granted. Use dispatch_async for any UI updating
                // code because this block may be executed in a thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self setupScanningSession];
                });
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                NSLog(@"Permission not granted");
            }
        }];
    } else {
         NSLog(@"Already have permission ");
        [self setupScanningSession];
    }
    
    //self.view.layer.borderColor = [UIColor blackColor].CGColor;
   // self.view.layer.borderWidth = 1.0f;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    //[self.view setBounds:CGRectMake((screenSize.width/2)-302,0, 302,340)];
     
    [self.previewArea bringSubviewToFront:self.closeBtn];
    self.closeBtn.userInteractionEnabled=true;
    UITapGestureRecognizer *close=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelPopup)];
    [close setNumberOfTapsRequired:1];
    [self.closeBtn addGestureRecognizer:close];
    self.manualSubmitBtn.backgroundColor=[UIColor grayColor];
    self.manualSubmitBtn.enabled=false;
    [self.manualBarcode addTarget:self action:@selector(enableButton) forControlEvents: UIControlEventAllEditingEvents] ;
    self.manualBarcode.delegate = self;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 180; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Local method to setup camera scanning session.
- (void)setupScanningSession {
    
    // Initalising hte Capture session before doing any video capture/scanning.
    self.captureSession = [[AVCaptureSession alloc] init];
    
    NSError *error;
    // Set camera capture device to default and the media type to video.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // Set video capture input: If there a problem initialising the camera, it will give am error.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"Error Getting Camera Input");
        return;
    }
    // Adding input souce for capture session. i.e., Camera
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // Set output to capture session. Initalising an output object we will use later.
    [self.captureSession addOutput:captureMetadataOutput];
    
    // Create a new queue and set delegate for metadata objects scanned.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("scanQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    // Delegate should implement captureOutput:didOutputMetadataObjects:fromConnection: to get callbacks on detected metadata.
    [captureMetadataOutput setMetadataObjectTypes:[captureMetadataOutput availableMetadataObjectTypes]];
    
    // Layer that will display what the camera is capturing.
    self.captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.captureLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.captureLayer setFrame:self.previewArea.layer.bounds];
    // Adding the camera AVCaptureVideoPreviewLayer to our view's layer.
    [self.previewArea.layer addSublayer:self.captureLayer];
    [self.captureSession startRunning];
    [self.previewArea bringSubviewToFront:self.closeBtn];
    
    /*dispatch_async(dispatch_get_main_queue(), ^{
        [captureMetadataOutput setMetadataObjectTypes:[captureMetadataOutput availableMetadataObjectTypes]];
        
        // Layer that will display what the camera is capturing.
        self.captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        [self.captureLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.captureLayer setFrame:self.previewArea.layer.bounds];
        // Adding the camera AVCaptureVideoPreviewLayer to our view's layer.
        [self.previewArea.layer addSublayer:self.captureLayer];
        [self.captureSession startRunning];
         [self.previewArea bringSubviewToFront:self.closeBtn];
    });
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];*/
}



// AVCaptureMetadataOutputObjectsDelegate method
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // Do your action on barcode capture here:
    NSString *capturedBarcode = nil;
    
    // Specify the barcodes you want to read here:
    NSArray *supportedBarcodeTypes = @[AVMetadataObjectTypeUPCECode,
                                       AVMetadataObjectTypeCode39Code,
                                       AVMetadataObjectTypeCode39Mod43Code,
                                       AVMetadataObjectTypeEAN13Code,
                                       AVMetadataObjectTypeEAN8Code,
                                       AVMetadataObjectTypeCode93Code,
                                       AVMetadataObjectTypeCode128Code,
                                       AVMetadataObjectTypePDF417Code,
                                       AVMetadataObjectTypeQRCode,
                                       AVMetadataObjectTypeAztecCode];
    
    // In all scanned values..
    for (AVMetadataObject *barcodeMetadata in metadataObjects) {
        // ..check if it is a suported barcode
        for (NSString *supportedBarcode in supportedBarcodeTypes) {
            
            if ([supportedBarcode isEqualToString:barcodeMetadata.type]) {
                // This is a supported barcode
                // Note barcodeMetadata is of type AVMetadataObject
                // AND barcodeObject is of type AVMetadataMachineReadableCodeObject
                AVMetadataMachineReadableCodeObject *barcodeObject = (AVMetadataMachineReadableCodeObject *)[self.captureLayer transformedMetadataObjectForMetadataObject:barcodeMetadata];
                capturedBarcode = [barcodeObject stringValue];
                if(capturedBarcode!=nil){
                    if([barcodeMetadata.type isEqualToString:AVMetadataObjectTypeEAN13Code]){
                        if ([capturedBarcode hasPrefix:@"0"] && [capturedBarcode length] > 1)
                            capturedBarcode = [capturedBarcode substringFromIndex:1];
                    }
                }
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.captureSession stopRunning];
                    NSLog(@"Scan result");
                    NSLog(@"%@",capturedBarcode);
                    for(UIView *subViews in [self.parentViewController.view subviews]){
                        subViews.alpha=1.0;
                        [subViews setUserInteractionEnabled:YES];
                    }
                    
                    
                    [self.view removeFromSuperview];
                    [self removeFromParentViewController];
                    NSDictionary* userInfo = @{@"barcode": capturedBarcode};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkScannedItem" object:self userInfo:userInfo];
                });
                return;
            }
        }
    }
}
- (IBAction)submitManualBarcode:(id)sender {
    for(UIView *subViews in [self.parentViewController.view subviews]){
        subViews.alpha=1.0;
        [subViews setUserInteractionEnabled:YES];
    }
    
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    NSDictionary* userInfo = @{@"barcode": self.manualBarcode.text};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkScannedItem" object:nil userInfo:userInfo];
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void )cancelPopup {
    for(UIView *subViews in [self.parentViewController.view subviews]){
        subViews.alpha=1.0;
        //subViews.backgroundColor=[UIColor whiteColor];
        [subViews setUserInteractionEnabled:YES];
    }
    self.parentViewController.view.alpha=1.0;
    self.parentViewController.view.backgroundColor=[UIColor whiteColor];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
}
-(void ) enableButton{
    NSLog(@"here");
    if(self.manualBarcode.text.length>0){
        self.manualSubmitBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
        self.manualSubmitBtn.enabled=true;
    }else{
        self.manualSubmitBtn.backgroundColor=[UIColor grayColor];
        self.manualSubmitBtn.enabled=false;
    }
}

@end
