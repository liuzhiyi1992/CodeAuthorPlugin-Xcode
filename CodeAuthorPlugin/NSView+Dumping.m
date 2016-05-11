//
//  NSView+Dumping.m
//  DemoPlugin
//
//  Created by OneV on 13-2-2.
//  Copyright (c) 2013年 OneV's Den. All rights reserved.
//

#import "NSView+Dumping.h"

@implementation NSView (Dumping)

-(void)dumpWithIndent:(NSString *)indent {
    NSString *class = NSStringFromClass([self class]);
//    if ([class isEqualToString:@"DVTSourceTextScrollView"]) {
//        [self.layer setBackgroundColor:CGColorCreateGenericRGB(56/255.0, 56/255.0, 56/255.0, 1.0)];
//        NSView *view = [[NSView alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 500, 500))];
//        [view.layer setBackgroundColor:CGColorCreateGenericRGB(56/255.0, 56/255.0, 56/255.0, 1.0)];
//        [self addSubview:view];
////        [self changeColor:[CIColor colorWithRed:0.5 green:0.5 blue:0.5]];
//    }
    NSString *info = @"";
    if ([self respondsToSelector:@selector(title)]) {
        NSString *title = [self performSelector:@selector(title)];
        if (title != nil && [title length] > 0) {
            info = [info stringByAppendingFormat:@" title=%@", title];
        }
    }
    if ([self respondsToSelector:@selector(stringValue)]) {
		NSString *string = [self performSelector:@selector(stringValue)];
		if (string != nil && [string length] > 0) {
			info = [info stringByAppendingFormat:@" stringValue=%@", string];
        }
	}
	NSString *tooltip = [self toolTip];
	if (tooltip != nil && [tooltip length] > 0) {
		info = [info stringByAppendingFormat:@" tooltip=%@", tooltip];
    }
    
	NSLog(@"%@%@%@", indent, class, info);
    
	if ([[self subviews] count] > 0) {
		NSString *subIndent = [NSString stringWithFormat:@"%@%@", indent, ([indent length]/2)%2==0 ? @"| " : @": "];
		for (NSView *subview in [self subviews]) {
			[subview dumpWithIndent:subIndent];
        }
	}
}

@end
