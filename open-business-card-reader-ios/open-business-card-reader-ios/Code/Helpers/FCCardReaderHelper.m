/*
	FCCardReaderHelper.m

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

#import "FCCardReaderHelper.h"
#import "FCAPI+CardReader.h"
#import "FCAPI+Batch.h"
#import "FCResponse.h"

NSString *const kAPIUrl = @"https://api.fullcontact.com";
NSString *const kAPIVersion = @"v2";
NSString *const kAPIKey = nil;  //TODO:  Enter your API key here

NSString *const kCardStatusProcessing = @"PROCESSING";
NSString *const kCardStatusCallbackMade = @"CALLBACK_MADE";
NSString *const kCardStatusCallbackMadeNotProcessable = @"CALLBACK_MADE_NOT_PROCESSABLE";
NSString *const kCardStatusCallbackFailedNotProcessable  = @"CALLBACK_FAILED_NOT_PROCESSABLE";
NSString *const kCardStatusCallbackFailed = @"CALLBACK_FAILED";

#define kCardReaderAPIUrl @"https://api.fullcontact.com/v2/cardShark/%@"
#define kSFDCServiceWebHook @"https://sfdc-api.fullcontact.com/sfdc-api/cardReader/webhook"

static NSUInteger const BatchSize = 20;


@implementation FCCardReaderHelper {
	dispatch_queue_t _batchQueue;
}

static FCAPI *api;

+ (FCCardReaderHelper *)sharedInstance
{
    static FCCardReaderHelper *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
        api = [[FCAPI alloc] initWithBaseURL:[NSURL URLWithString:kAPIUrl] andVersion:kAPIVersion andAPIKey:kAPIKey];
		
		NSString *appVersion = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
		NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
		
		[api setDefaultHeader:@"X-FC-PRODUCT" value:@"Open Card Reader"];
		[api setDefaultHeader:@"X-FC-PLATFORM" value:@"ios"];
		[api setDefaultHeader:@"X-FC-PRODUCT-VERSION" value:[NSString stringWithFormat:@"%@ (%@)", appVersion, build]];
		[api setDefaultHeader:@"X-FC-PLATFORM-VERSION" value:[[UIDevice currentDevice] systemVersion]];
		api.userAgent = [NSString stringWithFormat:@" Open Card Reader %@ (%@)", appVersion, build];
		sharedInstance->_batchQueue = dispatch_queue_create("com.fullcontact.responsequeue", NULL);
    });
    return sharedInstance;
}

- (void) submitCardWithFrontImage:(UIImage*)frontImage
					 andBackImage:(UIImage*)backImage
					andParameters:(NSDictionary*)parameters
						  success:(FCSuccessBlock)success
						  failure:(FCFailureBlock)failure
{
	NSParameterAssert(frontImage);
	NSParameterAssert(success);
	NSParameterAssert(failure);
	
	NSMutableDictionary *mutableParameters =
	(parameters) ? [NSMutableDictionary dictionaryWithDictionary:parameters] : [NSMutableDictionary new];
	
	[mutableParameters setObject:@"medium" forKey:@"verified"];
	[mutableParameters setObject:@"casing" forKey:@"titlecase"];
	
	[api uploadCard:UIImageJPEGRepresentation(frontImage, 0.5)
			andBack:(backImage) ? UIImageJPEGRepresentation(backImage, 0.5) : nil
	 withParameters:parameters
	  andWebhookUrl:kSFDCServiceWebHook
			success:^(FCResponse *response) {
				success(response);
			} failure:^(FCResponse *response, NSError *error) {
				failure(response, error);
			}];
}

- (void) fetchUpdatesForCardIdentifiers:(NSArray*)identifiers
								success:(void (^)(NSDictionary* updates))success
								failure:(void (^)(NSError *error))failure {

	NSParameterAssert(identifiers);
	
	if (identifiers.count == 0) {
		if (success)
			dispatch_async(dispatch_get_main_queue(), ^{
				success(nil);
			});
		return;
	}

	//Step 1:  Build your batch of requests
	NSMutableSet *requests = [NSMutableSet new];
	[identifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[requests addObject:[NSString stringWithFormat:kCardReaderAPIUrl, obj]];
	}];
	NSArray *uniqueRequests = [requests allObjects];

	NSUInteger batchCount = (NSUInteger) ceil(uniqueRequests.count / (double) BatchSize);
	__block NSUInteger batchesToGo = batchCount;
	__block NSMutableDictionary *methodResponse = [NSMutableDictionary dictionaryWithCapacity:identifiers.count];
	__block BOOL anyRequestFailed = NO;
	for (NSUInteger i = 0; i < batchCount; i++) {
		NSRange range = NSMakeRange(i * BatchSize, MIN(uniqueRequests.count - i * BatchSize, BatchSize));
		NSArray *currentBatch = [uniqueRequests subarrayWithRange:range];

		[api batch:currentBatch success:^(FCResponse *response) {
			dispatch_async(_batchQueue, ^{
				if (anyRequestFailed) return;

				NSDictionary *responses = (NSDictionary *) [response.response objectForKey:@"responses"];
				[responses enumerateKeysAndObjectsUsingBlock:^(id key, id result, BOOL *stop) {
					[methodResponse setObject:result forKey:result[@"id"]];
				}];

				if (--batchesToGo == 0) {
					dispatch_async(dispatch_get_main_queue(), ^{
						success(methodResponse);
					});
				}
			});
		} failure:^(FCResponse *response, NSError *error) {
			dispatch_async(_batchQueue, ^{
				if (anyRequestFailed) return;
				anyRequestFailed = YES;

				if (failure) {
					dispatch_async(dispatch_get_main_queue(), ^{
						failure(error);
					});
				}
			});
		}];
	}
}


@end
