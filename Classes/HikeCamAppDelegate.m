//
//  HikeCamAppDelegate.m
//  HikeCam
//
//  Created by Joshua Krall on 11/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HikeCamAppDelegate.h"
#import "MainView.h"
#import "MainViewController.h"

@implementation HikeCamAppDelegate

@synthesize window, mainViewController, flipsideViewController, flipsideNavigationBar, navController;
@synthesize cameraController;
@synthesize animationInterval;
@synthesize soundEnabled, shutterSound, imageSequenceName, currentImagePath;

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

	self.cameraController = [(id)objc_getClass("PLCameraController") performSelector:@selector(sharedInstance)];
	[cameraController setDelegate:self];
	[cameraController setFocusDisabled:NO];
	// BAD [cameraController setCaptureAtFullResolution:YES];
	// BAD [cameraController setDontShowFocus:YES];

	UIView *previewView = [cameraController performSelector:@selector(previewView)];
	//[[mainViewController view] addSubview:previewView];
	[window addSubview:previewView];
	[cameraController performSelector:@selector(startPreview)];
	sleep(2);

	animationInterval = 10.0;
	[self startAnimation];

	[window addSubview:navController.view];
  [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	//Remove the "On" badge from the Insomnia SpringBoard icon
	application.applicationIconBadgeNumber = 0;
}

- (void)dealloc {
    [window release];
    [super dealloc];
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
}

- (IBAction) exitButton
{
	UIApplication *app = [UIApplication sharedApplication];
	[app.delegate applicationWillTerminate:app];
	exit(0);
}

@end


@implementation HikeCamAppDelegate (TimedPhotos)

- (void)startAnimation
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"M-d-Y_hh-mm-ss"];
	self.imageSequenceName = [dateFormatter stringFromDate:[NSDate date]];

	// Create the directory path
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
	self.currentImagePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, imageSequenceName];
	[[NSFileManager defaultManager] createDirectoryAtPath:currentImagePath withIntermediateDirectories:YES attributes:NULL error:NULL];

	animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(animCallback) userInfo:nil repeats:YES];
}

- (void)stopAnimation
{
	[animationTimer invalidate];
	animationTimer = nil;
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	int seconds = interval;
	animationInterval = interval;
	NSLog(@"Setting Interval to: %d seconds", (int)seconds);
	[[mainViewController photoDelayLabel] setText:[NSString stringWithFormat:@"Photo Delay: %d sec", seconds]];

	if(animationTimer) {
		[self stopAnimation];
		[self startAnimation];
	}
}
- (void)animCallback
{
	int seconds = animationInterval;
	NSLog([NSString stringWithFormat:@"Starting to take a photo, interval: %d", seconds]);

	[cameraController capturePhoto:NO];

	//NSDate *nextWake = [NSDate dateWithTimeIntervalSinceNow:(double)animationInterval];
	//IOReturn ret = IOPMSchedulePowerEvent((CFDateRef) nextWake, (CFStringRef)@"HikeCam", CFSTR(kIOPMAutoWakeOrPowerOn));
}

@end




@implementation HikeCamAppDelegate (Camera)


- (void)cameraControllerReadyStateChanged:(NSNotification *)aNotification
{
    NSLog(@"cameraControllerReadyStateChanged: %@", aNotification);
}

-(void) playSound
{
	if (soundEnabled)
		AudioServicesPlaySystemSound(shutterSound);
}

-(void)cameraController:(id)sender
			tookPicture:(UIImage*)picture
			withPreview:(UIImage*)preview
			   jpegData:(NSData*)rawData
		imageProperties:(struct __CFDictionary *)imageProperties
{
	// Stop Timer
	[animationTimer invalidate];

	NSLog([NSString stringWithFormat:@"Taking Photo #: %d", photoNum]);

	[NSThread detachNewThreadSelector:@selector(playSound) toTarget:self withObject:nil];

	mainViewController.lastPhotoView.image = picture;
	NSString *_imageName = [NSString stringWithFormat:@"photo.%05d.png", photoNum];
	NSData *_imageData = [NSData dataWithData:UIImagePNGRepresentation(picture)];

	if (![self writeApplicationData:_imageData toFile:_imageName]) {
	    NSLog(@"Save failed!");
	}

	[mainViewController navigationItem].title = [NSString stringWithFormat:@"Photo #: %d", photoNum];
	photoNum++;

	NSLog(@"Done Taking Photo!");

	//Restart Timer
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(animCallback) userInfo:nil repeats:YES];
}

-(void)cameraController:(id)sender
		addedVideoAtPath:(NSString *)path
	  withPreviewSurface:(id)surface
				metadata:(id)meta
		  wasInterrupted:(BOOL)interrupt
{
	// Do Nothing
}

-(void)cameraController:(id)sender
		  modeDidChange:(int)mode {
	NSLog(@"cameraController:modeDidChange");
}

-(void)cameraControllerVideoCaptureDidStart:(id)sender {
	NSLog(@"cameraControllerVideoCaptureDidStart");
}

-(void)cameraControllerVideoCaptureDidStop:(id)sender {
	NSLog(@"cameraControllerVideoCaptureDidStop");
}

-(void)cameraControllerFocusFinished:(id)sender {
	NSLog(@"cameraControllerFocusFinished");
}

- (BOOL) writeApplicationData:(NSData *)data toFile:(NSString *)fileName {
    NSString *appFile = [currentImagePath stringByAppendingPathComponent:fileName];
    return ([data writeToFile:appFile atomically:YES]);
}

@end
