//
//  FlipsideView.m
//  HikeCam
//
//  Created by Joshua Krall on 11/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "FlipsideView.h"
#import "HikeCamAppDelegate.h"

@implementation FlipsideView

@synthesize appDelegate, soundEnabledSwitch;

- (void)awakeFromNib
{
	// Initialization code
	appDelegate = (HikeCamAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSTimeInterval timedel = [appDelegate animationInterval];

	intervalLabel.text = [NSString stringWithFormat:@"%d", timedel];
	[datePicker setCountDownDuration:timedel*60.0];
	[datePicker setDate:[NSDate dateWithTimeIntervalSinceReferenceDate:timedel*60.0] animated:NO];
}

- (IBAction)respondToDurationChange:(UIDatePicker *)sender
{
	NSTimeInterval countDownDuration = [sender countDownDuration];
	int minutes = (int)(countDownDuration / 60.0) % 60;
	int hours = countDownDuration / 60.0 / 60.0;
	
	double seconds = hours*60.0 + minutes;
	if (seconds < 5)
		seconds = 5;
	
	NSLog(@"Duration Seconds Changed to: %d ... %d:%d, %f", (int)seconds, hours, minutes, countDownDuration);
	if (seconds > 0) {
		intervalLabel.text = [NSString stringWithFormat:@"Seconds: %d", (int)seconds];
		[appDelegate setAnimationInterval:seconds];
	}
}

- (IBAction)respondToSoundEnabledChange:(UISwitch *)sender 
{
	NSLog(@"Sound Enabled Changed to: %d", [sender isOn]);
	appDelegate.soundEnabled = [sender isOn];
}

- (void)dealloc {
    [super dealloc];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
	
	if ([self superview] != nil)
	{
		[soundEnabledSwitch setOn:appDelegate.soundEnabled];
		datePicker.countDownDuration = appDelegate.animationInterval * 60.0;
	}
}


@end
