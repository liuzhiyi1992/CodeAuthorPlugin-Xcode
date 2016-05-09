//
//  CodeAuthorPlugin.m
//  CodeAuthorPlugin
//
//  Created by lzy on 16/4/21.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import "CodeAuthorPlugin.h"
#import "NSView+Dumping.h"

#import "IDESourceCodeEditor.h"
#import "DVTSourceTextView.h"

#import "CodeAuthorSignitureView.h"

#import "CodeAuthor.h"


static Class IDEWorkspaceWindowControllerClass;
id objc_getClass(const char* name);

static CodeAuthorPlugin *sharedPlugin = nil;

NSString * const IDESourceCodeEditorDidFinishSetupNotification = @"IDESourceCodeEditorDidFinishSetup";
//NSString *const NSTextInputContextKeyboardSelectionDidChangeNotification = @"NSTextInputContextKeyboardSelectionDidChangeNotification";
//DVTSourceExpressionSelectedExpressionDidChangeNotification
NSString * const DVTSourceExpressionSelectedExpressionDidChangeNotification = @"DVTSourceExpressionSelectedExpressionDidChangeNotification";
NSString * const IDEEditorContextWillOpenNavigableItemNotification = @"IDEEditorContextWillOpenNavigableItemNotification";

NSString * const GitPath = @"/Applications/Xcode.app/Contents/Developer/usr/libexec/git-core";
NSString * const PIPE = @"|";
NSString * const AWK = @"awk";

#pragma mark - Own Notification
NSString * const CODE_AUTHOR_SHOW_BLAME_SHEEL_NOTIFICATION = @"CODE_AUTHOR_SHOW_BLAME_SHEEL_NOTIFICATION";
//NSString * const CODE_AUTHOR_DID_GET_BLAME_ARRAY_NOTIFICATION = @"CODE_AUTHOR_DID_GET_BLAME_ARRAY_NOTIFICATION";
NSString * const CODE_AUTHOR_VIEW_DID_SETUP_NOTIFICATION = @"CODE_AUTHOR_VIEW_DID_SETUP_NOTIFICATION";

NSString * const KEY_BLAME_ARRAY = @"KEY_BLAME_ARRAY";

@interface CodeAuthorPlugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@property (nonatomic, strong) id ideWorkspaceWindow;
@property (strong, nonatomic) NSArray *ignorePrefix;
@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *documentPath;


@end

@implementation CodeAuthorPlugin


+ (void)pluginDidLoad:(NSBundle *)plugin {
    [self sharedPlugin];
}


+ (instancetype)sharedPlugin {
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[CodeAuthorPlugin alloc] init];
        });
    }
    return sharedPlugin;
}

- (id)init
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
//        self.bundle = plugin;
        
        [self configureNotifyIgnorePrefix];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        //todo
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:nil object:nil];
        
        //NSOutlineViewSelectionDidChangeNotification
        //NSFileHandleDataAvailableNotification
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outlineViewSelectionDidChange:) name:NSOutlineViewSelectionDidChangeNotification object:nil];
        
        //代码文件切换
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editorContextDidChange:) name:IDEEditorContextWillOpenNavigableItemNotification object:nil];
        
        //代码编辑器setup
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidFinishSetup:) name:IDESourceCodeEditorDidFinishSetupNotification object:nil];
        
        //窗口激活
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchActiveIDEWorkspaceWindow:) name:NSWindowDidUpdateNotification object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(justForTestAction:) name:NSOutlineViewSelectionIsChangingNotification object:nil];
        
        [self registerNotification];
        
        IDEWorkspaceWindowControllerClass = objc_getClass("IDEWorkspaceWindowController");
        
        
        
        
    }
    return self;
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:CODE_AUTHOR_VIEW_DID_SETUP_NOTIFICATION object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
    }];
}

- (void)codeAuthorViewDidSetup {
    [self queryBlameWithPath:_documentPath fileName:_fileName];
}

- (void)configureNotifyIgnorePrefix {
    self.ignorePrefix = @[@"NSApplicationDidUpdate", @"NSApplicationWillUpdate", @"NSWindowDidUpdate", @"NSTextInputContextKeyboardSelectionDidChange",
                          @"VTSourceExpressionSelectedExpression", @"NSViewFrame", @"NSViewDidUpdateTrackingAreas", @"NSFileHandleDataAvailable",
                          @"NSTextViewDidChangeSelection", @"NSMenuDidRemove", @"NSMenuDidAdd", @"IDESourceCodeEditorDidChangeLine", @"NSThread",
                          @"NSWindowDidResign", @"NSWindowDidBecome"];
}

- (BOOL)validateIgnorePrefix:(NSString *)string {
    for (NSString *prefix in _ignorePrefix) {
        if ([string hasPrefix:prefix]) {
            return NO;
        }
    }
    return YES;
}

- (void)notificationLog:(NSNotification *)notify {
    
    if ([self validateIgnorePrefix:[notify name]]) {
//        NSLog(@"NotificationLog -- %@", [notify name]);
    }
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@"M"];
        [actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        
        NSMenuItem *showBlameViewMenuItem = [[NSMenuItem alloc] initWithTitle:@"Show Blame Sheel" action:@selector(showBlameSheel) keyEquivalent:@""];
        [showBlameViewMenuItem setTarget:self];
        
        [[menuItem submenu] addItem:actionMenuItem];
        [[menuItem submenu] addItem:showBlameViewMenuItem];
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    //dumpView
//    [[[NSApp mainWindow] contentView] dumpWithIndent:@""];
    
//    [self queryBlameWithPath:_documentPath fileName:_fileName];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Hello, World"];
    [alert runModal];
}

- (void)showBlameSheel {
    //todo 本地持久
    [[NSNotificationCenter defaultCenter] postNotificationName:CODE_AUTHOR_SHOW_BLAME_SHEEL_NOTIFICATION object:nil];
}

- (NSArray *)queryBlameWithPath:(NSString *)path fileName:(NSString *)fileName {
    NSTask *blameTask = [[NSTask alloc] init];
    [blameTask setLaunchPath:@"/usr/bin/xcrun"];
    [blameTask setCurrentDirectoryPath:path];
    [blameTask setArguments:@[@"git", @"blame", @"-c", fileName]];
    
    NSPipe *pipeBetween = [NSPipe pipe];
    [blameTask setStandardOutput:pipeBetween];
    
    NSTask *awkTask = [[NSTask alloc] init];
    [awkTask setLaunchPath:@"/usr/bin/awk"];
    [awkTask setArguments:@[@"{print $2,$3,$4}"]];
    [awkTask setStandardInput:pipeBetween];
    
    NSPipe *pipeToFile = [NSPipe pipe];
    [awkTask setStandardOutput:pipeToFile];
    
    NSFileHandle *file = [pipeToFile fileHandleForReading];
    
    [blameTask launch];
    [awkTask launch];

    NSString *outputString = [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    
    @try {
        self.codeAuthorArray = [self codeAuthorFactoryWithBlameString:outputString];
    } @catch (NSException *exception) {
        NSLog(@"出错了，别方%@", exception);
        //todo 处理错误,绝对不可以crash
    } @finally {
        NSLog(@"处理错误完毕");
    }
    _blameString = outputString;
    
    NSArray *blameArray = [outputString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    _blameArray = blameArray;
    return blameArray;
}

- (NSArray *)codeAuthorFactoryWithBlameString:(NSString *)blameString {
    NSMutableArray *codeAuthorArray = [NSMutableArray array];
    
    NSArray *lineBlameArray = [blameString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *lineBlameString in lineBlameArray) {
        if (lineBlameString.length <= 0) {
            continue;
        }
        NSString *cutBracketString;
        
        NSString *firstChar = [lineBlameString substringToIndex:1];
        if ([firstChar isEqualToString:@"("]) {
            cutBracketString = [lineBlameString substringFromIndex:1];
        }
        //trim whiteSpace
        cutBracketString = [cutBracketString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *blameInfoArray = [cutBracketString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (blameInfoArray.count >= 2) {
            CodeAuthor *codeAuthor = [[CodeAuthor alloc] init];
            codeAuthor.name = blameInfoArray.firstObject;
            codeAuthor.formatTimeString = blameInfoArray[1];
            [codeAuthorArray addObject:codeAuthor];
        } else {
            //todo Exception
        }
    }
    return codeAuthorArray;
}

- (NSPipe *)shellCommandWithLaunchPath:(NSString *)launchPath directoryPath:(NSString *)directoryPath arguments:(NSArray *)arguments {
//    NSTask *task = [[NSTask alloc] init];
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//todo 还没试验
#pragma mark - Xcode Notification
- (void)onDidFinishSetup:(NSNotification *)notify {
    //先拿数据
    [self activeDocument];
    
    //在显示
    if(![notify.object isKindOfClass:[IDESourceCodeEditor class]]) {
        NSLog(@"Could not fetch source code editor container");
        return;
    }
    
    IDESourceCodeEditor *codeEditor = (IDESourceCodeEditor *)[notify object];
    [codeEditor.textView setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin | NSViewWidthSizable | NSViewHeightSizable];
    [codeEditor.scrollView setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin | NSViewWidthSizable | NSViewHeightSizable];
    [codeEditor.containerView setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin | NSViewWidthSizable | NSViewHeightSizable];
    
    CodeAuthorSignitureView *authorSignitureView = [[CodeAuthorSignitureView alloc] initWithCodeEditor:codeEditor];
    [codeEditor.containerView addSubview:authorSignitureView];
//
//    SCXcodeMinimapView *minimapView = [[SCXcodeMinimapView alloc] initWithEditor:editor];
//    [editor.containerView addSubview:minimapView];
}

- (void)justForTestAction:(NSNotification *)notify {
    id sec = [notify object];
    NSLog(@"\n--- 秘密是什么 ----%@", sec);
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notify {
    NSView *outLineView = [notify object];
    for (NSView *view in outLineView.subviews) {
        //todo! 这里可以拿到当前所有文件item
        NSLog(@"子类：%@", view);
    }
//    NSLog(@"--- 秘密是什么 ----%@", sec);
}

- (void)editorContextDidChange:(NSNotification *)notify {
    id object = [notify object];
//    [self performSelector:@selector(activeDocument) withObject:nil afterDelay:2.0];
//    [self activeDocument];
}

- (void)fetchActiveIDEWorkspaceWindow:(NSNotification *)notify {
    id window = [notify object];
    if ([window isKindOfClass:[NSWindow class]] && [window isMainWindow])
    {
        self.ideWorkspaceWindow = window;
    }
}

- (NSURL *)activeDocument
{
    NSArray *windows = [IDEWorkspaceWindowControllerClass valueForKey:@"workspaceWindowControllers"];
    for (id workspaceWindowController in windows)
    {
        if ([workspaceWindowController valueForKey:@"workspaceWindow"] == self.ideWorkspaceWindow || windows.count == 1)
        {
            id document = [[workspaceWindowController valueForKey:@"editorArea"] valueForKey:@"primaryEditorDocument"];
            NSURL *fileUrl = [document fileURL];
            NSString *documentPath = [[fileUrl URLByDeletingLastPathComponent] path];
            NSString *fileName = [[document fileURL] lastPathComponent];
            NSLog(@"\n绝对路径------%@\n文件夹路径%@\n文件名%@", fileUrl, documentPath, fileName);
            
            self.documentPath = documentPath;
            self.fileName = fileName;
            
            //请求Blame
            [self queryBlameWithPath:_documentPath fileName:_fileName];
            
            return [document fileURL];
        }
    }
    return nil;
}

@end
