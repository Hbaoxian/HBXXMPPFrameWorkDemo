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

@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) NSString *accountName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSMutableArray *delegateArray;

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
    self.xmppStream = [[XMPPStream alloc] init];
    [_xmppStream addDelegate:self delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}


#pragma mark --xmppDelegate
#pragma mark -- 链接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSError *error = nil;
    [_xmppStream authenticateWithPassword:self.password error:&error];
    if (error) {
        NSLog(@"验证密码失败 %@",error.localizedDescription);
    }
}

#pragma mark -- 通过验证

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"链接成功");
    [self goOnLine];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<HBXXMPPToolDelegate> delegate in self.delegateArray) {
            if ([delegate respondsToSelector:@selector(HBXConnectServerSuccess)]) {
                [delegate HBXConnectServerSuccess];
            }
        }
    });
}

#pragma mark -- 验证失败

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"验证失败");
}



#pragma mark -- 接收消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"message is message.body%@ message.type%@  message.subject%@  message.thread%@  sender.hostName%@ sender.myJID.user%@", message.body,
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

#pragma mark -- HBXXMPPDeleagte管理

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


#pragma mark -- 连接xmpp

- (void)connect {
    
    // 设置用户名， 密码
    NSString *userName = @"shuzhen";
    self.password = @"123456";
    [_xmppStream setMyJID:[XMPPJID jidWithString:USER_NAME(userName)]];
    [_xmppStream setHostName:[self getHost]];
    
    NSError *error = nil;
    
    [_xmppStream connectWithTimeout:10 error:&error];
    
    if (error) {
        NSLog(@"连接错误 %@",error.localizedDescription);
    }
}

- (void)connect:(NSString *)userName passWord:(NSString *)password {
    self.accountName = userName;
    self.password = password;
    
    [_xmppStream setMyJID:[XMPPJID jidWithString:USER_NAME(self.accountName)]];
    [_xmppStream setHostName:[self getHost]];
    NSError *error = nil;
    [_xmppStream connectWithTimeout:10 error:&error];
    if (error) {
        NSLog(@"连接错误 %@",error.localizedDescription);
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


#pragma mark -- getter

- (NSMutableArray *)delegateArray {
    if (!_delegateArray) {
        _delegateArray = [[NSMutableArray alloc] init];
    }
    return _delegateArray;
}


@end
