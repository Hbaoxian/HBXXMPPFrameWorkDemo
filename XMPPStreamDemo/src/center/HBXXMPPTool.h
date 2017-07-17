//
//  HBXXMPPTool.h
//  XMPPStreamDemo
//
//  Created by 黄保贤 on 2017/7/13.
//  Copyright © 2017年 黄保贤. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPMessage;
@class XMPPStream;
@class XMPPRoster;
@class XMPPRosterCoreDataStorage;
@class XMPPJID;



@protocol HBXXMPPToolDelegate <NSObject>

@optional

/*
 * 获取服务消息回调
 */
- (void)HBXXMPPStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message;

/*
 * 登陆成功回调
 */
- (void)HBXConnectServerSuccess;

/*
 * 注册成回调
 **/
- (void)HBXRegisterServerSuccess;

/*
 * 获取好友列表
 * 数组存储 DDXMLElement 元素
 */
- (void)HBXXMPPStreamFriendList:(NSArray *)list;


/*
 *  有新朋友添加你为好友了
 */






@end


@interface HBXXMPPTool : NSObject

// 花名册模块
@property (nonatomic, strong, readonly) XMPPRoster *roster;
// 花名册数据存储
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *rosterStorage;

+ (HBXXMPPTool *)instance;


- (void)addDelegate:(id<HBXXMPPToolDelegate>)deleagte;
- (void)removeDelegate:(id)delegate;
- (void)connect:(NSString *)userName passWord:(NSString *)password;
- (void)registerConnect:(NSString *)userName password:(NSString *)password;
- (void)connect;
- (NSString *)getMyJid;
- (void)fetchFriends;
- (void)addFriend:(XMPPJID *)jid;




@end
