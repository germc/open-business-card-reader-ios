/*
	CardCell.m

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

#import "CardCell.h"
#import "UIImage+Sizing.h"
#import "FCCardReaderHelper.h"

#import "FCContact.h"
#import "FCName.h"
#import "FCOrganization.h"

@implementation CardCell

- (void)configureWithCard:(Card *)card
{
	_card = card;

	_statusView.hidden = _contactView.hidden = YES;

	_avatar.image = [UIImage circularScaleAndCrop:[UIImage imageWithData:card.frontImage] withRect:_avatar.bounds];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];

	NSString *formattedDateString = [dateFormatter stringFromDate:card.captureDate];

	if ([card.status isEqualToString:kCardStatusProcessing]) {
		_statusView.hidden = NO;
		_statusLabel.attributedText = [self getAttributedLabel:@"Transcribing..." withSubtitle:formattedDateString];
	} else if ([card.status isEqualToString:kCardStatusCallbackMade]) {
		_contactView.hidden = NO;
		NSDictionary *response = [NSKeyedUnarchiver unarchiveObjectWithData:card.response];
		if (response) {
			NSDictionary *contactDictionary = response[@"contact"];
			if (contactDictionary)
				_contactName.attributedText = [self processAttributedLabel:contactDictionary];
		}
	} else {

		_statusView.hidden = NO;

		if ([card.status isEqualToString:kCardStatusCallbackMadeNotProcessable]) {
			_statusLabel.attributedText = [self getAttributedLabel:@"Not Processable (Callback Made)" withSubtitle:formattedDateString];
		} else if ([card.status isEqualToString:kCardStatusCallbackFailedNotProcessable]) {
			_statusLabel.attributedText = [self getAttributedLabel:@"Not Processable (Callback Failed)" withSubtitle:formattedDateString];
		} else if ([card.status isEqualToString:kCardStatusCallbackFailed]) {
			_statusLabel.attributedText = [self getAttributedLabel:@"Callback Failed" withSubtitle:formattedDateString];
		} else {
			_statusLabel.attributedText = [self getAttributedLabel:@"Failed" withSubtitle:formattedDateString];
		}

	}
}

- (NSMutableAttributedString *)getAttributedLabel:(NSString *)title
                                     withSubtitle:(NSString *)subTitle
{

	NSAssert(title, @"title cannot be nil");
	NSAssert(subTitle, @"subTitle cannot be nil");
	NSMutableArray *components = [NSMutableArray arrayWithArray:@[title, subTitle]];

	NSMutableAttributedString *returnValue = [[NSMutableAttributedString alloc] initWithString:[components componentsJoinedByString:@"\n"]];
	[returnValue addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] range:NSMakeRange(title.length, returnValue.length - title.length)];
	return returnValue;
}

- (NSMutableAttributedString *)processAttributedLabel:(NSDictionary *)contact
{

	NSAssert(contact, @"contact cannot be nil");
	FCContact *c = [FCContact instanceFromDictionary:contact];

	NSMutableArray *components = [NSMutableArray new];
	NSMutableArray *processedName = [NSMutableArray new];
	NSString *name;
	if ([contact valueForKeyPath:@"name.givenName"])
		[processedName addObject:c.name.givenName];
	if ([contact valueForKeyPath:@"name.middleName"])
		[processedName addObject:c.name.middleName];
	if ([contact valueForKeyPath:@"name.familyName"])
		[processedName addObject:c.name.familyName];

	name = [processedName componentsJoinedByString:@" "];
	[components addObject:name];

	NSString *search = [components[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

	if ([search length] == 0) {
		components[0] = @"Unknown";
	}

	if (c.organizations.count > 0) {
		FCOrganization *o = c.organizations[0];
		if (o.name)
			[components addObject:o.name];
		if (o.title)
			[components addObject:o.title];

	}

	NSMutableAttributedString *returnValue = [[NSMutableAttributedString alloc] initWithString:[components componentsJoinedByString:@"\n"]];
	[returnValue addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] range:NSMakeRange(name.length, returnValue.length - name.length)];
	return returnValue;
}

@end
