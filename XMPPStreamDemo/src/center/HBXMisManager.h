//
//  HBXMisManager.h
//  XMPPStreamDemo
//
//  Created by 黄保贤 on 2017/7/13.
//  Copyright © 2017年 黄保贤. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBXMisManager : NSObject

+ (HBXMisManager *)instance;


/*
 *  对host删除查找存储
 */
- (NSString *)getHost;
- (void)setHost:(NSString *)host;
- (void)removeHost;


@end
