//
//  HBXIMFirstViewController.m
//  XMPPStreamDemo
//
//  Created by 黄保贤 on 2017/7/12.
//  Copyright © 2017年 黄保贤. All rights reserved.
//

#import "HBXIMFirstViewController.h"
#import <XMPPFramework/XMPPFramework.h>
#import "HBXLoginViewController.h"

@interface HBXIMFirstViewController ()<HBXXMPPToolDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPJID *formJid;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;




@end

@implementation HBXIMFirstViewController


- (instancetype)init {
    
    if (self = [super init]) {
        
//        XMPPRosterCoreDataStorage  *res = [XMPPRosterCoreDataStorage sharedInstance];
//      
//        
//        self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:res dispatchQueue:dispatch_get_main_queue()];
//        
//        [self.xmppRoster activate: self.xmppStream];
//        
//        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"聊天";
    self.view.backgroundColor = [UIColor whiteColor];
     [self.view addSubview:self.tableView];
    
   
    
    
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [[HBXXMPPTool instance] addDelegate:self];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[HBXXMPPTool instance] removeDelegate:self];
    
}

- (void)setRightBtn {

    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"登陆" style:UIBarButtonItemStyleDone target:self action:@selector(loginClick)];
    
    self.navigationItem.rightBarButtonItem = rightBtnItem;

}

- (void)loginClick {
    
    HBXLoginViewController *loginVC = [[HBXLoginViewController alloc] init];
    
    [self.navigationController pushViewController:loginVC animated:YES];

}

#pragma mark -- xmppStreamDelegate 
#pragma mark -- 链接服务器

- (void)HBXXMPPStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
        NSString *messageStr = [NSString stringWithFormat:@"%@: %@",[[message from] user], message.body];
        [self.dataArray addObject:messageStr];
        [self.tableView reloadData];
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}



#pragma mark --tableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"messageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}


#pragma makr -- tableViewdatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark --getter 

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.tableFooterView=[[UIView alloc] init];
        
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
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
