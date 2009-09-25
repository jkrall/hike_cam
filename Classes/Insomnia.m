/*
 Insomnia.app
 Insomnia.m
*/

#import "Insomnia.h"

@implementation Insomnia

// Overridden to prevent terminate (Allows the app to continue to run in the background)
- (void)applicationSuspend:(struct __GSEvent *)fp8	{
	NSLog(@"applicationSuspend... but we won't do it!");
}
- (BOOL)suspendRemainInMemory{
	NSLog(@"suspendRemainInMemory, returning YES");	
	return YES;
}

- (void)applicationDidResume{
	NSLog(@"applicationDidResume... doing nothing.");	
	//On the second launch terminate to turn Insomnia off
	//[self.delegate applicationWillTerminate:self];
	//[self terminate];
}

- (void)applicationWillTerminate
{
	NSLog(@"applicationWillTerminate... doing nothing.");		
}

- (void)applicationWillSuspend
{
	NSLog(@"applicationWillSuspend... doing nothing.");
}

- (void)applicationWillSuspendUnderLock
{
	NSLog(@"applicationWillSuspendUnderLock... doing nothing.");			
	//[self suspendWithAnimation: NO];
}

- (void)applicationWillSuspendForEventsOnly
{
	NSLog(@"applicationWillSuspendForEventsOnly... doing nothing.");				
	//[self suspendWithAnimation: NO];
}

@end
