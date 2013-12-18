/*
	CardDetailViewController.m

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

#import "AppDelegate.h"
#import "CardDetailViewController.h"
#import "FCCardReaderHelper.h"
#import "FCResponse.h"
#import "Card.h"
#import "UIColor+FullContact.h"

@interface CardDetailViewController ()

@property(strong, nonatomic) UIPopoverController *masterPopoverController;

@property(nonatomic, strong) UIPopoverController *captureViewPopover;
@property(nonatomic, strong) UIView *maskView;
@property(nonatomic) BOOL isCapturingFront;

- (void)configureView;

@end

@implementation CardDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)detailItem
{
	if (_detailItem != detailItem) {
		_detailItem = detailItem;
		[self configureView];
	}

	if (self.masterPopoverController != nil) {
		[self.masterPopoverController dismissPopoverAnimated:YES];
	}
}

- (void)configureView
{
	_cardFront.image = nil;
	_cardBack.image = nil;
	_notes.text = nil;
	_responseText.text = nil;
	_responseView.hidden = YES;

	if (_maskView) {
		[_maskView removeFromSuperview];
		_maskView = nil;
	}

	if (_detailItem && [_detailItem isKindOfClass:[UIImage class]]) {
		_cardFront.image = _detailItem;
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitCard:)];
		[self.navigationItem setRightBarButtonItem:button];
		_notes.userInteractionEnabled = YES;
		_chooseFront.hidden = _chooseBack.hidden = NO;
	} else if (_detailItem && [_detailItem isKindOfClass:[Card class]]) {
		Card *card = _detailItem;
		_cardFront.image = [UIImage imageWithData:card.frontImage];
		_cardBack.image = [UIImage imageWithData:card.backImage];
		_notes.text = card.notes;
		_notes.userInteractionEnabled = NO;
		_chooseFront.hidden = _chooseBack.hidden = YES;

		if (card.response) {
			_responseView.hidden = NO;
			NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:card.response];
			_responseText.text = [dictionary description];
			[_responseText setContentSize:CGSizeMake(2000, _responseText.contentSize.height)];
		}
	} else if (!_detailItem && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		_maskView = [[UIView alloc] initWithFrame:self.view.frame];
		_maskView.backgroundColor = [UIColor whiteColor];
		UILabel *takePhotoLabel = [[UILabel alloc] initWithFrame:_maskView.frame];
		takePhotoLabel.text = @"Choose a photo to see Card Details";
		takePhotoLabel.textColor = [UIColor fullContactGreenColor];
		takePhotoLabel.textAlignment = NSTextAlignmentCenter;
		
		[takePhotoLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
		
		[_maskView addSubview:takePhotoLabel];
		
		NSLayoutConstraint *centerYConstraint =
		[NSLayoutConstraint constraintWithItem:takePhotoLabel
									 attribute:NSLayoutAttributeCenterY
									 relatedBy:NSLayoutRelationEqual
										toItem:self.view
									 attribute:NSLayoutAttributeCenterY
									multiplier:1.0
									  constant:0.0];
		[self.view addConstraint:centerYConstraint];
		
		// Center Horizontally
		NSLayoutConstraint *centerXConstraint =
		[NSLayoutConstraint constraintWithItem:takePhotoLabel
									 attribute:NSLayoutAttributeCenterX
									 relatedBy:NSLayoutRelationEqual
										toItem:self.view
									 attribute:NSLayoutAttributeCenterX
									multiplier:1.0
									  constant:0.0];
		[self.view addConstraint:centerXConstraint];
		
		[self.view addSubview:_maskView];
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self configureView];
}

- (void)viewWillAppear:(BOOL)animated
{

}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
		  withBarButtonItem:(UIBarButtonItem *)barButtonItem
	   forPopoverController:(UIPopoverController *)popoverController
{
	barButtonItem.title = NSLocalizedString(@"Cards", @"Cards");
	[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
	self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	// Called when the view is shown again in the split view, invalidating the button and popover controller.
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	self.masterPopoverController = nil;
}


#pragma mark - Actions

- (IBAction)submitCard:(id)sender
{
	[self.view endEditing:YES];
	[self applyWaitActivityIndicator];

	NSDictionary *parameters = (_notes.text) ? @{@"notes" : _notes.text} : nil;

	[[FCCardReaderHelper sharedInstance] submitCardWithFrontImage:_cardFront.image andBackImage:_cardBack.image andParameters:parameters success:^(FCResponse *response) {
		NSDictionary *serverResponse = response.response;

		//Save the data locally
		if (serverResponse && ([serverResponse[@"status"] intValue] == 202)) {

			Card *card = (Card *) [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:__managedObjectContext];
			card.cardId = serverResponse[@"id"];
			card.frontImage = UIImageJPEGRepresentation(_cardFront.image, 0.5);
			if (_cardBack.image)
				card.backImage = UIImageJPEGRepresentation(_cardBack.image, 0.5);
			card.notes = (_notes.text) ? _notes.text : nil;
			card.captureDate = [NSDate date];
			card.response = [NSKeyedArchiver archivedDataWithRootObject:serverResponse];

			NSError *e;
			if (![__managedObjectContext save:&e]) {
				NSLog(@"Error: %@", e.localizedDescription);
			} else {
				NSLog(@"Succesfully submitted cardId: %@", card.cardId);
				if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
					[self removeWaitActivityIndicator];
					_detailItem = card;
					[self configureView];
				} else {
					[self.navigationController dismissViewControllerAnimated:YES completion:nil];
				}
				[self.navigationController popViewControllerAnimated:YES];
			}
		}

	} failure:^(FCResponse *response, NSError *error) {
		NSLog(@"Failure submitting Card");
		[self removeWaitActivityIndicator];
	}];

}

- (IBAction)chooseFront:(id)sender
{
	_isCapturingFront = YES;
	[self insertNewObject:sender];
}

- (IBAction)chooseBack:(id)sender
{
	_isCapturingFront = NO;
	[self insertNewObject:sender];
}

- (void)insertNewObject:(id)sender
{
	FCImageCaptureViewController *imageCaptureController = [FCImageCaptureViewController new];
	imageCaptureController.delegate = self;

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		_captureViewPopover = [[UIPopoverController alloc] initWithContentViewController:imageCaptureController];
		[_captureViewPopover setPopoverContentSize:CGSizeMake(320, 580)];

		[_captureViewPopover
				presentPopoverFromRect:((UIControl *) sender).frame inView:self.view
			  permittedArrowDirections:UIPopoverArrowDirectionAny
							  animated:YES];
	}
	else {
		[self presentViewController:imageCaptureController animated:YES completion:nil];
	}
}

#pragma mark - ImageCaptureViewControllerDelegate

- (void)imageCaptureControllerCancelledCapture:(FCImageCaptureViewController *)controller
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		[_captureViewPopover dismissPopoverAnimated:YES];
	} else {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)imageCaptureController:(FCImageCaptureViewController *)controller
                 capturedImage:(UIImage *)image
{
	if (_isCapturingFront) {
		_cardFront.image = image;
	} else {
		_cardBack.image = image;
	}

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		[_captureViewPopover dismissPopoverAnimated:YES];
	} else {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}
}


- (void)applyWaitActivityIndicator
{
	self.view.userInteractionEnabled = NO;
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[activityIndicator setColor:[UIColor fullContactGreenColor]];
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	self.navigationItem.rightBarButtonItem = barButton;
	[activityIndicator startAnimating];
}

- (void)removeWaitActivityIndicator
{
	self.view.userInteractionEnabled = YES;
	[self.navigationItem setRightBarButtonItem:nil];
}

@end
