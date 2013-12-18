/*
	FCCardReaderHelper.h

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

#import <Foundation/Foundation.h>

#import "FCAPI+CardReader.h"

UIKIT_EXTERN NSString *const kAPIKey;

UIKIT_EXTERN NSString *const kCardStatusProcessing;
UIKIT_EXTERN NSString *const kCardStatusCallbackMade;
UIKIT_EXTERN NSString *const kCardStatusCallbackMadeNotProcessable;
UIKIT_EXTERN NSString *const kCardStatusCallbackFailedNotProcessable;
UIKIT_EXTERN NSString *const kCardStatusCallbackFailed;

@interface FCCardReaderHelper : NSObject

/**
 * Intitializes the shared instance of the FCCardReaderHelper class
 *
 * @return The shared instance of the FCCardReaderHelper class
 */
+ (FCCardReaderHelper *)sharedInstance;

/**
 * Submits a card to the Card Reader API
 *
 * @param frontImage The front image of the card
 * @param backImage The back image of the card
 * @param parameters Values to send to the Card Reader API for processing
 * @param success A block that is evaluated when the card has been successfully submitted
 * @param failure A block that is evaluated if the card submission fails
 */
- (void) submitCardWithFrontImage:(UIImage*)frontImage
					 andBackImage:(UIImage*)backImage
					andParameters:(NSDictionary*)parameters
						  success:(FCSuccessBlock)success
						  failure:(FCFailureBlock)failure;

/**
 * Retrieves the statuses of cards submitted to the Card Reader API
 *
 * @param identifiers An array of cardIds to check status on
 * @param success A block that is evaluated when updates have been received from the server.  Returns an NSDictionary with cardIds as Keys and the response payload as the Value
 * @param failure A block that is evaluated if the update fetch fails.  Returns the error that occured.
 */
- (void) fetchUpdatesForCardIdentifiers:(NSArray*)identifiers
								success:(void (^)(NSDictionary* updates))success
								failure:(void (^)(NSError *error))failure;

@end
