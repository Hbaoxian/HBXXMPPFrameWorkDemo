//
//  HBXXMPPTool.m
//  XMPPStreamDemo
//
//  Created by 黄保贤 on 2017/7/13.
//  Copyright © 2017年 黄保贤. All rights reserved.
//

#import "HBXXMPPTool.h"
#import <XMPPFramework/XMPPFramework.h>

@interface HBXXMPPTool () <XMPPStreamDelegate, XMPPRosterDelegate>
// 核心流
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) NSString *accountName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSMutableArray *delegateArray;
@property (nonatomic, assign) BOOL isRegister;

// 获取好友的方式一种是手动刷新(有开始有结束)，另一种是别人添加自己为好友成功的回调，无开始结束，所有作为区分
@property (nonatomic, assign) BOOL hashandleRefreshFriend;
@property (nonatomic, strong) NSMutableArray *friendArray;

@end


static HBXXMPPTool *_mainTool = nil;


@implementation HBXXMPPTool


+ (HBXXMPPTool *)instance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mainTool = [[HBXXMPPTool alloc] init];
    });

    return _mainTool;
}

- (instancetype)init {
    
    if (self = [super init]) {
        [self setupStream];
    }
    return self;
}

#pragma mark -- xmppStream init

- (void)setupStream {
    // 创建核心流
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream addDelegate:self delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    // 创建花名册
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    _roster.autoFetchRoster = NO;
    [_roster activate:_xmppStream];
    [_roster addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

    
}


#pragma mark --xmppDelegate
#pragma mark -- 链接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSError *error = nil;
    if (!self.isRegister) {
         [_xmppStream authenticateWithPassword:self.password error:&error];
    }else {
        [_xmppStream registerWithPassword:self.password error:&error];
    }
    if (error) {
        HBXLogNet(@"验证密码失败 %@",error.localizedDescription);
    }
}

#pragma mark -- 登陆通过验证

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    HBXLogNet(@"链接成功");
    HBXLogNet(@"new %@", sender);
    [self goOnLine];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<HBXXMPPToolDelegate> delegate in self.delegateArray) {
            if ([delegate respondsToSelector:@selector(HBXConnectServerSuccess)]) {
                [delegate HBXConnectServerSuccess];
            }
        }
    });
}


#pragma mark -- 新账号注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    HBXLogNet(@"注册成功");
    [self goOnLine];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<HBXXMPPToolDelegate> delegate in self.delegateArray) {
            if ([delegate respondsToSelector:@selector(HBXRegisterServerSuccess)]) {
                [delegate HBXRegisterServerSuccess];
            }
        }
        
    });
}


#pragma mark -- 获取好友列表

- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version {
    self.hashandleRefreshFriend = YES;
    NSLog(@"开始接收");
    HBXLogNet(@"start");
    [self.friendArray removeAllObjects];
}
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
    self.hashandleRefreshFriend = NO;
    HBXLogNet(@"end");
    [self notificationFriendList];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item {
    HBXLogNet(@"1111");
    NSString *desc = [[item attributeForName:@"subscription"] stringValue];
    HBXLogNet(@"jid is %@ subscription  is  %@", [[item attributeForName:@"jid"] stringValue], [[item attributeForName:@"subscription"] stringValue]);
    if ([desc isEqualToString:@"to"]) {
        HBXLogNet(@"jid is %@", [[item attributeForName:@"jid"] stringValue]);
    }
    [_friendArray addObject:item];
    
    if (!self.hashandleRefreshFriend) {
        [self notificationFriendList];
    }
    
}


#pragma mark -- 验证失败

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    HBXLogNet(@"验证失败");
}

#pragma mark -- 接收消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    HBXLogNet(@"message is message.body%@ message.type%@  message.subject%@  message.thread%@  sender.hostName%@ sender.myJID.user%@", message.body,
          message.type,message.subject, message.thread, sender.hostName, sender.myJID.user);
    if (message.body && message.body.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegateArray.count) {
                for (id<HBXXMPPToolDelegate> delegate in self.delegateArray) {
                    [delegate respondsToSelector:@selector(HBXXMPPStream:didReceiveMessage:)];
                    [delegate HBXXMPPStream:sender didReceiveMessage:message];
                }
            }
        });
    }
}

#pragma mark -- 接收添加好友的请求

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    
    NSString *jid = [presence.from user];
    HBXLogNet(@"有新朋友添加你为好友了 %@",jid);
    if ([presence.type isEqualToString:@"subscribe"]) {
        [_roster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
    }
    
}




#pragma mark - HBXXMPPDeleagte管理

- (void)addDelegate:(id)deleagte {
    if (![self.delegateArray containsObject:deleagte]) {
        [self.delegateArray addObject:deleagte];
    }
}

- (void)removeDelegate:(id)delegate {
    if ([self.delegateArray containsObject:delegate]) {
        [self.delegateArray removeObject:delegate];
    }
}


#pragma mark - 连接xmpp

- (void)connect {
    self.isRegister = NO;
    // 设置用户名， 密码
    NSString *userName = @"shuzhen";
    self.password = @"123456";
    [_xmppStream setMyJID:[XMPPJID jidWithString:USER_NAME(userName)]];
    [_xmppStream setHostName:[self getHost]];
    
    NSError *error = nil;
    
    [_xmppStream connectWithTimeout:10 error:&error];
    
    if (error) {
        HBXLogNet(@"默认账号连接错误 %@",error.localizedDescription);
    }
}

- (void)connect:(NSString *)userName passWord:(NSString *)password {
    self.isRegister = NO;
    self.accountName = userName;
    self.password = password;
    [_xmppStream setMyJID:[XMPPJID jidWithString:USER_NAME(self.accountName)]];
    [_xmppStream setHostName:[self getHost]];
    NSError *error = nil;
    [_xmppStream connectWithTimeout:10 error:&error];
    if (error) {
        HBXLogNet(@"输入账号连接错误 %@",error.localizedDescription);
    }
}

- (void)registerConnect:(NSString *)userName password:(NSString *)password {
    self.isRegister = YES;
    self.accountName = userName;
    self.password = password;
    [_xmppStream setMyJID:[XMPPJID jidWithString:USER_NAME(self.accountName)]];
    [_xmppStream setHostName:[self getHost]];
    NSError *error = nil;
    [_xmppStream connectWithTimeout:10 error:&error];
    if (error) {
        HBXLogNet(@"注册账号连接错误 %@",error.localizedDescription);
    }

}

#pragma mark -- 断开连接

- (void)disConnect {
    [self goOnLine];
    [_xmppStream disconnect];
}

- (void)goOnLine {
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
}

- (void)goOffline {
    XMPPPresence * presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
}

#pragma mark -- gethost

- (NSString *)getHost {
    return [[HBXMisManager instance] getHost];
}

#pragma mark -getFriendsSelector 

- (void)fetchFriends {
    [_roster fetchRoster];
    NSLog(@"self.rosterStorage.storeOptions.count is %zd",self.rosterStorage.storeOptions.count);
}


#pragma mark - 触发添加好友逻辑

- (void)addFriend:(XMPPJID *)jid {
    
    if ([_rosterStorage userExistsWithJID:jid xmppStream:_xmppStream]) {
        [HBXUtil alertTitle:@"提示" message:@"您添加的好友已经存在"];
        return;
    }
    
    [_roster subscribePresenceToUser:jid];
}


#pragma mark - 逻辑处理方法
// 广播刷新好友
- (void)notificationFriendList {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<HBXXMPPToolDelegate> delegate in self.delegateArray) {
            if ([delegate respondsToSelector:@selector(HBXXMPPStreamFriendList:)]) {
                [delegate HBXXMPPStreamFriendList:self.friendArray];
            }
        }
    });
}




#pragma mark - 获取当前登录名
- (NSString *)getMyJid {
    return USER_NAME(self.accountName);
}


#pragma mark -- getter

- (NSMutableArray *)delegateArray {
    if (!_delegateArray) {
        _delegateArray = [[NSMutableArray alloc] init];
    }
    return _delegateArray;
}

- (NSMutableArray *)friendArray {
    if (!_friendArray) {
        _friendArray = [[NSMutableArray alloc] init];
    }
    return _friendArray;
}



@end
