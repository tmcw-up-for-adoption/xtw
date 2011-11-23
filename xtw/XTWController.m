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
    
    NSMutableDictionary *menuAttributes = [NSMutableDictionary dictionary];
        
    [menuAttributes setObject:[NSFont fontWithName:@"Lucida Grande"
											  size:14]
                                            forKey:NSFontAttributeName];
    
    
    taskContents = [NSString stringWithContentsOfFile:pendingPath
                                             encoding:NSASCIIStringEncoding
                                                error:&err];
    
    if (err) {
        [menuAttributes setObject:[NSColor grayColor]
                           forKey:NSForegroundColorAttributeName];	
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
            [menuAttributes setObject:[NSColor redColor]
                               forKey:NSForegroundColorAttributeName];	
            statusTitle = [NSString stringWithFormat:@"%dx%d", [tasks count], overdue];
        } else {
            [menuAttributes setObject:[NSColor blackColor]
                               forKey:NSForegroundColorAttributeName];	
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
        taskContents = [[NSString alloc] retain];
        pendingPath = [[@"~/.task/pending.data" stringByExpandingTildeInPath] retain];
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
    return self;
}
- (void)downloadNewDataTimerFired
{
    [self updateCount];
}
@end