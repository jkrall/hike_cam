//
//  RootViewController.m
//  HikeCam
//
//  Created by Joshua Krall on 11/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "RootViewController.h"
#import "MainViewController.h"
#import "FlipsideViewController.h"
#import "FlipsideView.h"

@implementation RootViewController

@synthesize flipsideNavigationBar;
@synthesize mainViewController;
@synthesize flipsideViewController;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cameraOverlayView = navController.view;
}


- (void)loadFlipsideViewController {
    FlipsideViewController *viewController = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    self.flipsideViewController = viewController;
    [viewController release];
}


- (IBAction) settingsButton 
{    
    if (flipsideViewController == nil) {
        [self loadFlipsideViewController];
    }

	[navController pushViewController:flipsideViewController animated:YES];
	
//    if (navController.visibleViewController == mainViewController) {
//		[navController pushViewController:flipsideViewController animated:YES];
//    } else {
//		[navController popViewControllerAnimated:YES];
//    }
}

- (IBAction) exitButton 
{
	UIApplication *app = [UIApplication sharedApplication];
	[app.delegate applicationWillTerminate:app];
	exit(0);
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [flipsideNavigationBar release];
    [mainViewController release];
    [flipsideViewController release];
    [super dealloc];
}


@end
