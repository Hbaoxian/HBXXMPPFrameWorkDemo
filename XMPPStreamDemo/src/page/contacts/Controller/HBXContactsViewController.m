//
//  HBXContactsViewController.m
//  XMPPStreamDemo
//
//  Created by 黄保贤 on 17/7/13.
//  Copyright © 2017年 黄保贤. All rights reserved.
//

#import "HBXContactsViewController.h"
#import <CoreData/CoreData.h>

@interface HBXContactsViewController () <NSFetchedResultsControllerDelegate, HBXXMPPToolDelegate, UITableViewDelegate, UITableViewDataSource> {
     NSFetchedResultsController *_fetchResultController;
}

@property (nonatomic, strong) NSMutableArray *userArray;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *friendArray;
@property (nonatomic, strong) UITextField *friendPhoneFiled;

@end

@implementation HBXContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"联系人";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [[HBXXMPPTool instance] fetchFriends];
    [self setRightBarBtn];
    
    
//    [self loadFriend];
    // Do any additional setup after loading the view.
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[HBXXMPPTool instance] addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[HBXXMPPTool instance] removeDelegate:self];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
     [[HBXXMPPTool instance] fetchFriends];
}

- (void)loadFriend {
    
    if ([HBXXMPPTool instance].rosterStorage == nil) {
        return;
    }
    NSManagedObjectContext *context = [HBXXMPPTool instance].rosterStorage.mainThreadManagedObjectContext;
    
    // 创建查询请求【要查哪张表】
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 设置过滤条件，找谁的好友，有可能多个用户登录
    NSString *userJid = [[HBXXMPPTool instance] getMyJid];
    //WXLog(@"%@",userJid);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND (subscription contains %@)",userJid,@"both"];
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subscription contains %@",@"both"];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",userJid];
    request.predicate = predicate;
    
    // 设置排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"nickname" ascending:YES];
    NSSortDescriptor *sectionNumSort = [NSSortDescriptor sortDescriptorWithKey:@"sectionNum" ascending:YES];
    request.sortDescriptors = @[sectionNumSort,sort];
    
    _fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _fetchResultController.delegate = self;
    
    // 执行查询
    NSError *error = nil;
    BOOL isSuccess = [_fetchResultController performFetch:&error];
    
    NSArray *contentArray = [context executeFetchRequest:request error:&error];
    
    if (error) {
        HBXLogNet(@"%@",error);
    }

    if (_fetchResultController.fetchedObjects.count) {
        for (XMPPUserCoreDataStorageObject *object in _fetchResultController.fetchedObjects) {
            NSLog(@"object.displayName is %@", object.displayName);
        }
    }
    for (XMPPUserCoreDataStorageObject *object in contentArray) {
            NSLog(@"object.displayName is %@", object.displayName);
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        HBXLogNet(@"refresh controller"); 
    });
    
    HBXLogNet(@"refresh controller");
    
    if (controller.fetchedObjects.count) {
        for (XMPPUserCoreDataStorageObject *object in controller.fetchedObjects) {
            NSLog(@"object.displayName is %@", object.displayName);
        }
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    HBXLogNet(@"will change content");
}


#pragma mark - HBXXMPPToolDelegate

- (void)HBXXMPPStreamFriendList:(NSArray *)list {
    
    [self.friendArray removeAllObjects];
    
    for (DDXMLElement *element in list) {
        NSString *desc = [[element attributeForName:@"subscription"] stringValue];
        if (desc && [desc isEqualToString:@"both"]) {
            NSString *jid = [[element attributeForName:@"jid"] stringValue];
            [self.friendArray addObject:jid];
        }
    }
    if (self.friendArray.count) {
        [self.tableView reloadData];
    }

}

#pragma mark -privateSelector

- (void)setRightBarBtn {
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"添加"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(addNewFriendClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

- (void)addNewFriendClick {
    if (self.friendPhoneFiled.text.length != 11) {
        [HBXUtil alertTitle:@"提示" message:@"请输入电话号码"];
        return;
    }
    
    if (![HBXUtil isTelphoneNum:self.friendPhoneFiled.text]) {
         [HBXUtil alertTitle:@"提示" message:@"请输入正确的电话号码电话号码"];
        return;
    }
    
    // 不能添加自己
    if([self.friendPhoneFiled.text isEqualToString:[[HBXMisManager instance] getAccoutName]]){
        [HBXUtil alertTitle:@"提示" message:@"不能添加自己"];
        return;
    }
    
    NSString *friengJid = USER_NAME(self.friendPhoneFiled.text);
    
    XMPPJID *jid = [XMPPJID jidWithString:friengJid];
    
    [[HBXXMPPTool instance] addFriend:jid];
    
}

#pragma mark -table
#pragma mark -tableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HBXChatViewController *chatVC = [[HBXChatViewController alloc] init];
    chatVC.userName = self.friendArray[indexPath.row];
    [self.navigationController pushViewController:chatVC animated:YES];
    
}

#pragma mark -datasoruce

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.friendArray.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *contactsCell = @"contactsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactsCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:contactsCell];
    }
    
    cell.textLabel.text = self.friendArray[indexPath.row];
    
    return cell;
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (NSMutableArray *)friendArray {
    if (!_friendArray) {
        _friendArray = [[NSMutableArray alloc] init];
    }
    return _friendArray;
}

- (UITextField *)friendPhoneFiled {
    if (_friendPhoneFiled) {
        _friendPhoneFiled = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
        _friendPhoneFiled.keyboardType = UIKeyboardTypePhonePad;
        _friendPhoneFiled.placeholder = @"请输入要添加的电话号码";
    }
    return _friendPhoneFiled;
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
