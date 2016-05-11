//
//  CodeAuthorScrollView.m
//  CodeAuthorPlugin
//
//  Created by lzy on 16/4/24.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import "CodeAuthorScrollView.h"

@interface CodeAuthorScrollView()
@property (strong, nonatomic) NSScrollView *codeEditorScrollView;

@end

@implementation CodeAuthorScrollView

- (instancetype)initWithFrame:(NSRect)frame codeEditorScrollView:(NSScrollView *)codeEditorScrollView {
    self  = [super initWithFrame:frame];
    if (self) {
        _codeEditorScrollView = codeEditorScrollView;
    }
    return self;
}

//让authorScrollView里的滚动事件映射到codeEditorScrollView里
- (void)scrollWheel:(NSEvent *)theEvent {
    [_codeEditorScrollView scrollWheel:theEvent];
}

@end
