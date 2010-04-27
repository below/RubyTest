//
//  RubyTestAppDelegate.m
//  RubyTest
//
//  Created by Alexander v. Below on 26.04.10.
//  Copyright 2010 AVB Software. All rights reserved.
//

#import "RubyTestAppDelegate.h"
#import <MacRuby/MacRuby.h>

@implementation RubyTestAppDelegate

@synthesize window;

- (void) startServer:(id)object {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    @try {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"webrick" ofType:@"rb"];
        id object;
        object = [[MacRuby sharedRuntime] evaluateFileAtPath:path];
        NSLog (@"%@", [object description]);
    }
    @catch (NSException *exception) {
        NSString *string = [NSString stringWithFormat:@"%@: %@\n%@", [exception name], [exception reason], 
                            [[[exception userInfo] objectForKey:@"backtrace"] description]];
        NSLog (@"%@", string);
    }    
    NSLog (@"end");
    [pool dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [NSThread detachNewThreadSelector:@selector(startServer:) toTarget:self withObject:nil];
}

@end
