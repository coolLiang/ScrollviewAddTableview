//
//  ViewController.m
//  scrollTest
//
//  Created by noci on 2016/11/14.
//  Copyright © 2016年 noci. All rights reserved.
//

#import "ViewController.h"
#import "MJRefresh.h"

//随机颜色
#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]

#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#define CUTOFFVIEWY  240
#define CUTOFFVIEWHEIGHT 60
#define APPENDINGHEIGHT  300
#define NAVIBARHEIGHT  64
#define SUPERVIEWTAG   110

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UIScrollView * scrollview;

@property(nonatomic,strong)UITableView * tableview;

@property(nonatomic,strong)UIView * cutoffview;

@property(nonatomic,assign)BOOL notUpdate;

@property(nonatomic,strong)NSMutableArray * dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"home";
    
    self.scrollview = [UIScrollView new];
    self.scrollview.frame = self.view.bounds;
    self.scrollview.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + APPENDINGHEIGHT);
    self.scrollview.backgroundColor = [UIColor whiteColor];
    [self.scrollview setScrollEnabled:NO];
    self.scrollview.tag = SUPERVIEWTAG;
    self.scrollview.delegate = self;
    self.scrollview.bounces = NO;
    [self.view addSubview:self.scrollview];
    
    self.cutoffview = [UIView new];
    self.cutoffview.backgroundColor = [UIColor blueColor];
    self.cutoffview.frame = CGRectMake(0, CUTOFFVIEWY, self.view.frame.size.width, CUTOFFVIEWHEIGHT);
    [self.scrollview addSubview:self.cutoffview];
    
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - NAVIBARHEIGHT + APPENDINGHEIGHT) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = [UIColor clearColor];

    self.tableview.contentInset = UIEdgeInsetsMake(APPENDINGHEIGHT, 0, 0, 0);
    [self.scrollview addSubview:self.tableview];
    
    [self.scrollview bringSubviewToFront:self.cutoffview];
    
    
    [self addTableRefresh];
    
    self.dataArray = [NSMutableArray new];
    for (int i = 0;  i < 10; i ++) {
        
        [self.dataArray addObject:@(0)];
    }
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)addTableRefresh
{
    __weak typeof(self) weakSelf = self;
    
    [self.tableview addLegendFooterWithRefreshingBlock:^{
        
        __strong typeof(self) strongSelf = weakSelf;
        
        for (int i = 0; i < 10; i ++) {
            
            [strongSelf.dataArray addObject:@(0)];
        }
        
        [strongSelf performSelector:@selector(cancelRefresh) withObject:strongSelf afterDelay:3];
        
    }];
    
    [self.tableview addLegendHeaderWithRefreshingBlock:^{
        
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.dataArray removeAllObjects];
        
        for (int i = 0; i < 10; i ++) {
            
            [strongSelf.dataArray addObject:@(0)];
        }
        
        [strongSelf performSelector:@selector(cancelRefresh) withObject:strongSelf afterDelay:3];
    }];
}

-(void)cancelRefresh
{
    [self.tableview.header endRefreshing];
    [self.tableview.footer endRefreshing];
    
    [self.tableview reloadData];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * ID = @"cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.backgroundColor = randomColor;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //偏移值。
    CGPoint contentOffset = scrollView.contentOffset;
    //初始偏移值重置。
    CGFloat yMargin;
    
    NSLog(@"111当前table的偏移%@",NSStringFromCGPoint(self.tableview.contentOffset));
    NSLog(@"111当前scroll的偏移%@",NSStringFromCGPoint(self.scrollview.contentOffset));

    if (scrollView.tag == SUPERVIEWTAG) {
        
        yMargin = contentOffset.y;
        
        if (yMargin >= CUTOFFVIEWY/2) {
            
            self.cutoffview.frame = CGRectMake(self.cutoffview.frame.origin.x, yMargin, self.cutoffview.frame.size.width, self.cutoffview.frame.size.height);
            
        }
        else
        {

             self.cutoffview.frame = CGRectMake(0, CUTOFFVIEWY - yMargin, self.view.frame.size.width, CUTOFFVIEWHEIGHT);
        }
        
    }
    else
    {
        yMargin = contentOffset.y + APPENDINGHEIGHT;
        
        if (yMargin <= APPENDINGHEIGHT && yMargin > 0) {
            
            [self.scrollview setContentOffset:CGPointMake(scrollView.contentOffset.x, yMargin) animated:NO];

        }
        
        else if (yMargin > APPENDINGHEIGHT)
        {
            [self.scrollview setContentOffset:CGPointMake(scrollView.contentOffset.x, APPENDINGHEIGHT) animated:NO];
        }
        else
        {
            
            [self.scrollview setContentOffset:CGPointMake(scrollView.contentOffset.x, 0) animated:NO];
            
            [self updateTheUI];
            
        }
        
        NSLog(@"222当前table的偏移%@",NSStringFromCGPoint(self.tableview.contentOffset));
        NSLog(@"222当前scroll的偏移%@",NSStringFromCGPoint(self.scrollview.contentOffset));
//
//        NSLog(@"当前table的坐标%@",NSStringFromCGRect(scrollView.frame));
//        

//
//        NSLog(@"当前scroll的坐标%@",NSStringFromCGRect(self.scrollview.frame));
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"111当前table的偏移%@",NSStringFromCGPoint(self.tableview.contentOffset));
    
//    NSLog(@"%@",NSStringFromCGRect(self.cutoffview.frame));
//    
//    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
//    
//    NSLog(@"%@",NSStringFromCGRect(self.tableview.frame));
    
}

-(void)updateTheUI
{
    self.cutoffview.frame = CGRectMake(0, CUTOFFVIEWY, self.view.frame.size.width, CUTOFFVIEWHEIGHT);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
