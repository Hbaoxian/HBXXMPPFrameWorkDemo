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


@protocol HBXXMPPToolDelegate <NSObject>

@optional
- (void)HBXXMPPStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message;
- (void)HBXConnectServerSuccess;

@end


@interface HBXXMPPTool : NSObject

+ (HBXXMPPTool *)instance;


- (void)addDelegate:(id<HBXXMPPToolDelegate>)deleagte;
- (void)removeDelegate:(id)delegate;
- (void)connect:(NSString *)userName passWord:(NSString *)password;
- (void)connect;

@end
