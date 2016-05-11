//
//  CodeAuthorSignitureView.m
//  CodeAuthorPlugin
//
//  Created by lzy on 16/4/24.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import "CodeAuthorSignitureView.h"
#import "IDESourceCodeEditor.h"
#import "DVTSourceTextView.h"
#import "DVTFontAndColorTheme.h"

#import "CodeAuthorPlugin.h"
#import "CodeAuthorScrollView.h"

#import "CodeAuthor.h"

static NSString * const IDESourceCodeEditorTextViewBoundsDidChangeNotification = @"IDESourceCodeEditorTextViewBoundsDidChangeNotification";

const CGFloat AuthorViewWidth = 80.f;

@interface CodeAuthorSignitureView()

@property (weak, nonatomic) IDESourceCodeEditor *codeEditor;
@property (strong, nonatomic) DVTSourceTextView *editorTextView;
@property (assign, nonatomic) int originOffset;
@property (strong, nonatomic) NSScrollView *codeAuthorScrollView;
@property (strong, nonatomic) DVTSourceTextView *codeAuthorTextView;
@property (strong, nonatomic) DVTFontAndColorTheme *codeEditorTheme;
@end




@implementation CodeAuthorSignitureView

- (instancetype)initWithCodeEditor:(IDESourceCodeEditor *)codeEditor {
    
    if (self = [super init]) {
        self.codeEditor = codeEditor;
        self.editorTextView = codeEditor.textView;
        self.codeEditorTheme = [DVTFontAndColorTheme currentTheme];
        
        [self setWantsLayer:YES];
        [self setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewWidthSizable | NSViewHeightSizable];
        
        [self registerNotification];
        
        [self configureViews];
        
    }
    return self ;
}

- (void)dealloc {
    [self resignNOtification];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:CODE_AUTHOR_SHOW_BLAME_SHEEL_NOTIFICATION object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self show];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:IDESourceCodeEditorTextViewBoundsDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateDocumentViewOffset];
    }];
    
//    [[NSNotificationCenter defaultCenter] addObserverForName:CODE_AUTHOR_DID_GET_BLAME_ARRAY_NOTIFICATION object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//        NSLog(@"---notify%@", note);
//    }];
}

- (void)resignNOtification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CODE_AUTHOR_SHOW_BLAME_SHEEL_NOTIFICATION object:nil];
}

- (void)configureViews {
    self.codeAuthorScrollView = [[CodeAuthorScrollView alloc] initWithFrame:self.bounds codeEditorScrollView:_codeEditor.scrollView];
    [self.codeAuthorScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.codeAuthorScrollView setDrawsBackground:NO];
    [self.codeAuthorScrollView setMinMagnification:0.0f];
    [self.codeAuthorScrollView setMaxMagnification:1.0f];
    [self.codeAuthorScrollView setAllowsMagnification:NO];
    
    [self.codeAuthorScrollView setHasHorizontalScroller:NO];
    [self.codeAuthorScrollView setHasVerticalScroller:NO];
    [self.codeAuthorScrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
    [self.codeAuthorScrollView setVerticalScrollElasticity:NSScrollElasticityAllowed];
    
    [self addSubview:_codeAuthorScrollView];
    
    self.codeAuthorTextView = [[DVTSourceTextView alloc] initWithFrame:CGRectZero];
    [_codeAuthorScrollView setDocumentView:_codeAuthorTextView];
    
    
    NSTextStorage *textStorage = self.editorTextView.textStorage;
//    [_codeAuthorTextView setTextStorage:textStorage];
    
    
//    [_codeAuthorTextView.layoutManager setBackgroundLayoutEnabled:YES];
//    [_codeAuthorTextView.layoutManager setAllowsNonContiguousLayout:YES];
    
    
//    [_codeAuthorScrollView setMagnification:0.5];
//    NSDictionary *attributes = @{NSFontAttributeName : [NSFont systemFontOfSize:25.0f],
//                                 NSForegroundColorAttributeName: [NSColor redColor]};
//    NSLayoutManager *manager = _codeAuthorTextView.layoutManager;
//    NSTextContainer *container = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(100, 600)];
//
//    
//    [manager setTextStorage:authorTextStorage];
//    [manager addTextContainer:container];
//    NSLayoutManager *layoutManager = _codeAuthorTextView.layoutManager;
//    [authorTextStorage addLayoutManager:layoutManager];
//    [_codeAuthorTextView setTextStorage:authorTextStorage];
    
//    NSString *blameString = [[CodeAuthorPlugin sharedPlugin] blameString];
    NSArray *codeAuthorArray = [[CodeAuthorPlugin sharedPlugin] codeAuthorArray];
    NSString *blameString = [self codeAuthorArrayToTest:codeAuthorArray];
    [_codeAuthorTextView insertText:@"NSString\n"];
    [_codeAuthorTextView insertText:blameString];
    
        
//    NSRange range = NSMakeRange(0, _codeAuthorTextView.textStorage.length);
//    NSMutableParagraphStyle *warnParagraph = [[NSMutableParagraphStyle alloc] init];
//    warnParagraph.lineSpacing = 30;//行间距
//    [_codeAuthorTextView.textStorage setFont:self.editorTextView.textStorage.font];
//    [_codeAuthorTextView.textStorage addAttribute:NSParagraphStyleAttributeName value:warnParagraph range:range];
    
    
//    [_codeAuthorTextView setTextContainer:textCon];
//    [((NSMutableArray *)_codeAuthorTextView.textStorage.layoutManagers) addObject:layoutManager];

    
//    NSString *string = @"看看插入在哪";
//    NSRange range = NSMakeRange(0, _codeAuthorTextView.textStorage.length);
//    [_codeAuthorTextView insertText:blameString replacementRange:range];
    
    //todo 英文行距和中文不同，要不改编译器的layout(英文行高跟中文一样)，要不就想办法一行对一行
}

- (void)show {
    [self updateLayout];
    NSLog(@"finish set textstore");
}

- (void)updateLayout {
    //codeEditor scrillView
    NSRect codeEditorScrollViewSuperViewFrame = _codeEditor.scrollView.superview.frame;
    NSRect codeEditorScrollViewFrame = _codeEditor.scrollView.frame;
    codeEditorScrollViewFrame.origin.x = AuthorViewWidth;
    codeEditorScrollViewFrame.size.width = codeEditorScrollViewSuperViewFrame.size.width - AuthorViewWidth;
    [self.codeEditor.scrollView setFrame:codeEditorScrollViewFrame];
    
    //CodeAuthorSignitureView -- self
    [self setFrame:NSMakeRect(0, 0, AuthorViewWidth, CGRectGetHeight(self.codeEditor.containerView.bounds))];
    
    //CodeAuthorTxtView
    NSRect textViewFrame = _codeAuthorTextView.bounds;
    textViewFrame.size.width = 2*AuthorViewWidth;
    [self.codeAuthorTextView setFrame:textViewFrame];
    
    [self updateDocumentViewOffset];
    
}

- (void)updateDocumentViewOffset {
    [_codeAuthorScrollView.documentView scrollPoint:NSMakePoint(0, CGRectGetMinY(_codeEditor.scrollView.contentView.bounds))];
}

- (NSString *)codeAuthorArrayToTest:(NSArray *)codeAuthorArray {
    NSString *blameString = @"";
    for (CodeAuthor *codeAuthor in codeAuthorArray) {
        blameString = [self stringByAppendingCodeAuthor:codeAuthor string:blameString];
        blameString = [blameString stringByAppendingString:@"\n"];
    }
    blameString = [blameString substringToIndex:blameString.length-1];
    return blameString;
}

- (NSString *)stringByAppendingCodeAuthor:(CodeAuthor *)codeAuthor string:(NSString *)string {
    if (nil != codeAuthor) {
        NSString *resultString;
        resultString = [string stringByAppendingString:codeAuthor.name];
        resultString = [resultString stringByAppendingString:@" "];
//        resultString = [resultString stringByAppendingString:codeAuthor.formatTimeString];
        return resultString;
    } else {
        //todo 出错终止
    }
    return @"";
}

@end
