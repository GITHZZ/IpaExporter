//
//  CustomLog.m
//  IpaExporter
//
//  Created by 何遵祖 on 2017/2/17.
//  Copyright © 2017年 何遵祖. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventManager.h"
#import "Defs.h"

void showLog(const char* content, ...)
{
    va_list ap;
    va_start(ap, content);
    NSString* contentStr = [NSString stringWithUTF8String:content];
    NSString* showStr =  [[NSString alloc] initWithFormat:contentStr arguments:ap];
    va_end(ap);
    [[EventManager instance] send:EventAddNewInfoContent withData:showStr];
}

void showError(const char* content, ...)
{
    va_list ap;
    va_start(ap, content);
    NSString* contentStr = [NSString stringWithUTF8String:content];
    NSString* showStr =  [[NSString alloc] initWithFormat:contentStr arguments:ap];
    va_end(ap);
    [[EventManager instance] send:EventAddErrorContent withData:showStr];
}

void showSuccess(const char* content, ...)
{
    va_list ap;
    va_start(ap, content);
    NSString* contentStr = [NSString stringWithUTF8String:content];
    NSString* showStr = [[NSString alloc] initWithFormat:contentStr arguments:ap];
    va_end(ap);
    [[EventManager instance] send:EventAddNewSuccessContent withData:showStr];
}

void lua_show_log(const char *s)
{
    showLog("*Lua:%@", [NSString stringWithUTF8String:s]);
}

void lua_show_error(const char *s)
{
    showError("*Lua:%s", s);
}
