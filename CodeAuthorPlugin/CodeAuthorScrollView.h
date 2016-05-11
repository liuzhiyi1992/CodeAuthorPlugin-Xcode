//
//  CodeAuthorScrollView.h
//  CodeAuthorPlugin
//
//  Created by lzy on 16/4/24.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CodeAuthorScrollView : NSScrollView

- (instancetype)initWithFrame:(NSRect)frame codeEditorScrollView:(NSScrollView *)codeEditorScrollView;

@end
