//
//  ExportInfoManager.m
//  IpaExporter
//
//  Created by 何遵祖 on 2016/9/28.
//  Copyright © 2016年 何遵祖. All rights reserved.
//

#import "ExportInfoManager.h"
#import <objc/runtime.h>

@implementation ExportInfoManager

- (void)dealloc
{
    free(_info);
}

- (id)init
{
    if(self =[super init])
    {
        _info = (ExportInfo*)malloc(sizeof(ExportInfo)); 
        _info->exportFolderParh = "";
        _info->unityProjPath = "";
        
        _unityProjPathArr = [[NSMutableArray alloc] initWithCapacity:6];
        _exportPathArr = [[NSMutableArray alloc] initWithCapacity:6];
        _codeBackupPath = @"";
        
        _saveTpDict = @{
                       SAVE_DETAIL_ARRARY_KEY:@[[NSMutableArray class],[DetailsInfoData class], [NSMutableDictionary class]],
                       SAVE_PROJECT_PATH_KEY:@[[NSArray class]],
                       SAVE_EXPORT_PATH_KEY:@[[NSArray class]],
                       SAVE_CODE_SAVE_PATH_KEY:@[[NSString class]],
                       SAVE_SCENE_ARRAY_KEY:@[[NSArray class]]
                       };
        
        _userData = [[LocalDataSave alloc] init];
        [_userData setAllSaveKey:_saveTpDict];
    }
    return self;
}

//如果传nil值 代表全部存储
- (void)saveAll
{
    [self saveDataForKey:nil];
}

- (void)saveDataForKey:(nullable NSString*)key
{
    [_userData saveDataForKey:key];
}

- (void)reloadPaths
{
    _unityProjPathArr = [_userData dataForKey:SAVE_PROJECT_PATH_KEY];
    _exportPathArr = [_userData dataForKey:SAVE_EXPORT_PATH_KEY];
    _codeBackupPath = [_userData dataForKey:SAVE_CODE_SAVE_PATH_KEY];
}

- (void)addNewUnityProjPath:(NSString *)path
{
    NSAssert(path != nil, @"路径不能为空");
    [_unityProjPathArr addObject:path];
    
    if([_unityProjPathArr count] > 5)
    {
        [_unityProjPathArr removeObjectAtIndex:0];
    }
}

- (void)replaceUnityProjPath:(NSString*)path
{
    NSUInteger index = [_unityProjPathArr indexOfObject:path];
    id lastObj = [_unityProjPathArr lastObject];
    [_unityProjPathArr replaceObjectAtIndex:[_unityProjPathArr count] - 1 withObject:path];
    [_unityProjPathArr replaceObjectAtIndex:index withObject:lastObj];
}

- (void)addNewExportProjPath:(NSString *)path
{
    NSAssert(path != nil, @"路径不能为空");
    [_exportPathArr addObject:path];
    
    if([_exportPathArr count] > 5)
    {
        [_exportPathArr removeLastObject];
    }
}

- (void)replaceExportProjPath:(NSString*)path
{
    NSUInteger index = [_exportPathArr indexOfObject:path];
    id fristObj = [_exportPathArr objectAtIndex:0];
    [_exportPathArr replaceObjectAtIndex:0 withObject:path];
    [_exportPathArr replaceObjectAtIndex:index withObject:fristObj];
}

//包配置 信息表格数据部分
- (NSMutableArray*)reLoadDetails:(NSString*)saveKey
{
    return [_userData dataForKey:saveKey];
}

- (void)addDetail:(id)data withKey:(NSString*)saveKey
{
    NSMutableArray *array = [_userData dataForKey:saveKey];
    [array addObject:data];
    [_userData setDataForKey:saveKey withData:array];
    [self saveDataForKey:saveKey];
}

- (void)removeDetail:(NSUInteger)index withKey:(NSString*)saveKey
{
    NSMutableArray *array = [_userData dataForKey:saveKey];
    if([array count] > 0){
        [array removeObjectAtIndex:index];
        [self saveDataForKey:saveKey];
    }
}

- (void)updateDetail:(NSUInteger)index withObject:(id)object withKey:(NSString*)saveKey
{
    NSMutableArray *array = [_userData dataForKey:saveKey];
    [array replaceObjectAtIndex:index withObject:object];
    [_userData setDataForKey:saveKey withData:array];
    [self saveDataForKey:saveKey];
}

- (void)setCodeSavePath:(NSString*)path
{
    _codeBackupPath = path;
}

- (NSMutableArray*)getDetailArray
{
    return [_userData dataForKey:SAVE_DETAIL_ARRARY_KEY];
}

- (NSMutableArray*)getSceneArray
{
    return [_userData dataForKey:SAVE_SCENE_ARRAY_KEY];
}

- (NSString*)getCodeSavePath
{
    return [_userData dataForKey:SAVE_CODE_SAVE_PATH_KEY];
}

@end