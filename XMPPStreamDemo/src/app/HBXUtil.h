//
//  HBXUtil.h
//  XMPPStreamDemo
//
//  Created by 黄保贤 on 2017/7/13.
//  Copyright © 2017年 黄保贤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HBXUtil : NSObject

+ (void)alertTitle:(NSString *)tile message:(NSString *)message;

+ (UIImage *)getImage:(NSString *)imageName;
//正则匹配电话好拿
+ (BOOL)isTelphoneNum:(NSString *)text;

@end
