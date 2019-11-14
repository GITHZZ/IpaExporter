//
//  LogicMain.m
//  IpaExporter
//
//  Created by 4399 on 8/4/19.
//  Copyright © 2019 何遵祖. All rights reserved.
//

#import "LogicManager.h"
#import "NSMutableDictionary+ArraySupport.h"

@implementation LogicManager

+ (instancetype)defaultManager
{
    Class cls = [self class];
    //动态去取属性方法
    id instance = objc_getAssociatedObject(cls, @"instance");
    if(!instance)
    {
        instance = [[self allocWithZone:NULL] init];
        objc_setAssociatedObject(cls, @"instance", instance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return instance;
}

- (void)startUp
{
    _instanceArray =  @[[[CodeTester alloc] init],
                        [[PackCammond alloc] init],
                        [[ExportInfoManager alloc] init],
                        [[UnityAssetManager alloc] init],
                        [[BuilderCSFileEdit alloc] init],
                        [[PreferenceData alloc] init],
                        [[VersionInfo alloc] init]
                        ];
   
    _instanceDict = [NSMutableDictionary dictionaryWithArray:_instanceArray];
    
    for(int i = 0; i < [_instanceArray count]; i++){
        NSObject* item = _instanceArray[i];
        [item initialize];
    }
    
    EVENT_REGIST(EventViewWillAppear, @selector(viewDidAppear));
    EVENT_REGIST(EventViewDidDisappear, @selector(viewDidDisappear));
}

- (id)getInstByClassName:(NSString*)className error:(NSError**)err
{
    err = nil;
    id obj = [_instanceDict objectForKey:className];
    if(obj == nil){
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat: @"%@不存在,请到startUp进行初始化", className]
                                                             forKey:NSLocalizedDescriptionKey];
        *err = [NSError errorWithDomain:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] code:999 userInfo:userInfo];
    }
    
    return obj;
}

- (void)viewDidAppear
{
    for(int i = 0; i < [_instanceArray count]; i++){
        NSObject* item = _instanceArray[i];
        [item updateData];
    }
}

- (void)viewDidDisappear
{
    for(int i = 0; i < [_instanceArray count]; i++){
        NSObject* item = _instanceArray[i];
        [item clear];
    }
}

- (void)applicationDelegateCallBack:(AppDelegateType)tp
                   withNotification:(NSNotification *)notification
{
    switch (tp)
    {
        case ApplicationWillFinishLaunching:
        case ApplicationDidFinishLaunching:
        case ApplicationWillTerminate:
        case ApplicationDidBecomeActive:
        case ApplicationWillResignActive:
        default:
            break;
    }
}

@end
