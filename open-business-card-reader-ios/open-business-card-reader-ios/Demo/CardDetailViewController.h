/*
	CardDetailViewController.h

	Created by Duane Schleen on 12/17/13.
	Copyright (c) 2013 FullContact Inc.

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	you may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "FCImageCaptureViewController.h"

@interface CardDetailViewController : UIViewController <UISplitViewControllerDelegate, FCImageCaptureViewControllerDelegate>

@property(strong, nonatomic) id detailItem;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *submitCard;
@property(weak, nonatomic) IBOutlet UIImageView *cardFront;
@property(weak, nonatomic) IBOutlet UIImageView *cardBack;
@property(weak, nonatomic) IBOutlet UIButton *chooseFront;
@property(weak, nonatomic) IBOutlet UIButton *chooseBack;
@property(weak, nonatomic) IBOutlet UITextView *notes;

@property(weak, nonatomic) IBOutlet UIView *responseView;
@property(weak, nonatomic) IBOutlet UITextView *responseText;

- (IBAction)chooseFront:(id)sender;

- (IBAction)chooseBack:(id)sender;

@end
