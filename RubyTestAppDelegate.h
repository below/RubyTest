//
//  RubyTestAppDelegate.h
//  RubyTest
//
//  Created by Alexander v. Below on 26.04.10.
//  Copyright 2010 AVB Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RubyTestAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
