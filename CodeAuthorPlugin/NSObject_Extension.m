//
//  NSObject_Extension.m
//  CodeAuthorPlugin
//
//  Created by lzy on 16/4/21.
//  Copyright © 2016年 lzy. All rights reserved.
//


#import "NSObject_Extension.h"
#import "CodeAuthorPlugin.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[CodeAuthorPlugin alloc] initWithBundle:plugin];
        });
    }
}
@end
