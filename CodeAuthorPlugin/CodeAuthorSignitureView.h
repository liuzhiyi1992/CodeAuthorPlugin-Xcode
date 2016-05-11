//
//  CodeAuthorSignitureView.h
//  CodeAuthorPlugin
//
//  Created by lzy on 16/4/24.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IDESourceCodeEditor;

@interface CodeAuthorSignitureView : NSView

- (instancetype)initWithCodeEditor:(IDESourceCodeEditor *)codeEditor;

@end
