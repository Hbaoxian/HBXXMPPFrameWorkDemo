//
//  HBXLoginViewController.m
//  XMPPStreamDemo
//
//  Created by 黄保贤 on 2017/7/13.
//  Copyright © 2017年 黄保贤. All rights reserved.
//

#import "HBXLoginViewController.h"

@interface HBXLoginViewController () <HBXXMPPToolDelegate>
@property (weak, nonatomic) IBOutlet UITextField *AccountTextfiled;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextfiled;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *registBtn;
- (IBAction)loginClick:(id)sender;
- (IBAction)registerClick:(id)sender;

@end

@implementation HBXLoginViewController


- (void)awakeFromNib {
    [super awakeFromNib];
    self.registBtn.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.AccountTextfiled.text = [[HBXMisManager instance] getAccoutName];
    self.passWordTextfiled.text = [[HBXMisManager instance] getPassword];
    
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[HBXXMPPTool instance] addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[HBXXMPPTool instance] removeDelegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark --HBXXMPPDELEGATe

- (void)HBXConnectServerSuccess {
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate handleMainViewController];
    
    [[HBXMisManager instance] setAccount:self.AccountTextfiled.text];
    [[HBXMisManager instance] setPassword:self.passWordTextfiled.text];
    
}

- (void)HBXRegisterServerSuccess {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate handleMainViewController];
    
    [[HBXMisManager instance] setAccount:self.AccountTextfiled.text];
    [[HBXMisManager instance] setPassword:self.passWordTextfiled.text];

}


#pragma mark -- loginAction

- (IBAction)loginClick:(id)sender {
    
    [self.view endEditing:NO];
    
    if (!self.AccountTextfiled.text.length) {
        [HBXUtil alertTitle:@"提示" message:@"请输入账号"];
    }
    
    if (!self.passWordTextfiled.text.length) {
         [HBXUtil alertTitle:@"提示" message:@"请输入密码"];
    }
    
    [[HBXXMPPTool instance] connect:self.AccountTextfiled.text
                           passWord:self.passWordTextfiled.text];
    
}


#pragma mark registerAction

- (IBAction)registerClick:(id)sender {
    [self.view endEditing:NO];
    
    if (!self.AccountTextfiled.text.length) {
        [HBXUtil alertTitle:@"提示" message:@"请输入账号"];
    }
    
    if (!self.passWordTextfiled.text.length) {
        [HBXUtil alertTitle:@"提示" message:@"请输入密码"];
    }
    
    [[HBXXMPPTool instance] registerConnect:self.AccountTextfiled.text
                                   password:self.passWordTextfiled.text];
   
    
    
}


@end
