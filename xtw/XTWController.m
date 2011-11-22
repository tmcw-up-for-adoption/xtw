//
//  XTWController.m
//  xtw
//
//  Created by Tom MacWright on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XTWController.h"

@implementation XTWController
- (id)init
{
	self = [super init];
	if(self)
	{
		menu                     = [[NSMenu alloc] init];
        statusItem               = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
        [statusItem setMenu:menu];
        [statusItem retain];
        
        NSMutableDictionary *menuAttributes = [NSMutableDictionary dictionary];
        NSFont *displayFont = [NSFont fontWithName:@"Arial Black" size:20];
        if (!displayFont)
            displayFont = [NSFont boldSystemFontOfSize:22];
        
        NSString *statusTitle = nil;
        NSError *err = nil;
        
        NSString *taskcontents = [NSString stringWithContentsOfFile:[@"~/.task/pending.data" stringByExpandingTildeInPath] encoding:NSASCIIStringEncoding error:err];
        
        NSArray *tasks = [taskcontents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        statusTitle = [NSString stringWithFormat:@"%d", [tasks count]];
        
        // statusTitle = NSLocalizedString(@"3 | 2",@"");
        [statusItem setAttributedTitle:[[[NSAttributedString alloc] initWithString:statusTitle attributes:menuAttributes] autorelease]];
    }
}
@end