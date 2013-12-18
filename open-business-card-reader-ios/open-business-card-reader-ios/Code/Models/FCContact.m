/*
	FCContact.m

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

#import "FCContact.h"

#import "FCAccount.h"
#import "FCAddress.h"
#import "FCEmail.h"
#import "FCIm.h"
#import "FCName.h"
#import "FCOrganization.h"
#import "FCPhoneNumber.h"
#import "FCPhoto.h"
#import "FCUrl.h"

@implementation FCContact

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.accounts forKey:@"accounts"];
	[encoder encodeObject:self.addresses forKey:@"addresses"];
	[encoder encodeObject:self.emails forKey:@"emails"];
	[encoder encodeObject:self.ims forKey:@"ims"];
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.organizations forKey:@"organizations"];
	[encoder encodeObject:self.phoneNumbers forKey:@"phoneNumbers"];
	[encoder encodeObject:self.photos forKey:@"photos"];
	[encoder encodeObject:self.urls forKey:@"urls"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super init])) {
		self.accounts = [decoder decodeObjectForKey:@"accounts"];
		self.addresses = [decoder decodeObjectForKey:@"addresses"];
		self.emails = [decoder decodeObjectForKey:@"emails"];
		self.ims = [decoder decodeObjectForKey:@"ims"];
		self.name = [decoder decodeObjectForKey:@"name"];
		self.organizations = [decoder decodeObjectForKey:@"organizations"];
		self.phoneNumbers = [decoder decodeObjectForKey:@"phoneNumbers"];
		self.photos = [decoder decodeObjectForKey:@"photos"];
		self.urls = [decoder decodeObjectForKey:@"urls"];
	}
	return self;
}

+ (FCContact *)instanceFromDictionary:(NSDictionary *)aDictionary {

	FCContact *instance = [[FCContact alloc] init];
	[instance setAttributesFromDictionary:aDictionary];
	return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {

	if (![aDictionary isKindOfClass:[NSDictionary class]]) {
		return;
	}

	[self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forKey:(NSString *)key {

	if ([key isEqualToString:@"accounts"]) {

		if ([value isKindOfClass:[NSArray class]]) {

			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			for (id valueMember in value) {
				FCAccount *populatedMember = [FCAccount instanceFromDictionary:valueMember];
				[myMembers addObject:populatedMember];
			}

			self.accounts = myMembers;

		}

	} else if ([key isEqualToString:@"addresses"]) {

		if ([value isKindOfClass:[NSArray class]]) {

			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			for (id valueMember in value) {
				FCAddress *populatedMember = [FCAddress instanceFromDictionary:valueMember];
				[myMembers addObject:populatedMember];
			}

			self.addresses = myMembers;

		}

	} else if ([key isEqualToString:@"emails"]) {

		if ([value isKindOfClass:[NSArray class]]) {

			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			for (id valueMember in value) {
				FCEmail *populatedMember = [FCEmail instanceFromDictionary:valueMember];
				[myMembers addObject:populatedMember];
			}

			self.emails = myMembers;

		}

	} else if ([key isEqualToString:@"ims"]) {

		if ([value isKindOfClass:[NSArray class]]) {

			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			for (id valueMember in value) {
				FCIm *populatedMember = [FCIm instanceFromDictionary:valueMember];
				[myMembers addObject:populatedMember];
			}

			self.ims = myMembers;

		}

	} else if ([key isEqualToString:@"name"]) {

		if ([value isKindOfClass:[NSDictionary class]]) {
			self.name = [FCName instanceFromDictionary:value];
		}

	} else if ([key isEqualToString:@"organizations"]) {

		if ([value isKindOfClass:[NSArray class]]) {

			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			for (id valueMember in value) {
				FCOrganization *populatedMember = [FCOrganization instanceFromDictionary:valueMember];
				[myMembers addObject:populatedMember];
			}

			self.organizations = myMembers;

		}

	} else if ([key isEqualToString:@"phoneNumbers"]) {

		if ([value isKindOfClass:[NSArray class]]) {

			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			for (id valueMember in value) {
				FCPhoneNumber *populatedMember = [FCPhoneNumber instanceFromDictionary:valueMember];
				[myMembers addObject:populatedMember];
			}

			self.phoneNumbers = myMembers;

		}

	} else if ([key isEqualToString:@"photos"]) {

		if ([value isKindOfClass:[NSArray class]]) {

			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			for (id valueMember in value) {
				FCPhoto *populatedMember = [FCPhoto instanceFromDictionary:valueMember];
				[myMembers addObject:populatedMember];
			}

			self.photos = myMembers;

		}

	} else if ([key isEqualToString:@"urls"]) {

		if ([value isKindOfClass:[NSArray class]]) {

			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			for (id valueMember in value) {
				FCUrl *populatedMember = [FCUrl instanceFromDictionary:valueMember];
				[myMembers addObject:populatedMember];
			}

			self.urls = myMembers;

		}

	} else {
		[super setValue:value forKey:key];
	}

}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	return;
}

- (NSDictionary *)dictionaryRepresentation {

	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

	if (self.accounts) {
		NSMutableArray *tempAccounts = [[NSMutableArray alloc] init];
		for (FCAccount *a in self.accounts) {
			[tempAccounts addObject:[a dictionaryRepresentation]];
		}
		[dictionary setObject:tempAccounts forKey:@"accounts"];
	}

	if (self.addresses) {
		NSMutableArray *tempAddresses = [[NSMutableArray alloc] init];
		for (FCAddress *a in self.addresses) {
			[tempAddresses addObject:[a dictionaryRepresentation]];
		}
		[dictionary setObject:tempAddresses forKey:@"addresses"];
	}

	if (self.emails) {
		NSMutableArray *tempEmails = [[NSMutableArray alloc] init];
		for (FCEmail *e in self.emails) {
			[tempEmails addObject:[e dictionaryRepresentation]];
		}
		[dictionary setObject:tempEmails forKey:@"emails"];
	}

	if (self.ims) {
		NSMutableArray *tempIms = [[NSMutableArray alloc] init];
		for (FCIm *im in self.ims) {
			[tempIms addObject:[im dictionaryRepresentation]];
		}
		[dictionary setObject:tempIms forKey:@"ims"];
	}

	if (self.name) {
		[dictionary setObject:[self.name dictionaryRepresentation] forKey:@"name"];
	}

	if (self.organizations) {
		NSMutableArray *tempOrganizations = [[NSMutableArray alloc] init];
		for (FCOrganization *org in self.organizations) {
			[tempOrganizations addObject:[org dictionaryRepresentation]];
		}
		[dictionary setObject:tempOrganizations forKey:@"organizations"];
	}

	if (self.phoneNumbers) {
		NSMutableArray *tempPhones = [[NSMutableArray alloc] init];
		for (FCPhoneNumber *p in self.phoneNumbers) {
			[tempPhones addObject:[p dictionaryRepresentation]];
		}
		[dictionary setObject:tempPhones forKey:@"phoneNumbers"];
	}

	if (self.photos) {
		NSMutableArray *tempPhotos = [[NSMutableArray alloc] init];
		for (FCPhoto *photo in self.photos) {
			[tempPhotos addObject:[photo dictionaryRepresentation]];
		}
		[dictionary setObject:tempPhotos forKey:@"photos"];
	}

	if (self.urls) {
		NSMutableArray *tempUrls = [[NSMutableArray alloc] init];
		for (FCUrl *u in self.urls) {
			[tempUrls addObject:[u dictionaryRepresentation]];
		}
		[dictionary setObject:tempUrls forKey:@"urls"];
	}

	return dictionary;

}

@end
