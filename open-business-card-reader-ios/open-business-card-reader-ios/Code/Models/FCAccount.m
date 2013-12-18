/*
	FCAccount.m

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

#import "FCAccount.h"

@implementation FCAccount

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.domain forKey:@"domain"];
	[encoder encodeObject:self.urlString forKey:@"urlString"];
	[encoder encodeObject:self.username forKey:@"username"];
	[encoder encodeObject:self.userId forKey:@"userid"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super init])) {
		self.domain = [decoder decodeObjectForKey:@"domain"];
		self.urlString = [decoder decodeObjectForKey:@"urlString"];
		self.username = [decoder decodeObjectForKey:@"username"];
		self.userId = [decoder decodeObjectForKey:@"userid"];
	}
	return self;
}

+ (FCAccount *)instanceFromDictionary:(NSDictionary *)aDictionary {

	FCAccount *instance = [[FCAccount alloc] init];
	[instance setAttributesFromDictionary:aDictionary];
	return instance;

}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	return;
}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {

	if (![aDictionary isKindOfClass:[NSDictionary class]]) {
		return;
	}

	[self setValuesForKeysWithDictionary:aDictionary];

}

- (NSDictionary *)dictionaryRepresentation {

	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

	if (self.domain) {
		[dictionary setObject:self.domain forKey:@"domain"];
	}

	if (self.urlString) {
		[dictionary setObject:self.urlString forKey:@"urlString"];
	}

	if (self.username) {
		[dictionary setObject:self.username forKey:@"username"];
	}

	if (self.userId) {
		[dictionary setObject:self.userId forKey:@"userid"];
	}

	return dictionary;

}

@end
