//
//  DetailsInfoSetting.m
//  IpaExporter
//
//  Created by 何遵祖 on 2016/10/31.
//  Copyright © 2016年 何遵祖. All rights reserved.
//

#import "DetailsInfoSetting.h"

@implementation DetailsInfoSetting

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)checkContent
{
    return NO;
}

- (IBAction)sureBtnClickFuncion:(id)sender
{
    NSString* appName = _appName.stringValue;
    NSString* appID = _appID.stringValue;
    NSString* codeSignIdentity = _codeSignIdentity.stringValue;
    NSString* provisioning = _provisioningProfile.stringValue;
    NSString* platform = _platform.stringValue;
    
    DetailsInfoData* info = [[DetailsInfoData alloc] initWithAppName:appName
                                                               appID:appID
                                                    codeSignIdentity:codeSignIdentity provisioningProfile:provisioning platformName:platform
                                                          frameworks:nil];
    
    [[EventManager instance] send:EventDetailsInfoSettingClose
                         withData:info];
    
    [self dismissViewController:self];
}

- (IBAction)cancelBtnClickFunction:(id)sender
{
    [self dismissViewController:self];
}

@end
