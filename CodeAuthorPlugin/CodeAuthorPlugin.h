//
//  CodeAuthorPlugin.h
//  CodeAuthorPlugin
//
//  Created by lzy on 16/4/21.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import <AppKit/AppKit.h>

extern NSString * const CODE_AUTHOR_SHOW_BLAME_SHEEL_NOTIFICATION;
//extern NSString * const CODE_AUTHOR_DID_GET_BLAME_ARRAY_NOTIFICATION;
extern NSString * const KEY_BLAME_ARRAY;


@class CodeAuthorPlugin;



@interface CodeAuthorPlugin : NSObject
@property (strong, nonatomic) NSArray *codeAuthorArray;
@property (strong, nonatomic, readonly) NSArray *blameArray;
@property (copy, nonatomic) NSString *blameString;

+ (instancetype)sharedPlugin;
//- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end