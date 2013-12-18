/*
	CardListViewController.m

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

#import "CardListViewController.h"
#import "AppDelegate.h"
#import "CardDetailViewController.h"
#import "UIColor+FullContact.h"
#import "Card.h"
#import "CardCell.h"
#import "FCCardReaderHelper.h"

@interface CardListViewController ()

@property(nonatomic, strong) UIPopoverController *captureViewPopover;
@property(nonatomic, retain) id detailItem;

@end

@implementation CardListViewController

- (void)awakeFromNib
{
	NSAssert(kAPIKey, @"An API key must be set in FCCardReaderHelper.m order to run the application");
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		self.clearsSelectionOnViewWillAppear = NO;
		self.preferredContentSize = CGSizeMake(320.0, 600.0);
	}
	[super awakeFromNib];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.leftBarButtonItem = self.editButtonItem;

	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame:CGRectMake(0.0f, 0.0f, 35.0f, 25.0f)];
	[button addTarget:self action:@selector(insertNewObject:) forControlEvents:UIControlEventTouchUpInside];
	[button setImage:[UIImage imageNamed:@"icon-camera-only"] forState:UIControlStateNormal];
	[button.imageView setTintColor:[UIColor fullContactOrangeColor]];
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:button];

	self.navigationItem.rightBarButtonItem = addButton;
	self.detailViewController = (CardDetailViewController *) [[self.splitViewController.viewControllers lastObject] topViewController];

	[self.refreshControl addTarget:self action:@selector(forcePull)
	              forControlEvents:UIControlEventValueChanged];
}

- (void)forcePull
{
	//Here we get updates for all the cards in our data source

	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Card class]) inManagedObjectContext:__managedObjectContext];
	NSFetchRequest *request = [NSFetchRequest new];
	[request setEntity:entity];
	request.predicate = [NSPredicate predicateWithFormat:@"status == %@", kCardStatusProcessing];
	NSError *err = nil;
	NSArray *cards = [__managedObjectContext executeFetchRequest:request error:&err];

	NSMutableSet *identifiers = [NSMutableSet new];

	[cards enumerateObjectsUsingBlock:^(Card *obj, NSUInteger idx, BOOL *stop)
	{
		[identifiers addObject:obj.cardId];
	}];

	[[FCCardReaderHelper sharedInstance] fetchUpdatesForCardIdentifiers:[identifiers allObjects] success:^(NSDictionary *updates)
	{

		[updates enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
		{
			NSPredicate *keyPredicate = [NSPredicate predicateWithFormat:
					@"cardId == %@", key];
			NSArray *predicateResults = [cards filteredArrayUsingPredicate:keyPredicate];
			[predicateResults enumerateObjectsUsingBlock:^(Card *c, NSUInteger idx, BOOL *s)
			{
				c.status = obj[@"status"];
				c.response = [NSKeyedArchiver archivedDataWithRootObject:obj];
				NSError *e;
				if (![__managedObjectContext save:&e]) {
					NSLog(@"Error updating cardId: %@, %@", c.cardId, e.localizedDescription);
				} else {
					NSLog(@"Succesfully updated cardId: %@", c.cardId);
				}

			}];
		}];

		[self.refreshControl endRefreshing];
	} failure:^(NSError *error)
	{
		[self.refreshControl endRefreshing];
	}];


}

- (void)insertNewObject:(id)sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][(NSUInteger) section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCell" forIndexPath:indexPath];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 70;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
		[context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];

		NSError *error = nil;
		if (![context save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	// The table view should not be re-orderable.
	return NO;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	_detailItem = object;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		self.detailViewController.detailItem = object;
	} else {
		[self performSegueWithIdentifier:@"showDetail" sender:self];
	}

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
		[[segue destinationViewController] setDetailItem:_detailItem];
		_detailItem = nil;
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
	_detailItem = image;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		self.detailViewController.detailItem = _detailItem;
		[_captureViewPopover dismissPopoverAnimated:YES];
	} else {
		[self performSegueWithIdentifier:@"showDetail" sender:self];
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:__managedObjectContext];
	[fetchRequest setEntity:entity];

	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];

	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"captureDate" ascending:NO];
	NSArray *sortDescriptors = @[sortDescriptor];

	[fetchRequest setSortDescriptors:sortDescriptors];

	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}

	return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
	switch (type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
	        break;

		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
	        break;
		case NSFetchedResultsChangeMove:
			break;
		case NSFetchedResultsChangeUpdate:
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
	UITableView *tableView = self.tableView;

	switch (type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
	        break;

		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	        break;

		case NSFetchedResultsChangeUpdate:
			[self configureCell:(CardCell *) [tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
	        break;

		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	        [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
	        break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(CardCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
{
	Card *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell configureWithCard:card];
}

@end
