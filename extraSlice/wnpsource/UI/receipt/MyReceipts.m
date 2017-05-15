//
//  MyReceipts.m
//  walkNPay
//
//  Created by Administrator on 28/01/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "MyReceipts.h"
#import "WnPConstants.h"
#import "TransactionDAO.h"
#import "TransactionModel.h"
#import "WnPUtilities.h"
#import "MenuController.h"

@interface MyReceipts ()
@property (strong,nonatomic) NSMutableArray *rcptArray;
@property(strong,nonatomic)WnPConstants *wnpCont;
@property(strong,nonatomic)TransactionDAO *trxnDao;
@property(strong,nonatomic) WnPUtilities *utils;
@property (strong, nonatomic)  UIView *header;
@property (strong, nonatomic)  UITableView *rcptTable;
@property (strong, nonatomic) UIView *paginationView;
@property (strong, nonatomic)  UITextField *limitView;
@property(strong ,nonatomic) UILabel  *lbl;
@end

@implementation MyReceipts

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wnpCont=[[WnPConstants alloc]init];
    self.trxnDao=[[TransactionDAO alloc]init];
    self.utils=[[WnPUtilities alloc]init];
   
    self.rcptArray=[[NSMutableArray alloc]init];
   
    for(UIView *sv in self.view.subviews){
        [sv removeFromSuperview];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width-8;
    
    int expTabHeight=noOfRecords*38;
    if((screenRect.size.height - 207)  < expTabHeight){
        expTabHeight=(screenRect.size.height - 207);
    }
    
    UILabel *mainHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , (tableWidth+8), 40)];
    mainHeader.text=@"My Receipts";
    mainHeader.textColor=[self.wnpCont getThemeBaseColor];
    mainHeader.textAlignment= NSTextAlignmentCenter;
    UIFont *mainHeaderFont = [UIFont boldSystemFontOfSize:18.0];
    mainHeader.font = mainHeaderFont;
    
    
    [self.view addSubview:mainHeader];
    self.header = [[UIView alloc] initWithFrame:CGRectMake(0, 40 , (tableWidth+8), 30)];
    self.header.backgroundColor=[self.wnpCont getThemeBaseColor];
    
    self.rcptTable=[[UITableView alloc] initWithFrame:CGRectMake(0, 70 , (tableWidth+8), expTabHeight)];
    
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(2, 2 , (tableWidth*0.2), 34)];
    UIFont *txtFont = [date.font fontWithSize:15.0];
    date.font = txtFont;
    date.text=@"Date";
    [self.header addSubview:date];
    
    UILabel *store = [[UILabel alloc] initWithFrame:CGRectMake(2+(tableWidth*0.2), 2 , (tableWidth*0.4), 34)];
    store.font = txtFont;
    store.text=@"Store";
    [self.header addSubview:store];
    
    UILabel *orderNo = [[UILabel alloc] initWithFrame:CGRectMake(4+(tableWidth*0.6), 2 , (tableWidth*0.2), 34)];
    orderNo.font = txtFont;
    orderNo.text=@"OrderNo";
    [self.header addSubview:orderNo];
    
    UILabel *total = [[UILabel alloc] initWithFrame:CGRectMake(8+(tableWidth*0.8), 2 , (tableWidth*0.2), 34)];
    total.font = txtFont;
    total.text=@"Total";
    [self.header addSubview:total];
    
    
   // NSDictionary *webResult=[self.trxnDao getAllRecieptsForuser:[self.wnpCont getUserId] SoreId:@0];
    NSDictionary *webResult=[self.trxnDao getAllRecieptsForuserWithOffset:[self.wnpCont getUserId] StoreId:@0 Limit:noOfRecords Offset:offset];
    NSNumber *totalRcpt = [NSNumber numberWithInt:0];
                             
    if([@"SUCCESS"  isEqual: [webResult objectForKey:@"STATUS"]]){
        NSArray *userRcpts=[webResult objectForKey:@"TransactionList"];
        totalRcpt = [webResult objectForKey:@"COUNT"];
        for(NSDictionary *rcptItem in userRcpts){
            TransactionModel *trxnModel = [[TransactionModel alloc]init];
            trxnModel=[trxnModel initWithDictionary:rcptItem];
            [self.rcptArray addObject:trxnModel];
        }
    }else{
        //status = [NSMutableString stringWithString:[result objectForKey:@"ERRORMESSAGE"]];
    }
    
    self.rcptTable.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, expTabHeight+71 , (tableWidth+8), 1)];
    seperator.backgroundColor=[self.wnpCont getThemeHeaderColor];
    [self.view addSubview:seperator];
    
    UIView *rowNoView = [[UIView alloc] initWithFrame:CGRectMake(0, expTabHeight+73 , (tableWidth+8), 30)];
    
    
    UILabel *pageDetl = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth-155), 0 , 100, 25)];
    pageDetl.text=@"No of rows";
    [rowNoView addSubview:pageDetl];
    
    
    self.limitView = [[UITextField alloc] initWithFrame:CGRectMake((tableWidth-50), 0 , 40, 25)];
    self.limitView.textAlignment=NSTextAlignmentCenter;
    self.limitView.text=[NSString stringWithFormat:@"%d",noOfRecords];
    [rowNoView addSubview:self.limitView];
    self.limitView.userInteractionEnabled=TRUE;
    [self.limitView setKeyboardType:UIKeyboardTypeDecimalPad   ];
    self.limitView.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.limitView.layer.borderWidth = 1.0f;
    
   /* UIButton *goBtn = [[UIButton alloc] initWithFrame:CGRectMake((tableWidth-72), 0 , 75, 25)];
    goBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    [goBtn setTitle: @"Change" forState: UIControlStateNormal];
    goBtn.userInteractionEnabled=TRUE;
    goBtn.enabled=TRUE;
    [goBtn addTarget:self action:@selector(changeNoOfRecords:) forControlEvents: UIControlEventTouchUpInside];
    [rowNoView addSubview:goBtn];*/
    
    self.paginationView = [[UIView alloc] initWithFrame:CGRectMake(0, (expTabHeight+104) , (tableWidth+8), 34)];
    self.paginationView.backgroundColor=[self.wnpCont getThemeHeaderColor];
    self.paginationView.userInteractionEnabled=true;
    

    
    
    int noOfpages=1;
    if(totalRcpt.intValue >0 ){
        noOfpages=totalRcpt.intValue/noOfRecords;
        if((totalRcpt.intValue%noOfRecords) >0){
            noOfpages = noOfpages+1;
        }
    }
    
     NSLog(@"%s%d","pages ..........",noOfpages);
    if(noOfpages <=((pageset+1)*3)){
        int index=1;
        for(;index<=noOfpages;index++){
            if(noOfpages <((pageset*3)+index)){
                break;
            }
            
            UILabel *pageView = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth-(35*index)), 2 , 30, 30)];
            [self.paginationView addSubview:pageView];
            if((noOfpages-(index-1)) ==(pageNo+1)){
                pageView.backgroundColor=[self.wnpCont getThemeBaseColor];
            }else{
                pageView.backgroundColor=[UIColor clearColor];
            }
            pageView.textColor=[UIColor whiteColor];
            pageView.textAlignment=NSTextAlignmentCenter;
            pageView.text=[NSString stringWithFormat:@"%d",(noOfpages-(index-1))];
            pageView.tag=(noOfpages-(pageset*3)-(index-1));
            UITapGestureRecognizer *pageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
            pageTap.numberOfTapsRequired = 1;
            pageTap.numberOfTouchesRequired = 1;
            [pageView setUserInteractionEnabled:YES];
            [pageView addGestureRecognizer:pageTap];
        }
        if(noOfpages > 3){
            UILabel *pageView = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth-(35*index)), 2 , 30, 30)];
            [self.paginationView addSubview:pageView];
            pageView.backgroundColor=[UIColor clearColor];
            pageView.textColor=[UIColor whiteColor];
            pageView.textAlignment=NSTextAlignmentCenter;
            pageView.text=@"<";
            pageView.tag=(noOfpages-(index-1));
            
            UITapGestureRecognizer *pageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(previousSet:)];
            pageTap.numberOfTapsRequired = 1;
            pageTap.numberOfTouchesRequired = 1;
            [pageView setUserInteractionEnabled:YES];
            [pageView addGestureRecognizer:pageTap];
        }
    }else{
        int index = 1;
        for(;index<=3;index++){
            UILabel *pageView = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth-(35+35*index)), 2 , 30, 30)];
            [self.paginationView addSubview:pageView];
            if(((3*pageset)+3-(index-1)) ==(pageset*3)+(pageNo+1)){
                pageView.backgroundColor=[self.wnpCont getThemeBaseColor];
            }else{
                pageView.backgroundColor=[UIColor clearColor];
            }
            
            pageView.textColor=[UIColor whiteColor];
            pageView.textAlignment=NSTextAlignmentCenter;
            pageView.text=[NSString stringWithFormat:@"%d",((3*pageset)+3-(index-1))];
            pageView.tag=(3-(index-1));
            pageView.userInteractionEnabled=true;
            
            
            UITapGestureRecognizer *pageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
            pageTap.numberOfTapsRequired = 1;
            pageTap.numberOfTouchesRequired = 1;
            [pageView setUserInteractionEnabled:YES];
            [pageView addGestureRecognizer:pageTap];

        }
        if(noOfpages > 3 && pageset > 0){
            UILabel *pageView = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth-(35+35*index)), 2 , 30, 30)];
            [self.paginationView addSubview:pageView];
            pageView.backgroundColor=[UIColor clearColor];
            pageView.textColor=[UIColor whiteColor];
            pageView.textAlignment=NSTextAlignmentCenter;
            pageView.text=@"<";
            pageView.tag=(noOfpages-(index-1));
            
            UITapGestureRecognizer *pageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(previousSet:)];
            pageTap.numberOfTapsRequired = 1;
            pageTap.numberOfTouchesRequired = 1;
            [pageView setUserInteractionEnabled:YES];
            [pageView addGestureRecognizer:pageTap];
        }
        UILabel *pageView = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth-(35)), 2 , 30, 30)];
        [self.paginationView addSubview:pageView];
        pageView.backgroundColor=[UIColor clearColor];
        pageView.textColor=[UIColor whiteColor];
        pageView.textAlignment=NSTextAlignmentCenter;
        pageView.text=@">";
        pageView.tag=4;
        
        UITapGestureRecognizer *pageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(nextSet:)];
        pageTap.numberOfTapsRequired = 1;
        pageTap.numberOfTouchesRequired = 1;
        [pageView setUserInteractionEnabled:YES];
        [pageView addGestureRecognizer:pageTap];
    }
    [self.view bringSubviewToFront:self.paginationView];
    for(UIView *sv in self.paginationView.subviews){
        [self.paginationView bringSubviewToFront:sv];
    }
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
   // UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneClicked:)];
    //[keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    self.lbl=[[UILabel alloc] initWithFrame:CGRectMake((tableWidth-(85)), 2 , 30, 30)];
    [self.limitView addTarget:self action:@selector(editQuantity:) forControlEvents: UIControlEventAllEditingEvents] ;
    self.lbl.text=self.limitView.text;
    [keyboardDoneButtonView addSubview:self.lbl];
    self.limitView.inputAccessoryView = keyboardDoneButtonView;
    
    
    
    UIButton *goBtn = [[UIButton alloc] initWithFrame:CGRectMake((tableWidth-50), 2 , 50, 25)];
    goBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    [goBtn setTitle: @"Done" forState: UIControlStateNormal];
    goBtn.userInteractionEnabled=TRUE;
    goBtn.enabled=TRUE;
    [goBtn addTarget:self action:@selector(changeNoOfRecords:) forControlEvents: UIControlEventTouchUpInside];
    [keyboardDoneButtonView addSubview:goBtn];
    
    
    [self.view addSubview:self.header];
    [self.view addSubview:self.rcptTable];
    [self.view addSubview:self.paginationView];
    [self.view addSubview:rowNoView];
    self.rcptTable.delegate = self;
    self.rcptTable.dataSource = self;
    
}
-(void)viewWillAppear:(BOOL)animated{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"memory warning..........................................................................");
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.rcptArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *celId =[NSString stringWithFormat:@"%s%ld","Cell",(long)indexPath.item];;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:celId];
    TransactionModel *trxnModel=[self.rcptArray objectAtIndex:indexPath.item];

    if(trxnModel !=nil){
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
        
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat tableWidth = screenRect.size.width-8;
        
            UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(2, 2 , (tableWidth*0.2), 34)];
            UIFont *txtFont = [date.font fontWithSize:15.0];
            date.font = txtFont;
            date.text=[self.utils changeDateFormat:trxnModel.orderDate] ;
            [cell addSubview:date];
        
            UILabel *store = [[UILabel alloc] initWithFrame:CGRectMake(2+(tableWidth*0.2), 2 , (tableWidth*0.4), 34)];
            store.font = txtFont;
            store.text=[trxnModel.recieptStore objectForKey:@"name"] ;
            [cell addSubview:store];
        
            UILabel *orderNo = [[UILabel alloc] initWithFrame:CGRectMake(4+(tableWidth*0.6), 2 , (tableWidth*0.2), 34)];
            orderNo.font = txtFont;
            orderNo.text=trxnModel.orderId.stringValue;
            [cell addSubview:orderNo];

            UILabel *total = [[UILabel alloc] initWithFrame:CGRectMake(8+(tableWidth*0.8), 2 , (tableWidth*0.2), 34)];
            total.font = txtFont;
            total.text=[self.utils getNumberFormatter:trxnModel.grossTotal.doubleValue];
            [cell addSubview:total];
        
            UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 37 , tableWidth, 1)];
            [seperator setBackgroundColor:[self.wnpCont getThemeHeaderColor]];
            [cell addSubview:seperator];
            self.rcptTable.rowHeight=38;
        }
    }
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showReceipt:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    cell.tag=indexPath.item;
    [cell setUserInteractionEnabled:YES];
    [cell addGestureRecognizer:singleTap];
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSIndexPath *currentSelectedIndexPath = [tableView indexPathForSelectedRow];
    if (currentSelectedIndexPath != nil)
    {
        NSLog(@"willSelectRowAtIndexPath");
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TransactionModel *trxnModel=[self.rcptArray objectAtIndex:indexPath.item];
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
    MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
    if(viewCtrl != nil){
        viewCtrl.reciept =trxnModel;
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        viewCtrl.viewName=@"Reciept";
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}



- (void)showReceipt:(UIGestureRecognizer *)recognizer{
    int index = (int)recognizer.view.tag;
    TransactionModel *trxnModel=[self.rcptArray objectAtIndex:index];
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
    MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
    if(viewCtrl != nil){
        viewCtrl.reciept =trxnModel;
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        viewCtrl.viewName=@"Reciept";
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }
}


- (void) tapDetected:(UIGestureRecognizer *)recognizer{
    pageNo=(int)recognizer.view.tag-1;
    offset=(pageset*noOfRecords*3)+(pageNo*noOfRecords);
    [self viewDidLoad];
}

- (void) nextSet:(UIGestureRecognizer *)recognizer{
    pageset=pageset+1;
    for(UIView *sv in self.paginationView.subviews){
        [sv removeFromSuperview];
    }
    pageNo=0;
    offset=(pageset*noOfRecords*3)+(pageNo*noOfRecords);
    [self viewDidLoad];
}

- (void) previousSet:(UIGestureRecognizer *)recognizer{
    pageset=pageset-1;
    pageNo=0;
    for(UIView *sv in self.paginationView.subviews){
        [sv removeFromSuperview];
    }
    offset=(pageset*noOfRecords*3)+(pageNo*noOfRecords);
    [self viewDidLoad];
}

- (void)changeNoOfRecords:(id)sender {
    
    noOfRecords=self.limitView.text.intValue;
    offset=0;
    pageset=0;
    pageNo=0;
    offset=(pageset*noOfRecords*3)+(pageNo*noOfRecords);
    [self viewDidLoad];
}

- (IBAction)doneClicked:(id)sender
{
    [self changeNoOfRecords:sender];
    [self.view endEditing:YES];
}
-(void) resetDefault{
    noOfRecords=10;
    pageset=0;
    pageNo=0;
    offset=0;
    
}
-(void)editQuantity:(UIGestureRecognizer *)recognizer{
    self.lbl.text=self.limitView.text;
}
@end
