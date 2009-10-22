//
//  HikeCamAppDelegate.h
//  HikeCam
//
//  Created by Joshua Krall on 11/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <IOKit/pwr_mgt/IOPMLib.h>
#import <IOKit/IOMessage.h>
#import "AudioToolbox/AudioServices.h"
#import <Foundation/NSKeyValueObserving.h>

@class PLCameraController;
@class MainViewController;
@class FlipsideViewController;

@interface HikeCamAppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate> {
  UIWindow *window;
	id cameraController;
	io_connect_t root_port;
	io_object_t notifier;

  NSTimer *animationTimer;
  NSTimeInterval animationInterval;
	SystemSoundID shutterSound;
	bool soundEnabled;
	int photoNum;
	NSString *rootImagePath;
	NSString *imageSequenceName;
	UINavigationController *navController;
	MainViewController *mainViewController;
	FlipsideViewController *flipsideViewController;
	UINavigationBar *flipsideNavigationBar;
}

@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;
@property (nonatomic, retain) UINavigationBar *flipsideNavigationBar;
@property (nonatomic, retain) FlipsideViewController *flipsideViewController;

- (IBAction) settingsButton;
- (IBAction) exitButton;

- (void)powerMessageReceived:(uint32_t)messageType withArgument:(void *)messageArgument;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) id cameraController;
@property (nonatomic, retain) NSString *imageSequenceName;

@property NSTimeInterval animationInterval;
@property bool soundEnabled;
@property SystemSoundID shutterSound;

@end

@interface HikeCamAppDelegate (TimedPhotos)
- (void)startAnimation;
- (void)stopAnimation;
- (void)animCallback;
@end

@interface HikeCamAppDelegate (UINavigationControllerDelegate)

@end

