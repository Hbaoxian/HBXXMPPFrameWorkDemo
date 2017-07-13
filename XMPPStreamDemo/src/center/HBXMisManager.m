//
//  HBXMisManager.m
//  XMPPStreamDemo
//
//  Created by 黄保贤 on 2017/7/13.
//  Copyright © 2017年 黄保贤. All rights reserved.
//

#import "HBXMisManager.h"

static HBXMisManager *_misManger = nil;


static NSString *HBX_HOST_KEY = @"HBX_HOST_KEY";

@implementation HBXMisManager

+ (HBXMisManager *)instance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _misManger = [[HBXMisManager alloc] init];
    });
    
    return _misManger;
}


- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - 获取Host
- (NSString *)getHost {
    NSString *host = [self getStringValue:HBX_HOST_KEY];
    
    if (host) {
        return host;
    }
    return XMPP_HOST;
}

- (void)setHost:(NSString *)host {
    [self storedata:host key:HBX_HOST_KEY];
}


#pragma mark -- privateSelector

- (void)storedata:(id)objec key:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:objec forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getStringValue:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

- (NSArray *)getArrayValue:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:key];
}

- (NSDictionary *)getNSDictionaryValue:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
}

- (NSObject *)getObject:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)removeObejct:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
