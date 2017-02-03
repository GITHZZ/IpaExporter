//
//  DataCSCodeEdit.m
//  IpaExporter
//
//  Created by 何遵祖 on 2016/10/11.
//  Copyright © 2016年 何遵祖. All rights reserved.
//

#import "BaseDataCSCodeEdit.h"

@implementation BaseDataCSCodeEdit

- (void)start:(NSString*)dstPath withPackInfo:(DetailsInfoData*)info
{    
}

- (BOOL)initWithPath:(NSString*)path
{
    _path = path;
        
    NSError* error;
    _content = [NSMutableString stringWithContentsOfFile:path
                                                encoding:NSUTF8StringEncoding
                                                   error:&error];
    if(error != nil)
    {
        NSLog(@"%@", error);
        NSLog(@"%@", [error userInfo]);
        return NO;
    }
        
    _lines = [_content componentsSeparatedByString:@"\n"];
    
    return YES;
}

- (void)replaceContent:(NSString*) newContent
{
    NSError* error;
    [newContent writeToFile:_path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(error != nil)
    {
        NSLog(@"%@", error);
        NSLog(@"%@", [error userInfo]);
    }
}

@end
