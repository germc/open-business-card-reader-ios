/*
	FCAddress.m

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

#import "FCAddress.h"

@implementation FCAddress

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.country forKey:@"country"];
	[encoder encodeObject:self.locality forKey:@"locality"];
	[encoder encodeObject:self.postalCode forKey:@"postalCode"];
	[encoder encodeObject:self.region forKey:@"region"];
	[encoder encodeObject:self.streetAddress forKey:@"streetAddress"];
	[encoder encodeObject:self.type forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super init])) {
		self.country = [decoder decodeObjectForKey:@"country"];
		self.locality = [decoder decodeObjectForKey:@"locality"];
		self.postalCode = [decoder decodeObjectForKey:@"postalCode"];
		self.region = [decoder decodeObjectForKey:@"region"];
		self.streetAddress = [decoder decodeObjectForKey:@"streetAddress"];
		self.type = [decoder decodeObjectForKey:@"type"];
	}
	return self;
}

+ (FCAddress *)instanceFromDictionary:(NSDictionary *)aDictionary {

	FCAddress *instance = [[FCAddress alloc] init];
	[instance setAttributesFromDictionary:aDictionary];
	return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {

	if (![aDictionary isKindOfClass:[NSDictionary class]]) {
		return;
	}

	[self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	return;
}

- (NSDictionary *)dictionaryRepresentation {

	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

	if (self.country) {
		[dictionary setObject:self.country forKey:@"country"];
	}

	if (self.locality) {
		[dictionary setObject:self.locality forKey:@"locality"];
	}

	if (self.postalCode) {
		[dictionary setObject:self.postalCode forKey:@"postalCode"];
	}

	if (self.region) {
		[dictionary setObject:self.region forKey:@"region"];
	}

	if (self.streetAddress) {
		[dictionary setObject:self.streetAddress forKey:@"streetAddress"];
	}

	if (self.type) {
		[dictionary setObject:self.type forKey:@"type"];
	}

	return dictionary;

}

@end
