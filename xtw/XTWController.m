//
//  XTWController.m
//  xtw
//
//  Created by Tom MacWright on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XTWController.h"

@implementation XTWController
- (void)updateCount
{
    NSString *statusTitle = nil;
    NSError *err = nil;
    
    NSMutableDictionary *menuAttributes = [NSMutableDictionary dictionary];
    NSFont *displayFont = [NSFont fontWithName:@"Helvetica Neue" size:20];
    if (!displayFont)
        displayFont = [NSFont boldSystemFontOfSize:22];
    
    NSString *taskcontents = [NSString stringWithContentsOfFile:[@"~/.task/pending.data" stringByExpandingTildeInPath] encoding:NSASCIIStringEncoding error:err];
    
    NSArray *tasks = [taskcontents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    statusTitle = [NSString stringWithFormat:@"%d", [tasks count]];
    
    [statusItem setAttributedTitle:[[[NSAttributedString alloc] initWithString:statusTitle attributes:menuAttributes] autorelease]];
}
- (id)init
{
	self = [super init];
	if(self)
	{
		menu                     = [[NSMenu alloc] init];
        statusItem               = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
        [statusItem setMenu:menu];
        [statusItem retain];
        [statusItem setToolTip:@"taskwarrior"];
        [statusItem setHighlightMode:YES];
        quitMI = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Quit",@"") 
                                             action:@selector(terminate:) 
                                      keyEquivalent:@""] autorelease];
        
        aboutMI = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"About xtw",@"")
                                              action:@selector(orderFrontStandardAboutPanel:)
                                       keyEquivalent:@""] autorelease];
        
        [quitMI setTarget:NSApp];	
        [aboutMI setTarget:NSApp];
        [menu addItem:aboutMI];
        [menu addItem:[NSMenuItem separatorItem]];
        [menu addItem:quitMI];
        
        automaticUpdateTimer     = [[NSTimer scheduledTimerWithTimeInterval:10
																	 target:self
																   selector:@selector(downloadNewDataTimerFired) 
																   userInfo:nil 
																	repeats:YES] retain];
        [self updateCount];
    }
}
- (void)downloadNewDataTimerFired
{
    [self updateCount];
}
@end