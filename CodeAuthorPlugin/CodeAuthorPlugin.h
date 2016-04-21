//
//  CodeAuthorPlugin.h
//  CodeAuthorPlugin
//
//  Created by lzy on 16/4/21.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import <AppKit/AppKit.h>

@class CodeAuthorPlugin;

static CodeAuthorPlugin *sharedPlugin;

@interface CodeAuthorPlugin : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end