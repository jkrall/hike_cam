//
//  HikeCamAppDelegate.m
//  HikeCam
//
//  Created by Joshua Krall on 11/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HikeCamAppDelegate.h"
#import "RootViewController.h"
#import "MainView.h"

@implementation HikeCamAppDelegate

@synthesize window;
@synthesize rootViewController;
@synthesize animationInterval;
@synthesize soundEnabled, shutterSound;

void powerCallback(void *refCon, io_service_t service, uint32_t messageType, void *messageArgument)
{	
	NSLog(@"refCon: %x", refCon);
	NSLog(@"service: %d", service);
	NSLog(@"messageType: %d", messageType);
	NSLog(@"messageArgument: %x", messageArgument);
	[(HikeCamAppDelegate *)[(UIApplication*)refCon delegate] powerMessageReceived:messageType withArgument:messageArgument];
}

- (void)powerMessageReceived:(uint32_t)messageType withArgument:(void *)messageArgument
{
    switch (messageType)
    {
        case kIOMessageSystemWillSleep:
			/* The system WILL go to sleep. If you do not call IOAllowPowerChange or
			 IOCancelPowerChange to acknowledge this message, sleep will be
			 delayed by 30 seconds.
			 
			 NOTE: If you call IOCancelPowerChange to deny sleep it returns kIOReturnSuccess,
			 however the system WILL still go to sleep.
			 */
			
            // we cannot deny forced sleep
			NSLog(@"powerMessageReceived kIOMessageSystemWillSleep");
            IOAllowPowerChange(root_port, (long)messageArgument);  
            break;
        case kIOMessageCanSystemSleep:
			/*
			 Idle sleep is about to kick in.
			 Applications have a chance to prevent sleep by calling IOCancelPowerChange.
			 Most applications should not prevent idle sleep.
			 
			 Power Management waits up to 30 seconds for you to either allow or deny idle sleep.
			 If you don't acknowledge this power change by calling either IOAllowPowerChange
			 or IOCancelPowerChange, the system will wait 30 seconds then go to sleep.
			 */
			
			NSLog(@"powerMessageReceived kIOMessageCanSystemSleep");
			
			//cancel the change to prevent sleep
			IOCancelPowerChange(root_port, (long)messageArgument);
			//IOAllowPowerChange(root_port, (long)messageArgument);	
			
            break; 
        case kIOMessageSystemHasPoweredOn:
            NSLog(@"powerMessageReceived kIOMessageSystemHasPoweredOn");
            break;
    }
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	IONotificationPortRef notificationPort;
	root_port = IORegisterForSystemPower(application, &notificationPort, powerCallback, &notifier);
	
	// add the notification port to the application runloop
	CFRunLoopAddSource(CFRunLoopGetCurrent(),
					   IONotificationPortGetRunLoopSource(notificationPort),
					   kCFRunLoopCommonModes );
	
	application.applicationIconBadgeNumber = 1;
	
	soundEnabled = true;
	NSString *path = [[NSBundle mainBundle] pathForResource:@"photoShutter" ofType:@"caf"];
	NSURL *url = [NSURL fileURLWithPath:path];
	AudioServicesCreateSystemSoundID((CFURLRef)url, &shutterSound);	
	
	photoNum = 1;
	
	// Hide Apple's UI
	rootViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
	rootViewController.allowsEditing = NO;
	rootViewController.showsCameraControls = NO;
	rootViewController.navigationBarHidden = YES;
	rootViewController.toolbarHidden = YES;
	rootViewController.wantsFullScreenLayout = YES;
	//rootViewController.cameraViewTransform = CGAffineTransformScale(rootViewController.cameraViewTransform, 1.0, 1.13);
	
	[rootViewController setDelegate:self];
	
	animationInterval = 20.0;
	[self startAnimation];
		
    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	//Remove the "On" badge from the Insomnia SpringBoard icon
	application.applicationIconBadgeNumber = 0;
}

- (void)dealloc {
    [rootViewController release];
    [window release];
    [super dealloc];
}

-(void)takePicture:(id)sender
{
	NSLog(@"Starting to take a photo\n");					
	[rootViewController takePicture];
}

@end


@implementation HikeCamAppDelegate (TimedPhotos)

- (void)startAnimation 
{
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(animCallback) userInfo:nil repeats:YES];
}

- (void)stopAnimation
{
	[animationTimer invalidate];
	animationTimer = nil;
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	NSLog(@"Setting Interval to: %d seconds", (int)interval);
	animationInterval = interval;
	
	if(animationTimer) {
		[self stopAnimation];
		[self startAnimation];
	}
}
- (void)animCallback
{
	[self takePicture:self];

	//NSDate *nextWake = [NSDate dateWithTimeIntervalSinceNow:(double)animationInterval];	
	//IOReturn ret = IOPMSchedulePowerEvent((CFDateRef) nextWake, (CFStringRef)@"HikeCam", CFSTR(kIOPMAutoWakeOrPowerOn));	
}

@end




@implementation HikeCamAppDelegate (Camera)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSLog(@"Took a picture\n");					
	if (soundEnabled) {
		AudioServicesPlaySystemSound(shutterSound);
	}
	
	UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);
	
	MainViewController *mainViewController = [rootViewController mainViewController];
	[mainViewController navigationItem].title = [NSString stringWithFormat:@"Photo #: %d", photoNum];
	
	photoNum++;
}

@end
