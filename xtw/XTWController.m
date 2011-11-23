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
    NSInteger timestamp = (long)[[NSDate date] timeIntervalSince1970];
    NSInteger overdue = 0;
    
    NSMutableArray *taskData = nil;
    
    NSMutableDictionary *menuAttributes = [NSMutableDictionary dictionary];
    NSFont *displayFont = [NSFont fontWithName:@"Helvetica Neue"
                                          size:20];
    if (!displayFont)
        displayFont = [NSFont boldSystemFontOfSize:22];
        
    taskContents = [NSString stringWithContentsOfFile:pendingPath
                                             encoding:NSASCIIStringEncoding
                                                error:&err];
    
    if (err) {
        statusTitle = @"install taskwarrior";
    } else {
        NSArray *tasks = [taskContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        NSEnumerator *e = [tasks objectEnumerator];
        id object;
        NSInteger dueDate;
        NSScanner *dueScanner;
        while (object = [e nextObject]) {
            dueScanner = [NSScanner scannerWithString:object];
            [dueScanner scanUpToString:@"due:\"" intoString:nil];
            [dueScanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
            if ([dueScanner isAtEnd] == NO) {
                [dueScanner scanInteger:&dueDate];
                if (dueDate < timestamp) {
                    overdue++;
                }
            }
        }
        if (overdue > 0) {
            statusTitle = [NSString stringWithFormat:@"%d | %d", overdue, [tasks count]];
        } else {
            statusTitle = [NSString stringWithFormat:@"%d", [tasks count]];
        }
    }
    
    
    [statusItem setAttributedTitle:[[[NSAttributedString alloc]
                                     initWithString:statusTitle
                                     attributes:menuAttributes] autorelease]];
}
- (id)init
{
	self = [super init];
	if(self)
	{
        pendingPath = [[NSString alloc] retain];
        taskContents = [[NSString alloc] retain];
        pendingPath = [@"~/.task/pending.data" stringByExpandingTildeInPath];
		menu                     = [[NSMenu alloc] init];
        
        // Set up my status item
        statusItem               = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
        [statusItem setMenu:menu];
        [statusItem retain];
        [statusItem setToolTip:@"taskwarrior"];
        [statusItem setHighlightMode:YES];
        
        // Set up the menu
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
        
        // Keep the thing updated
        automaticUpdateTimer     = [[NSTimer scheduledTimerWithTimeInterval:10
																	 target:self
																   selector:@selector(downloadNewDataTimerFired) 
																   userInfo:nil 
																	repeats:YES] retain];
        
        // Run the initial update
        [self updateCount];
    }
}
- (void)downloadNewDataTimerFired
{
    [self updateCount];
}
@end