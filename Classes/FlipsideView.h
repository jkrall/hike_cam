//
//  FlipsideView.h
//  HikeCam
//
//  Created by Joshua Krall on 11/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HikeCamAppDelegate.h"

@interface FlipsideView : UIView 
{
	IBOutlet UIDatePicker *datePicker;
	IBOutlet UILabel *intervalLabel;
	IBOutlet UISwitch *soundEnabledSwitch;
	IBOutlet UISwitch *locationEnabledSwitch;
	HikeCamAppDelegate* appDelegate;
}

@property(retain) HikeCamAppDelegate* appDelegate;
@property(retain) IBOutlet UISwitch *soundEnabledSwitch;

- (IBAction)respondToDurationChange:(UIDatePicker *)sender;
- (IBAction)respondToSoundEnabledChange:(UISwitch *)sender;

@end
