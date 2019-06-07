//
//  RubyCommand.m
//  IpaExporter
//
//  Created by 4399 on 5/28/19.
//  Copyright © 2019 何遵祖. All rights reserved.
//

#import "RubyCammond.h"
#import "Common.h"
#import "ExportInfoManager.h"
#import "DataResManager.h"
#import "BuilderCSFileEdit.h"

@interface RubyCammond()
{
    BOOL _isExporting;
}
@end

@implementation RubyCammond

- (void)startUp
{
    _isExporting = false;
    [self initEvent];
}

- (void)initEvent
{
    [[EventManager instance] regist:EventViewSureClicked
                               func:@selector(sureBtnClicked:)
                           withData:nil
                               self:self];
}

- (void)sureBtnClicked:(NSNotification*)notification
{
    //导出中不走逻辑
    if(_isExporting)
        return;
    
    _isExporting = true;
    
    [[EventManager instance] send:EventSetExportButtonState withData:s_false];
    [[EventManager instance] send:EventStartRecordTime withData:nil];
    
    showLog("*开始执行打包脚本\n");
    ExportInfoManager* view = [ExportInfoManager instance];
    [[DataResManager instance] start:view.info];
  
    BuilderCSFileEdit* builderEdit = [[BuilderCSFileEdit alloc] init];
    [builderEdit startWithDstPath:[NSString stringWithUTF8String:view.info->unityProjPath]];
    
    //修改xcode工程
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        ExportInfoManager* view = [ExportInfoManager instance];
        NSMutableArray<DetailsInfoData*>* detailArray = view.detailArray;
        
        dispatch_queue_t sq = dispatch_queue_create("exportInfo", DISPATCH_QUEUE_SERIAL);
      
        [self exportXcodeProjInThread:sq];
        
        for(int i = 0; i < [detailArray count]; i++){
            dispatch_sync(sq, ^{
                DetailsInfoData *data = [detailArray objectAtIndex:i];
                [self editXcodeProject:data];
            });
        }
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //全部打包完毕
        _isExporting = false;
        [[EventManager instance] send:EventSetExportButtonState withData:s_true];
        [[EventManager instance] send:EventStopRecordTime withData:nil];
        [[DataResManager instance] end];
        
        showLog("*打包结束");
        showLog("--------------------------------");
    });
}

- (NSString*)writeConfigToJsonFile:(NSString*)platformName withData:(NSMutableDictionary*)jsonData
{
    BOOL isVaild = [NSJSONSerialization isValidJSONObject:jsonData];
    if(!isVaild){
        //showError("json格式有错，请检查");
        //return error code
        return @"";
    }
    
    
    NSString *resourcePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingFormat:@"/%@/", platformName];
    [[NSFileManager defaultManager]createDirectoryAtPath:resourcePath withIntermediateDirectories:YES         attributes:nil error:nil];

    NSString *configPath = [resourcePath stringByAppendingString:@"config.json"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:configPath]){
        [[NSFileManager defaultManager] createFileAtPath:configPath contents:nil attributes:nil];
    }
    
    NSOutputStream *outStream = [[NSOutputStream alloc] initToFileAtPath:configPath append:NO];
    [outStream open];
    
    NSError *error;
    [NSJSONSerialization writeJSONObject:jsonData
                                toStream:outStream
                                 options:NSJSONWritingPrettyPrinted
                                   error:&error];
    
    if(error != nil){
        [outStream close];
        //return error code
        return @"";
    }
    
    [outStream close];
    
    return configPath;
}

- (id)invokingShellScriptAtPath:(NSString*)shellScriptPath withArgs:(NSArray*)args
{
    //设置参数
    NSString *shellArgsStr = [[NSString alloc] init];
    for(int i = 0; i < [args count]; i++)
    shellArgsStr = [shellArgsStr stringByAppendingFormat:@"%@\t", args[i]];
    
    NSTask *shellTask = [[NSTask alloc] init];
    [shellTask setLaunchPath:@"/bin/sh"];
    NSString *shellStr = [NSString stringWithFormat:@"sh %@ %@", shellScriptPath, shellArgsStr];
    
    //-c 表示将后面的内容当成shellcode来执行、
    [shellTask setArguments:[NSArray arrayWithObjects:@"-c", shellStr, nil]];
    
    NSPipe *pipe = [[NSPipe alloc] init];
    [shellTask setStandardOutput:pipe];
    [shellTask launch];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *data = [file readDataToEndOfFile];
    NSString *strReturnFormShell = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"The return content from shell script is: %@",strReturnFormShell);
    
    return strReturnFormShell;
}

- (void)exportXcodeProjInThread:(dispatch_queue_t)sq
{
    NSString *xcodeShellPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Xcodeproj/ExportXcode.sh"];
    ExportInfoManager* view = [ExportInfoManager instance];
    
    dispatch_sync(sq, ^{
        //生成xcode工程
        //$1 unity工程路径
        //showLog("开始生成xcode工程");
        NSArray *args = [NSArray arrayWithObjects:
                         [NSString stringWithUTF8String:view.info->unityProjPath],
                         nil];
        NSString *shellLog = [self invokingShellScriptAtPath:xcodeShellPath withArgs:args];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            showLog([shellLog UTF8String]);
        });
    });
}

- (void)editXcodeProject:(DetailsInfoData*)data
{
    NSString *shellPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Xcodeproj/Main.sh"];
    NSString *rubyMainPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Xcodeproj/Main.rb"];
    
    ExportInfoManager* view = [ExportInfoManager instance];
    
     if(data.isSelected){
        //配置json文件
        NSMutableDictionary *jsonData = [NSMutableDictionary dictionary];
        jsonData[@"frameworks"] = data.frameworkNames;
        jsonData[@"embedFrameworks"] = data.embedFramework;
        jsonData[@"Libs"] = data.libNames;
        jsonData[@"linker_flags"] = data.linkerFlag;
        jsonData[@"enable_bit_code"] = @"NO";
        jsonData[@"develop_signing_identity"] = [NSMutableArray arrayWithObjects:data.debugProfileName, data.debugDevelopTeam, nil];
        jsonData[@"release_signing_identity"] = [NSMutableArray arrayWithObjects:data.releaseProfileName, data.releaseDevelopTeam, nil];
        jsonData[@"product_bundle_identifier"] = data.bundleIdentifier;
        
        NSString *configPath = [self writeConfigToJsonFile:data.platform withData:jsonData];
        
        //$1 ruby入口文件路径
        //$2 sdk资源文件路径
        //$3 导出ipa和xcode工程路径
        //$4 平台名称
        //$5 configPath 配置路径
        //$6 unity工程路径
        //$7 xcode工程名称 目前固定xcodeProj
        //$8 开发者teamid（debug）
        //$9 开发者签名文件名字（debug）
        //$10 开发者teamid（release）
        //$11 开发者签名文件名字（release）
        NSArray *args = [NSArray arrayWithObjects:rubyMainPath,
                         data.customSDKPath,
                         [NSString stringWithUTF8String:view.info->exportFolderParh],
                         data.platform,
                         configPath,
                         [NSString stringWithUTF8String:view.info->unityProjPath],
                         XCODE_PROJ_NAME,
                         data.debugDevelopTeam,
                         data.debugProfileName,
                         data.releaseDevelopTeam,
                         data.releaseProfileName,
                         nil];
        
        NSString *shellLog = [self invokingShellScriptAtPath:shellPath withArgs:args];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            showLog([shellLog UTF8String]);
            showLog([[NSString stringWithFormat:@"%@平台,打包完毕", data.platform] UTF8String]);
        });
    }
}
@end