//
//  MainView.m
//  HikeCam
//
//  Created by Joshua Krall on 11/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "MainView.h"
#import <Foundation/Foundation.h>
#import "HikeCamAppDelegate.h"

@implementation MainView

@synthesize imageNumberLabel;

- (id)initWithCoder:(NSCoder*)coder
{
    if(self = [super initWithCoder:coder]) {
		// Initialization code
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


@end



