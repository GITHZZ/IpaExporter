//
//  GeneralView.m
//  IpaExporter
//
//  Created by 何遵祖 on 2016/9/1.
//  Copyright © 2016年 何遵祖. All rights reserved.
//

#import "GeneralView.h"
#import "DetailsInfoView.h"
#import "DetailsInfoData.h"
#import "ExportInfoManager.h"
#import "Common.h"
#import "PreferenceView.h"
#import "PreferenceData.h"
#import "ExportInfoManager.h"

#define PlatformTblKey @"platformTbl"
#define PackSceneKey   @"packScene"

@implementation GeneralView

- (void)viewDidLoad
{
    //设置数据源
    _platformTbl.delegate = self;
    _packSceneTbl.delegate = self;
    _platformTbl.dataSource = self;
    _packSceneTbl.dataSource = self;
    _packSceneTbl.enabled = NO;
    
    _unityPathBox.delegate = self;
    _exportPathBox.delegate = self;

    _progressTip.displayedWhenStopped = NO;
    
    _manager = (ExportInfoManager*)get_instance(@"ExportInfoManager");
    [_manager reloadPaths];
    
    ExportInfo* info = _manager.info;
    NSMutableArray* unityProjPathArr = _manager.unityProjPathArr;
    NSMutableArray* exportPathArr = _manager.exportPathArr;
    
    if ([unityProjPathArr count] > 0)
    {
        _unityPathBox.stringValue = (NSString*)[unityProjPathArr lastObject];
        info->unityProjPath = [_unityPathBox.stringValue UTF8String];
        [_unityPathBox addItemsWithObjectValues:unityProjPathArr];
    }
    
    if ([exportPathArr count] > 0)
    {
        _exportPathBox.stringValue = (NSString*)[exportPathArr lastObject];
        info->exportFolderParh = [_exportPathBox.stringValue UTF8String];
        [_exportPathBox addItemsWithObjectValues:exportPathArr];
    }
    
    _isReleaseBox.state = info->isRelease;
    _isExportXcode.state = info->isExportXcode;
    _isExportIpa.state = info->isExportIpa;
    
    _useTimeLabel.stringValue = @"";
    
    EVENT_REGIST(EventStopRecordTime, @selector(stopShowPackTime:));
    EVENT_SEND(EventGeneralViewLoaded, nil);
}

- (void)viewDidAppear
{
    _isVisable = YES;
    
    //从本地读取存储数据
    ExportInfoManager* view = (ExportInfoManager*)get_instance(@"ExportInfoManager");
    NSMutableArray<DetailsInfoData*> *saveArray = [view reLoadDetails:SAVE_DETAIL_ARRARY_KEY];
    _dataDict = [[NSMutableArray alloc] initWithArray:saveArray];
    
    NSMutableArray<NSString*> *saveSceneArr = [view reLoadDetails:SAVE_SCENE_ARRAY_KEY];
    _sceneArray = [[NSMutableArray alloc] initWithArray:saveSceneArr];

    [_platformTbl reloadData];
    [_packSceneTbl reloadData];
    
    [self registEvent];
}

- (void)viewDidDisappear
{
    _isVisable = NO;
    [self unRegistEvent];
}

- (void)registEvent
{
    EVENT_REGIST(EventDetailsInfoUpdate, @selector(detailsInfoDictUpdate:));
    EVENT_REGIST(EventAddNewInfoContent, @selector(addNewInfoContent:));
    EVENT_REGIST(EventAddNewSuccessContent, @selector(addNewSuccessContent:));
    EVENT_REGIST(EventAddNewWarningContent, @selector(addNewWarningContent:));
    EVENT_REGIST(EventAddErrorContent, @selector(addNewErrorContent:));
    EVENT_REGIST(EventSetExportButtonState, @selector(setExportBtnState:));
    EVENT_REGIST(EventStartRecordTime, @selector(startShowPackTime:));
    EVENT_REGIST(EventCleanInfoContent, @selector(cleanInfoContent:));
    EVENT_REGIST(EventSettingFileSelect, @selector(reloadAllInfo));
    EVENT_REGIST(EventOnMenuSelect, @selector(onMenuSelect:));
    EVENT_REGIST(EventSelectSceneClicked, @selector(selectSceneClicked:));
}

- (void)unRegistEvent
{
    EVENT_UNREGIST(EventDetailsInfoUpdate);
    EVENT_UNREGIST(EventAddNewInfoContent);
    EVENT_UNREGIST(EventAddNewSuccessContent);
    EVENT_UNREGIST(EventAddNewWarningContent);
    EVENT_UNREGIST(EventAddErrorContent);
    EVENT_UNREGIST(EventSetExportButtonState);
    EVENT_UNREGIST(EventStartRecordTime);
    EVENT_UNREGIST(EventCleanInfoContent);
    EVENT_UNREGIST(EventSettingFileSelect);
    EVENT_UNREGIST(EventOnMenuSelect);
    EVENT_UNREGIST(EventSelectSceneClicked);

}

- (void)reloadAllInfo
{
    [_unityPathBox removeAllItems];
    [_exportPathBox removeAllItems];
    
    ExportInfoManager* view = (ExportInfoManager*)get_instance(@"ExportInfoManager");
    [view reload];
    
    ExportInfo* info = view.info;
    NSMutableArray* unityProjPathArr = view.unityProjPathArr;
    NSMutableArray* exportPathArr = view.exportPathArr;
    
    if ([unityProjPathArr count] > 0)
    {
        _unityPathBox.stringValue = (NSString*)[unityProjPathArr lastObject];
        info->unityProjPath = [_unityPathBox.stringValue UTF8String];
        [_unityPathBox addItemsWithObjectValues:unityProjPathArr];
    }
    
    if ([exportPathArr count] > 0)
    {
        _exportPathBox.stringValue = (NSString*)[exportPathArr lastObject];
        info->exportFolderParh = [_exportPathBox.stringValue UTF8String];
        [_exportPathBox addItemsWithObjectValues:exportPathArr];
    }
    
    _isReleaseBox.state = info->isRelease;
    _isExportXcode.state = info->isExportXcode;
    
    NSMutableArray<DetailsInfoData*> *saveArray = [_manager reLoadDetails:SAVE_DETAIL_ARRARY_KEY];
    _dataDict = [[NSMutableArray alloc] initWithArray:saveArray];
    
    NSMutableArray<NSString*> *saveSceneArr = [_manager reLoadDetails:SAVE_SCENE_ARRAY_KEY];
    _sceneArray = [[NSMutableArray alloc] initWithArray:saveSceneArr];
    
    [_platformTbl reloadData];
    [_packSceneTbl reloadData];
    
    inst_method_call(@"PreferenceData", restoreCustomCode);
}

- (IBAction)sureBtnClick:(id)sender
{
    EVENT_SEND(EventViewSureClicked, sender);
}

- (void)openFolderSelectDialog:(EventType)et
               IsCanSelectFile:(BOOL)chooseFile
        IsCanSelectDirectories:(BOOL)chooseDirectories
                    identifier:(NSString*)identifier
{
    NSString *unityProjPath = [NSString stringWithUTF8String:_manager.info->unityProjPath];
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setDelegate:self];
    [openDlg setIdentifier:identifier];
    [openDlg setCanChooseFiles:chooseFile];
    [openDlg setCanChooseDirectories:chooseDirectories];
    [openDlg setDirectoryURL:[NSURL URLWithString:unityProjPath]];
    
    ExportInfo* tInfo = _manager.info;
    
    if ([openDlg runModal] == NSModalResponseOK)
    {
        for(NSURL* url in [openDlg URLs])
        {
            NSString* selectPath = [url path];
            
            switch (et)
            {
                case EventUnityPathSelectEnd:
                    tInfo->unityProjPath = [selectPath UTF8String];
                    _manager.info = tInfo;
                    if([_manager addNewUnityProjPath:selectPath])
                        _unityPathBox.stringValue = selectPath;

                    break;
                case EventExportPathSelectEnd:
                    tInfo->exportFolderParh = [selectPath UTF8String];
                    _manager.info = tInfo;
                    if([_manager addNewExportProjPath:selectPath])
                       _exportPathBox.stringValue = selectPath;
                    
                    break;
                case EventScenePathSelectEnd:
                    [self addNewScenePath:selectPath];
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)addNewScenePath:(NSString*)path
{
    NSString *unityProjPath = [NSString stringWithUTF8String:_manager.info->unityProjPath];
    if(![path hasSuffix:@"unity"]){
        showError("[加入新打包场景失败]：选择场景文件必须为unity后缀文件");
        return;
    }
    
    if(![path hasPrefix:unityProjPath]){
        showError("[加入新打包场景失败]：选择场景文件必须在unity工程下选择");
        return;
    }
    
    [_sceneArray addObject:path];
    [_manager addDetail:path withKey:SAVE_SCENE_ARRAY_KEY];
    [_packSceneTbl reloadData];
}

- (IBAction)unityPathSelect:(id)sender
{
    [self openFolderSelectDialog:EventUnityPathSelectEnd
                 IsCanSelectFile:NO
          IsCanSelectDirectories:YES
                      identifier:@"unityPath"];
}

- (IBAction)exportPathSelect:(id)sender
{
    [self openFolderSelectDialog:EventExportPathSelectEnd
                 IsCanSelectFile:NO
          IsCanSelectDirectories:YES
                      identifier:@"exportPath"];
}

- (void)selectSceneClicked:(NSNotification*)notification
{
    NSArray *sceneArr = [_manager getSceneArray];
    for (int i = (int)[sceneArr count] - 1; i >= 0 ; i--) {
        [_sceneArray removeObjectAtIndex:i];
        [_manager removeDetail:i withKey:SAVE_SCENE_ARRAY_KEY];
    }
    
    NSArray *selectScene = (NSArray*)notification.object;
    for (NSString *path in selectScene) {
        [self addNewScenePath:path];
    }
}

- (IBAction)scenePathSelect:(id)sender
{
    if(strlen(_manager.info->unityProjPath) == 0){
        showError("请选择工程路径");
        return;
    }
    
    EVENT_SEND(EventShowSubView, @"SceneSelectView");
}

- (IBAction)removeScenePath:(id)sender
{
    NSInteger row = [_packSceneTbl selectedRow];
    if([_sceneArray count] > 0){
        [_sceneArray removeObjectAtIndex:row];
    }
    [_manager removeDetail:row withKey:SAVE_SCENE_ARRAY_KEY];
    [_packSceneTbl reloadData];
}

- (void)detailsInfoDictUpdate:(NSNotification*)notification
{
    NSMutableArray* dict = (NSMutableArray*)[notification object];
    _dataDict = dict;
    [_platformTbl reloadData];
}

//返回表格的行数
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if([tableView.identifier isEqualToString:PlatformTblKey]){
        return [_dataDict count];
    }
    else if([tableView.identifier isEqualToString:PackSceneKey]){
        return [_sceneArray count];
    }
    return 0;
}

//初始化新行内容
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *columnIdentifier=[tableColumn identifier];
    if(columnIdentifier == nil)
    {
        NSLog(@"存在没有设置Identifier属性");
        return nil;
    }
    
    id itemCell;
    if([tableView.identifier isEqualToString:PlatformTblKey]){
        DetailsInfoData *info = [_dataDict objectAtIndex:row];
        NSString* title = [NSString stringWithFormat:@"%@(%@)", info.appName, info.platform];
        NSButtonCell* cell = [tableColumn dataCellForRow:row];
        cell.tag = row;
        cell.title = title;
    
        NSString *isSelect = info.isSelected;
        if(isSelect == nil)
            isSelect = s_true;
    
        [cell setState:[isSelect integerValue]];
        itemCell = cell;
    }else if([tableView.identifier isEqualToString:PackSceneKey]){
        if([_sceneArray count] > 0){
            NSString *item = [_sceneArray objectAtIndex:row];
            itemCell = [item lastPathComponent];
        }
    }
    
    return itemCell;
}

//修改行内容
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSButtonCell* cell = [tableColumn dataCellForRow:row];
    if([tableView.identifier isEqualToString:PlatformTblKey]){
        DetailsInfoData *data = (DetailsInfoData*)[_dataDict objectAtIndex:row];
        NSInteger newState = ![cell state];
        NSString *newStateStr = [NSString stringWithFormat:@"%ld", newState];
        [cell setState: newState];
        [data setValueForKey:Defs_Is_Selected withObj:newStateStr];
    
        [_manager updateDetail:row withObject:data withKey:SAVE_DETAIL_ARRARY_KEY];
    }
}

//修改comboBox内容
- (void)comboBoxSelectionIsChanging:(NSNotification *)notification
{
    //bug:延迟到下一帧取数据
    [self performSelector:@selector(readComboValue:) withObject:[notification object] afterDelay:0];
}

- (void)readComboValue:(id)object
{
    NSComboBox* box = (NSComboBox *)object;
    NSString *changePath = [box stringValue];
    ExportInfo* info = _manager.info;
    
    if([[box identifier] isEqualToString:@"unityPathBox"])
    {
        info->unityProjPath = [changePath UTF8String];
        [_manager replaceUnityProjPath:changePath];
    }
    else if([[box identifier] isEqualToString:@"exportPathBox"])
    {
        info->exportFolderParh = [changePath UTF8String];
        [_manager replaceExportProjPath:changePath];
    }
    else
    {
        showLog("未知路径类型%@", changePath);
    }
}

- (void)addNewInfoContent:(NSNotification*)notification
{
    NSString *content = [notification object];
    NSString *infoString = [NSString stringWithFormat:@":arrow_forward:%@", content];
    infoString = [infoString stringByReplacingEmojiCheatCodesWithUnicode];
    [self renderUpAttriString:infoString withColor:[NSColor blackColor] isBold:NO];
}

- (void)addNewSuccessContent:(NSNotification*)notification
{
    NSString *content = [notification object];
    NSString *infoString = [NSString stringWithFormat:@":heavy_check_mark:%@", content];
    infoString = [infoString stringByReplacingEmojiCheatCodesWithUnicode];
    [self renderUpAttriString:infoString withColor:[NSColor greenColor] isBold:YES];
}

- (void)addNewErrorContent:(NSNotification*)notification
{
    NSString *content = [notification object];
    NSString *infoString = [NSString stringWithFormat:@":heavy_multiplication_x:%@", content];
    infoString = [infoString stringByReplacingEmojiCheatCodesWithUnicode];
    [self renderUpAttriString:infoString withColor:[NSColor redColor] isBold:YES];
}

- (void)addNewWarningContent:(NSNotification*)notification
{
    NSString *content = [notification object];
    NSString *infoString = [NSString stringWithFormat:@":eight_spoked_asterisk:%@", content];
    infoString = [infoString stringByReplacingEmojiCheatCodesWithUnicode];
    [self renderUpAttriString:infoString withColor:[NSColor systemYellowColor] isBold:YES];
}

- (void)setExportBtnState:(NSNotification*)notification
{
    NSString *isEnable = (NSString*)[notification object];
    if ([isEnable isEqualToString: s_true]) {
        _exportBtn.enabled = YES;
        _exportXcode.enabled = YES;
        _exportIpa.enabled = YES;
    }else{
        _exportBtn.enabled = NO;
        _exportXcode.enabled = NO;
        _exportIpa.enabled = NO;
    }
}

- (void)renderUpAttriString:(NSString*)string withColor:(NSColor*) color isBold:(BOOL) isBold
{
    NSString *newStr = [string stringByAppendingString:@"\n"];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    
    NSMutableAttributedString *addString = [[NSMutableAttributedString alloc] initWithString:newStr];
    [addString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [newStr length] - 1)];
    [addString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,[newStr length] - 1)];
    [addString addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:12] range:NSMakeRange(0, [newStr length] - 1)];

    [[_infoLabel textStorage] appendAttributedString:addString];
    
    [_infoLabel scrollRectToVisible:CGRectMake(0, _infoLabel.textContainer.size.height-15, _infoLabel.textContainer.size.width, 10)];
}

- (IBAction)cleanAllLog:(id)sender
{
    [self cleanInfoContent:nil];
}

- (void)cleanInfoContent:(NSNotification*)notification
{
    [[_infoLabel textStorage] deleteCharactersInRange:NSMakeRange(0, [_infoLabel textStorage].length)];
}

- (void)startShowPackTime:(NSNotification*)notification
{
    [_progressTip startAnimation:nil];
    _packTime = 0.0f;
    
    _showTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        _packTime += timer.timeInterval;
        int min=(int)_packTime / 60;
        int sec=(int)_packTime % 60;
        
        NSString *minStr;
        NSString *secStr;
        if(min < 10){
            minStr = [NSString stringWithFormat:@"0%d", min];
        }else{
            minStr = [NSString stringWithFormat:@"%d", min];
        }
        
        if(sec < 10){
            secStr = [NSString stringWithFormat:@"0%d", sec];
        }else{
            secStr = [NSString stringWithFormat:@"%d", sec];
        }
        
        _useTimeLabel.stringValue = [NSString stringWithFormat:@"本次打包用时 %@:%@", minStr, secStr];
    }];
}

- (void)stopShowPackTime:(NSNotification*)notification
{
    showLog("总共打包用时%@", _useTimeLabel.stringValue);
    _useTimeLabel.stringValue = @"";
    [_progressTip stopAnimation:nil];

    if([_showTimer isValid]){
        [_showTimer invalidate];
        _showTimer = nil;
    }
}

- (void)onMenuSelect:(NSNotification*)notification
{
    NSString *identifier = notification.object;
    ExportInfo* info = _manager.info;
    NSButton *btn = [[NSButton alloc] init];
    btn.identifier = identifier;
    if([btn.identifier isEqualToString:@"isReleaseBox"])
        _isReleaseBox.state = (int)(!info->isRelease);
    else if([btn.identifier isEqualToString:@"isExportXcode"])
        _isExportXcode.state = (int)(!info->isExportXcode);
    else if([btn.identifier isEqualToString:@"isExportIpa"])
        _isExportIpa.state = (int)(!info->isExportIpa);
    
    [self isReleaseBtnSelect:btn];
}

- (IBAction)isReleaseBtnSelect:(id)sender
{
    NSButton *btn = (NSButton*)sender;
    ExportInfo* info = _manager.info;
    if([btn.identifier isEqualToString:@"isReleaseBox"]){
        info->isRelease = (int)_isReleaseBox.state;
        [_manager saveDataForKey:SAVE_IS_RELEASE_KEY
                                            withData:[NSString stringWithFormat:@"%d",info->isRelease]];
    }else if([btn.identifier isEqualToString:@"isExportXcode"]){
        info->isExportXcode = (int)_isExportXcode.state;
        [_manager saveDataForKey:SAVE_IS_EXPORT_XCODE
                                            withData:[NSString stringWithFormat:@"%d",info->isExportXcode]];
    }else if([btn.identifier isEqualToString:@"isExportIpa"]){
        info->isExportIpa = (int)_isExportIpa.state;
        [_manager saveDataForKey:SAVE_IS_EXPORT_IPA
                                            withData:[NSString stringWithFormat:@"%d",info->isExportIpa]];
    }
}

- (IBAction)exportXcodeCilcked:(id)sender
{
    EVENT_SEND(EventExportXcodeCilcked, sender);
}

- (IBAction)exportIpa:(id)sender
{
    EVENT_SEND(EventExportIpaChilcked, sender);
}

- (IBAction)openCustomConfig:(id)sender
{
    PreferenceData* dataInst = (PreferenceData*)get_instance(@"PreferenceData");
    NSMutableArray *jsonAppArray = inst_method_call(@"PreferenceData", getJsonAppArray);
    NSString *filePath = dataInst.jsonFilePath;
    [[NSWorkspace sharedWorkspace] openFile:filePath withApplication:[jsonAppArray firstObject]];
}

- (void)panel:(id)sender didChangeToDirectoryURL:(NSURL *)url
{
    NSOpenPanel *openDlg = (NSOpenPanel*)sender;
    if([openDlg.identifier isEqualToString:@"scenePath"])
    {
        NSString *unityProjPath = [NSString stringWithUTF8String:_manager.info->unityProjPath];
        [sender setDirectoryURL:[NSURL URLWithString:unityProjPath]];
    }
}

@end
