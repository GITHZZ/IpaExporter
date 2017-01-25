//
//  DetailsInfoData.h
//  IpaExporter
//
//  Created by 何遵祖 on 2016/11/3.
//  Copyright © 2016年 何遵祖. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Platform_Name @"platform"
#define App_Name_Key @"appName"
#define App_ID_Key @"bundleIdentifier"
#define Code_Sign_Identity_Key @"codeSignIdentity"
#define Provisioning_Profile_key @"provisioningProfile"
#define Frameworks_Key @"frameworks"
#define libs_Key @"libs"
#define Libker_Flag @"libkerFlag"

@interface DetailsInfoData : NSObject<NSCoding>

@property(nonatomic, readonly) NSString* platform;
@property(nonatomic, readonly) NSString* appName;
@property(nonatomic, readonly) NSString* bundleIdentifier;
@property(nonatomic, readonly) NSString* codeSignIdentity;
@property(nonatomic, readonly) NSString* provisioningProfile;

-(void)setInfoWithAppName:(NSString*)appName
                    appID:(NSString*)appID
         codeSignIdentity:(NSString*)codeS
      provisioningProfile:(NSString*)profile
             platformName:(NSString*)platform;

@end
