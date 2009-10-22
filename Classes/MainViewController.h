//
//  MainViewController.h
//  HikeCam
//
//  Created by Joshua Krall on 11/27/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController {
	UIView *previewView;
	UILabel *photoDelayLabel;
	UIImageView *lastPhotoView;
	UIButton *takingPhotoButton;
}

@property (nonatomic, retain) IBOutlet UIView *previewView;
@property (nonatomic, retain) IBOutlet UILabel *photoDelayLabel;
@property (nonatomic, retain) IBOutlet UIImageView *lastPhotoView;

@end
