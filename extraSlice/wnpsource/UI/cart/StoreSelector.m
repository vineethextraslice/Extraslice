//
//  StoreSelector.m
//  WalkNPay
//
//  Created by Administrator on 12/01/16.
//  Copyright © 2016 Extraslice. All rights reserved.
//

#import "StoreSelector.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"
#import "StoreModel.h"

static UIColor *SelectedCellBGColor ;
static UIColor *NotSelectedCellBGColor;
@interface StoreSelector ()

@property(nonatomic) NSNumber *selectedStoreId;
@property(strong,nonatomic) UIView *previousRow;
@property(strong,nonatomic) WnPConstants *wnpCont;
@property(strong,nonatomic) NSString *currCode;
@property(strong,nonatomic) NSString *currSymb;

@end

@implementation StoreSelector

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wnpCont =[[WnPConstants alloc]init];
    self.storeSelector.delegate = self;
    self.storeSelector.dataSource = self;
    if(self.errorText ==nil){
        [self.view setBounds:CGRectMake(0,0, 250,235)];
    }else{
        [self.view setBounds:CGRectMake(0,0, 250,285)];
    }
    
    SelectedCellBGColor=[UIColor grayColor];
    NotSelectedCellBGColor =[UIColor whiteColor];
    //self.storeSelector.layer.borderColor= [self.wnpCont getThemeBaseColor].CGColor;
   // self.storeSelector.layer.borderWidth = 1.0f;
    self.header.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.selectedStoreId=[NSNumber numberWithInt:-1];
    self.okButton.backgroundColor=[UIColor grayColor];
    self.okButton.enabled=false;
    self.cancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.previousRow=nil;
    self.view.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.view.layer.borderWidth = 1.0f;
    for(UIView *subViews in [self.topView subviews]){
        subViews.userInteractionEnabled=TRUE;
    }
    if(self.errorText != nil){
      
        // [utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:self.errorText];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.storeArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSString *celId =[NSString stringWithFormat:@"%s%ld","Cell",(long)indexPath.item];;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:celId];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
    }else{
        for (UIView *sv in [cell subviews]){
            [sv removeFromSuperview];
        }
    }
    
        //if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat tableWidth = screenRect.size.width-10;
        
        UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(0, 2 , (tableWidth), 34)];
        UIFont *txtFont = [code.font fontWithSize:15.0];
        code.font = txtFont;
        [code setUserInteractionEnabled:TRUE];
        [code setEnabled:YES];
        UITapGestureRecognizer *codeSel=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setSelectStore:)];
        [codeSel setNumberOfTapsRequired:1];
        [code addGestureRecognizer:codeSel];
        StoreModel *strMdl = [self.storeArray objectAtIndex:indexPath.item];
        code.text=[NSString stringWithFormat:@"%s%@", "  ", strMdl.name];
        if(self.selectedStoreId.intValue == strMdl.storeId.intValue){
            code.backgroundColor=[UIColor grayColor];
        }else{
            code.backgroundColor=[UIColor whiteColor];
        }
        [cell addSubview:code];
        [cell bringSubviewToFront:code];
        
        
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 35 , tableWidth, 1)];
        [seperator setBackgroundColor:[self.wnpCont getThemeHeaderColor]];
        [cell addSubview:seperator];
        self.storeSelector.rowHeight=35;
        
    //}
    
    
    
    return cell;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *currentSelectedIndexPath = [tableView indexPathForSelectedRow];
    if (currentSelectedIndexPath != nil)
    {
        [[tableView cellForRowAtIndexPath:currentSelectedIndexPath] setBackgroundColor:NotSelectedCellBGColor];
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setBackgroundColor:SelectedCellBGColor];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.isSelected == YES)
    {
        [cell setBackgroundColor:SelectedCellBGColor];
    }
    else
    {
        [cell setBackgroundColor:NotSelectedCellBGColor];
    }
}

-(IBAction) setSelectStore:(UIGestureRecognizer *)recognizer{
    NSIndexPath *selectedIndexPath = [self.storeSelector indexPathForRowAtPoint:[recognizer locationInView:self.storeSelector]];
    StoreModel *strMdl = [self.storeArray objectAtIndex:selectedIndexPath.item];
    self.selectedStoreId=strMdl.storeId;
    self.currCode=strMdl.currencyCode;
    self.currSymb=strMdl.currencySymbol;
    NSLog(@"%@",strMdl.storeId);
    recognizer.view.backgroundColor=SelectedCellBGColor;
    if(self.previousRow !=nil){
        self.previousRow.backgroundColor=NotSelectedCellBGColor;
    }
    self.previousRow=recognizer.view;
    [self enableButton];
}


- (IBAction)selectStore:(id)sender {
    NSLog(@"selectStore");
    
    [self.wnpCont setSelectedStoreId:self.selectedStoreId];
    [self.wnpCont setCurrencyCode:self.currCode];
    [self.wnpCont setCurrencySymbol:self.currSymb];
    for(UIView *subViews in [self.parentViewController.view subviews]){
        subViews.alpha=1.0;
        [subViews setUserInteractionEnabled:YES];
    }
    
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    if(self.notifyAfter){
        if(self.requestedFrom != nil && [self.requestedFrom isEqualToString:@"Cart"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeStoreFromCart" object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeStore" object:nil];
        }
        
    }
    
}
- (IBAction)cancelPopup:(id)sender {
    for(UIView *subViews in [self.parentViewController.view subviews]){
        subViews.alpha=1.0;
        [subViews setUserInteractionEnabled:YES];
    }
    self.parentViewController.view.alpha=1.0;
    self.parentViewController.view.backgroundColor=[UIColor whiteColor];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];}

-(void ) enableButton{
    if(self.selectedStoreId.intValue >0){
        self.okButton.backgroundColor=[self.wnpCont getThemeBaseColor];
        self.okButton.enabled=true;
    }else{
        self.okButton.backgroundColor=[UIColor grayColor];
        self.okButton.enabled=false;
    }
}
@end
