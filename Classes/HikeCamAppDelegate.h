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
@class RootViewController;

@interface HikeCamAppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIWindow *window;
    RootViewController *rootViewController;
	io_connect_t root_port;
	io_object_t notifier;
	
    NSTimer *animationTimer;
    NSTimeInterval animationInterval;
	SystemSoundID shutterSound;
	bool soundEnabled;
	int photoNum;	
	NSString *rootImagePath;	
}

- (void)powerMessageReceived:(uint32_t)messageType withArgument:(void *)messageArgument;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;

@property NSTimeInterval animationInterval;
@property bool soundEnabled;
@property SystemSoundID shutterSound;

- (void)takePicture:(id)sender;

@end

@interface HikeCamAppDelegate (TimedPhotos)
- (void)startAnimation;
- (void)stopAnimation;
- (void)animCallback;
@end

@interface HikeCamAppDelegate (UIImagePickerControllerDelegate)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;

@end

@interface HikeCamAppDelegate (UINavigationControllerDelegate)

@end

