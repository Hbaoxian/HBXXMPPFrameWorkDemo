//
//  AppDelegate.m
//  XMPPStreamDemo
//
//  Created by 黄保贤 on 2017/7/11.
//  Copyright © 2017年 黄保贤. All rights reserved.
//

#import "AppDelegate.h"
#import "HBXIMFirstViewController.h"
#import "HBXXMPPTool.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [HBXXMPPTool instance];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    HBXLoginViewController *vc = [[HBXLoginViewController alloc] init];
    
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window.rootViewController = naVC;
    
    [self.window makeKeyAndVisible];
    
    // Override point for customization after application launch.
    return YES;
}





- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -登陆成功之后切换contoller

- (void)handleMainViewController {

    self.window.rootViewController = nil;
    
    HBXIMFirstViewController *vc = [[HBXIMFirstViewController alloc] init];
    
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:vc];
    
   
    HBXContactsViewController *vc2 = [[HBXContactsViewController alloc] init];
    
    UINavigationController *naVC2 = [[UINavigationController alloc] initWithRootViewController:vc2];

    
    HBXFoundViewController *vc3 = [[HBXFoundViewController alloc] init];
    
    UINavigationController *naVC3 = [[UINavigationController alloc] initWithRootViewController:vc3];

    
    
    HBXUserCenterViewController *vc4 = [[HBXUserCenterViewController alloc] init];
    
    UINavigationController *naVC4 = [[UINavigationController alloc] initWithRootViewController:vc4];

    
    
    UITabBarController *tabVC = [[UITabBarController alloc] init];
    tabVC.viewControllers = @[naVC,naVC2,naVC3,naVC4];
    
     self.window.rootViewController = tabVC;
}




@end
;
