/*
	CardCell.h

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
#import "Card.h"

@interface CardCell : UITableViewCell

@property(nonatomic) Card *card;

@property(weak, nonatomic) IBOutlet UIImageView *avatar;

@property(weak, nonatomic) IBOutlet UIView *statusView;
@property(weak, nonatomic) IBOutlet UILabel *statusLabel;

@property(weak, nonatomic) IBOutlet UIView *contactView;
@property(weak, nonatomic) IBOutlet UILabel *contactName;

- (void)configureWithCard:(Card *)card;

@end
