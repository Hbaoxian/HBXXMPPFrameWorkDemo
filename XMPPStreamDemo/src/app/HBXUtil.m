//
//  HBXUtil.m
//  XMPPStreamDemo
//
//  Created by 黄保贤 on 2017/7/13.
//  Copyright © 2017年 黄保贤. All rights reserved.
//

#import "HBXUtil.h"

@implementation HBXUtil

+ (void)alertTitle:(NSString *)tile message:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:tile message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
}

+ (UIImage *)getImage:(NSString *)imageName  {
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return image;
}

+ (BOOL)isTelphoneNum:(NSString *)text {
    
    NSString *telRegex = @"^1[3578]\\d{9}$";
    NSPredicate *prediate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", telRegex];
    return [prediate evaluateWithObject:text];
}


@end
