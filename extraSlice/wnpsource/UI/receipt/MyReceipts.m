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
#import "EsliceTrxnDAO.h"
#import "Utilities.h"



static UIColor *SelectedCellBGColor ;
static UIColor *NotSelectedCellBGColor;
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
@property (strong, nonatomic) UITableView *monthTable;
@property (strong, nonatomic) UITableView *yearTable;
@property (strong, nonatomic) NSArray *monthArray;
@property (strong, nonatomic) NSMutableArray *yearArray;
@property(nonatomic) BOOL isYearExpanded;
@property(nonatomic) BOOL isMonthExpanded;
@property (strong, nonatomic) UILabel *yearLabel;
@property (strong, nonatomic) UILabel *monthLabel;
@property(strong,nonatomic) NSDateFormatter *MMMFormat;
@property(strong,nonatomic) NSDateFormatter *MMFormat;
@property(strong,nonatomic) NSDateFormatter *yyyyFormat;
@property(strong,nonatomic) NSString *selectedYearStr;
@property(strong,nonatomic) NSString *selectedMonthStr;
@property(strong,nonatomic) NSString *selectedMonthInt;
@property(strong,nonatomic) Utilities *eUtils;
@property(strong,nonatomic) NSDictionary *esResult;
@property(strong,nonatomic) NSDictionary *wnpResult;
@property(strong,nonatomic) UIActivityIndicatorView *indicator;
@property(nonatomic) BOOL esRLoaded;
@property(nonatomic) BOOL wnpRLoaded;
@end

@implementation MyReceipts

- (void)viewDidLoad {
    [super viewDidLoad];
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.indicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
    [self.view addSubview:self.indicator];
    self.wnpCont=[[WnPConstants alloc]init];
    self.trxnDao=[[TransactionDAO alloc]init];
    self.utils=[[WnPUtilities alloc]init];
    self.eUtils = [[Utilities alloc]init];
    self.esRLoaded=FALSE;
    self.wnpRLoaded=FALSE;
    self.monthArray = [NSArray arrayWithObjects:@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec", nil ];
    self.yearArray = [[NSMutableArray alloc]init];
    
    self.yyyyFormat = [[NSDateFormatter alloc]init];
    [self.yyyyFormat setDateFormat:@"yyyy"];
    self.selectedYearStr=[self.yyyyFormat stringFromDate:[NSDate date]];
    
    for(int yearInt=2015;yearInt <=self.selectedYearStr.intValue;yearInt++){
        [self.yearArray addObject:[NSString stringWithFormat:@"%d",yearInt]];
    }
    NSLog(@"%@  ---- %d   --  %@",self.selectedYearStr,self.selectedYearStr.intValue,self.yearArray);
    int tabHt = self.yearArray.count*38;
    if(self.yearArray.count*38 >=150){
        tabHt=150;
    }
    // = [NSArray arrayWithObjects:@"2015",@"2016",@"2017", nil];
    self.isYearExpanded=FALSE;
    self.isMonthExpanded=FALSE;
    self.rcptArray=[[NSMutableArray alloc]init];
   
    for(UIView *sv in self.view.subviews){
        [sv removeFromSuperview];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width-8;
    
    int expTabHeight=noOfRecords*38;
    if((screenRect.size.height - 240)  < expTabHeight){
        expTabHeight=(screenRect.size.height - 240);
    }
    self.MMMFormat = [[NSDateFormatter alloc]init];
    self.MMFormat = [[NSDateFormatter alloc]init];
    
    [self.MMMFormat setDateFormat:@"MMM"];
    [self.MMFormat setDateFormat:@"MM"];
 
    self.selectedMonthStr=[self.MMMFormat stringFromDate:[NSDate date]];
    self.selectedMonthInt=[self.MMFormat stringFromDate:[NSDate date]];
    self.yearLabel = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth/2)-35, 5 , 70, 30)];
    [self.view addSubview:self.yearLabel];
    self.yearLabel.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.yearLabel.layer.borderWidth = 1.0f;
    self.yearLabel.text=self.selectedYearStr;
    
    self.monthLabel = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth/2)-115, 5 , 70, 30)];
    [self.view addSubview:self.monthLabel];
    self.monthLabel.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.monthLabel.layer.borderWidth = 1.0f;
    self.monthLabel.text=self.selectedMonthStr;
    SelectedCellBGColor=[UIColor grayColor];
    NotSelectedCellBGColor =[UIColor whiteColor];
    UITapGestureRecognizer *monthTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(expandMonth:)];
    monthTap.numberOfTapsRequired = 1;
    monthTap.numberOfTouchesRequired = 1;
    
    [self.monthLabel setUserInteractionEnabled:YES];
    [self.monthLabel addGestureRecognizer:monthTap];
    
    UITapGestureRecognizer *yearTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(expandYear:)];
    yearTap.numberOfTapsRequired = 1;
    yearTap.numberOfTouchesRequired = 1;
    
    [self.yearLabel setUserInteractionEnabled:YES];
    [self.yearLabel addGestureRecognizer:yearTap];
    
    self.yearTable = [[UITableView alloc] initWithFrame:CGRectMake((tableWidth/2)-35, 34 , 70, tabHt)];
    [self.view addSubview:self.yearTable];
    self.yearTable.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.yearTable.layer.borderWidth = 1.0f;
    
    self.monthTable = [[UITableView alloc] initWithFrame:CGRectMake((tableWidth/2)-115, 34 , 100, 150)];
    [self.view addSubview:self.monthTable];
    self.monthTable.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.monthTable.layer.borderWidth = 1.0f;
    
    self.yearTable.hidden=true;
    self.monthTable.hidden=true;
    self.yearTable.userInteractionEnabled=false;
    self.monthTable.userInteractionEnabled=false;
    self.monthTable.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    self.monthTable.delegate = self;
    self.monthTable.dataSource = self;
    
    self.yearTable.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    self.yearTable.delegate = self;
    self.yearTable.dataSource = self;
    
  
    UIButton *submit = [[UIButton alloc] initWithFrame:CGRectMake((tableWidth/2)+45, 5 , 100, 30)];
    submit.backgroundColor=[self.wnpCont getThemeBaseColor];
    [submit setTitle: @"Submit" forState: UIControlStateNormal];
    submit.userInteractionEnabled=TRUE;
    submit.enabled=TRUE;
    [submit addTarget:self action:@selector(loadNewReceipts:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:submit];
    
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
    [self.view addSubview:self.rcptTable];
    self.rcptTable.delegate = self;
    self.rcptTable.dataSource = self;
    @try{
        if([[self.eUtils getLoggedinUser].userType.uppercaseString isEqualToString:@"MEMBER"]){
            [self performBackgroundTask: @"LOAD_ESLICE_RCPT"];
        }else{
            self.esRLoaded=TRUE;
        }
        [self performBackgroundTask: @"LOAD_WNP_RCPT"];
    }@catch(NSException *exp){
        
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
    [self.view addSubview:self.paginationView];
    [self.view addSubview:rowNoView];
  
    
}
-(void)viewWillAppear:(BOOL)animated{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"memory warning..........................................................................");
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     if ([tableView isEqual:self.monthTable]) {
         return self.monthArray.count;
     }else  if ([tableView isEqual:self.yearTable]) {
         return self.yearArray.count;
     }else{
         return self.rcptArray.count;
         
     }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *celId =@"Cell";
    UITableViewCell *cell = nil;
    //if(cell == nil){
      //  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
   // }
    if ([tableView isEqual:self.monthTable]) {
       // for(int i=0;i<[self.monthArray count];i++){
           if(cell == nil){
               cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
               UILabel *month = [[UILabel alloc] initWithFrame:CGRectMake(2, 2 , (96), 34)];
               UIFont *txtFont = [month.font fontWithSize:15.0];
               month.font = txtFont;
               month.text=[self.monthArray objectAtIndex:indexPath.item] ;
               if([self.monthLabel.text isEqualToString:[self.monthArray objectAtIndex:indexPath.item]]){
                   [cell setBackgroundColor:SelectedCellBGColor];
               }else{
                   [cell setBackgroundColor:NotSelectedCellBGColor];
               }
               [cell addSubview:month];
               self.monthTable.rowHeight=38;
               UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectMonth:)];
               singleTap.numberOfTapsRequired = 1;
               singleTap.numberOfTouchesRequired = 1;
               cell.tag=indexPath.item;
               [cell setUserInteractionEnabled:YES];
               [cell addGestureRecognizer:singleTap];
           }
       // }
    }else  if ([tableView isEqual:self.yearTable]) {
       // for(int i=1;i<[self.yearArray count];i++){
           if(cell == nil){
               cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
               UILabel *month = [[UILabel alloc] initWithFrame:CGRectMake(2, 2 , (96), 34)];
               UIFont *txtFont = [month.font fontWithSize:15.0];
               month.font = txtFont;
               month.text=[self.yearArray objectAtIndex:indexPath.item] ;
               [cell addSubview:month];
               self.yearTable.rowHeight=38;
               if([self.yearLabel.text isEqualToString:[self.yearArray objectAtIndex:indexPath.item]]){
                   [cell setBackgroundColor:SelectedCellBGColor];
               }else{
                   [cell setBackgroundColor:NotSelectedCellBGColor];
               }
               UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectYear:)];
               singleTap.numberOfTapsRequired = 1;
               singleTap.numberOfTouchesRequired = 1;
               cell.tag=indexPath.item;
               [cell setUserInteractionEnabled:YES];
               [cell addGestureRecognizer:singleTap];
            }
       // }
    }else{
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
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSLog(@"didSelectRowAtIndexPath");
    
    if ([tableView isEqual:self.rcptArray]) {
        TransactionModel *trxnModel=[self.rcptArray objectAtIndex:indexPath.item];
        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
        MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
        if(viewCtrl != nil){
            viewCtrl.reciept =trxnModel;
            viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
            viewCtrl.viewName=@"Reciept";
            [self presentViewController:viewCtrl animated:YES completion:nil];
        }
    }else if ([tableView isEqual:self.yearTable]) {
        //self.yearTable = [[UITableView alloc] initWithFrame:CGRectMake((tableWidth/2)-35, 2 , 70, 38*4)];
        
    }else{
        //self.monthTable = [[UITableView alloc] initWithFrame:CGRectMake((tableWidth/2)-145, 2 , 100, 38*12)];
    }
}

- (void)selectMonth:(UIGestureRecognizer *)recognizer{
    int index = (int)recognizer.view.tag;
    self.selectedMonthStr=[self.monthArray objectAtIndex:index];
    self.monthLabel.text=self.selectedMonthStr;
    self.selectedMonthInt=[NSString stringWithFormat:@"%d",(index+1)];
    [self expandMonth:recognizer];
}
- (void)selectYear:(UIGestureRecognizer *)recognizer{
    int index = (int)recognizer.view.tag;
    
    self.selectedYearStr=[self.yearArray objectAtIndex:index];
    self.yearLabel.text=self.selectedYearStr;
    [self expandYear:recognizer];
}

- (void)expandMonth:(UIGestureRecognizer *)recognizer{
    if(self.isMonthExpanded){
        self.isMonthExpanded=false;
        self.monthTable.hidden=true;
        self.monthTable.userInteractionEnabled=false;
        for(UIView *subViews in [self.view subviews]){
            subViews.alpha=1.0;
            subViews.userInteractionEnabled=true;
        }
    }else{
        self.isMonthExpanded=true;
        for(UIView *subViews in [self.view subviews]){
            subViews.alpha=0.2;
            subViews.userInteractionEnabled=false;
        }
        self.monthTable.hidden=false;
        self.monthTable.userInteractionEnabled=true;
        self.monthTable.alpha=1.0;
        self.monthLabel.alpha=1.0;
        self.yearLabel.alpha=1.0;
        self.monthLabel.userInteractionEnabled=true;
        self.yearLabel.userInteractionEnabled=true;
    }
}

- (void)expandYear:(UIGestureRecognizer *)recognizer{
    if(self.isYearExpanded){
        self.isYearExpanded=false;
        self.yearTable.hidden=true;
        self.yearTable.userInteractionEnabled=false;
        for(UIView *subViews in [self.view subviews]){
            subViews.alpha=1.0;
            subViews.userInteractionEnabled=true;
        }
    }else{
        self.isYearExpanded=true;
        
        for(UIView *subViews in [self.view subviews]){
            subViews.alpha=0.2;
            subViews.userInteractionEnabled=false;
        }
        self.yearTable.hidden=false;
        self.yearTable.userInteractionEnabled=true;
        self.yearTable.alpha=1.0;
        self.yearTable.alpha=1.0;
        self.yearLabel.alpha=1.0;
        self.monthLabel.userInteractionEnabled=true;
        self.yearLabel.userInteractionEnabled=true;
    }
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
- (void) loadNewReceipts:(id)sender{
    self.esRLoaded=FALSE;
    self.wnpRLoaded=FALSE;
     self.rcptArray=[[NSMutableArray alloc]init];
    if([[self.eUtils getLoggedinUser].userType.uppercaseString isEqualToString:@"MEMBER"]){
        [self performBackgroundTask: @"LOAD_ESLICE_RCPT"];
    }else{
        self.esRLoaded=TRUE;
    }
    
    [self performBackgroundTask: @"LOAD_WNP_RCPT"];
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
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *currentSelectedIndexPath = [tableView indexPathForSelectedRow];
    if (currentSelectedIndexPath != nil)
    {
        [[tableView cellForRowAtIndexPath:currentSelectedIndexPath] setBackgroundColor:NotSelectedCellBGColor];
    }
    
    return indexPath;
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

- (void)performBackgroundTask:(NSString *)purpose
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        if(!self.esRLoaded && !self.wnpRLoaded){
            CGAffineTransform transform = CGAffineTransformMakeScale(2.0f, 2.0f);
            self.indicator.transform = transform;
            self.indicator.center = self.view.center;
            [self.indicator bringSubviewToFront:self.view];
            if(![self.indicator isAnimating]){
              //  [self.indicator startAnimating];
            }
            
        }
      
        @try{
            NSDateFormatter *format = [[NSDateFormatter alloc]init];
            NSString *startDateStr = [NSString stringWithFormat:@"%@%@%@%@",self.selectedYearStr,@"-",self.selectedMonthInt,@"-01 00:00:0"];
            [format setDateFormat:@"yyyy-M-dd hh:mm:s"];
            NSDate *startDate=[format dateFromString:startDateStr];
            NSCalendar *gregorian = [NSCalendar currentCalendar];
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setMonth:1];
            NSDate *enddate = [gregorian dateByAddingComponents:dateComponents toDate:startDate options:0];
            NSString *endDateStr = [format stringFromDate:enddate];
            if([purpose isEqualToString:@"LOAD_ESLICE_RCPT"]){
                EsliceTrxnDAO *eTrxnDAO = [[EsliceTrxnDAO alloc]init];
                self.esResult=[eTrxnDAO getEsliceReceipts:[self.eUtils getLoggedinUser].userId StartDate:startDateStr EndDate:endDateStr];
                NSLog(@"%@",self.esResult);
            }else if([purpose isEqualToString:@"LOAD_WNP_RCPT"]){
                TransactionDAO *trxnDAO = [[TransactionDAO alloc]init];
                self.wnpResult=[trxnDAO getAllWnpReceipts:[self.wnpCont getUserId] StartDate:startDateStr EndDate:endDateStr];
            }
            NSLog(@"%s%@%s%@","start ..........",startDateStr,"      ensstr ....",endDateStr);
            
        }@catch(NSException *exp){
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            int totalRcpt = 0;
            if([purpose isEqualToString:@"LOAD_ESLICE_RCPT"]){
                self.esRLoaded=TRUE;
                if([@"SUCCESS"  isEqual: [self.esResult objectForKey:@"STATUS"]]){
                    NSArray *userRcpts=[self.esResult objectForKey:@"TransactionList"];
                    for(NSDictionary *rcptItem in userRcpts){
                        TransactionModel *trxnModel = [[TransactionModel alloc]init];
                        trxnModel=[trxnModel initWithDictionary:rcptItem];
                        [self.rcptArray addObject:trxnModel];
                    }
                }else{
                    //status = [NSMutableString stringWithString:[result objectForKey:@"ERRORMESSAGE"]];
                }
            }else if([purpose isEqualToString:@"LOAD_WNP_RCPT"]){
                self.wnpRLoaded=TRUE;
                if([@"SUCCESS"  isEqual: [self.wnpResult objectForKey:@"STATUS"]]){
                    NSArray *userRcpts=[self.wnpResult objectForKey:@"TransactionList"];
                    for(NSDictionary *rcptItem in userRcpts){
                        TransactionModel *trxnModel = [[TransactionModel alloc]init];
                        trxnModel=[trxnModel initWithDictionary:rcptItem];
                        [self.rcptArray addObject:trxnModel];
                    }
                }else{
                    //status = [NSMutableString stringWithString:[result objectForKey:@"ERRORMESSAGE"]];
                }
            }
            
            if(self.wnpRLoaded && self.esRLoaded){
                totalRcpt = self.rcptArray.count;
                CGRect screenRect = [[UIScreen mainScreen] bounds];
                CGFloat tableWidth = screenRect.size.width-8;
                int noOfpages=1;
                if(totalRcpt >0 ){
                    noOfpages=totalRcpt/noOfRecords;
                    if((totalRcpt%noOfRecords) >0){
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
                
                [self.indicator stopAnimating];
                self.esRLoaded=FALSE;
                self.wnpRLoaded=FALSE;
                
                [self.rcptTable reloadData];
            }
            
            
        });
    });
}


@end
