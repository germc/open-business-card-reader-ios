/*
	FCName.m

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

#import "FCName.h"

@implementation FCName

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.familyName forKey:@"familyName"];
	[encoder encodeObject:self.givenName forKey:@"givenName"];
	[encoder encodeObject:self.middleName forKey:@"middleName"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super init])) {
		self.familyName = [decoder decodeObjectForKey:@"familyName"];
		self.givenName = [decoder decodeObjectForKey:@"givenName"];
		self.middleName = [decoder decodeObjectForKey:@"middleName"];
	}
	return self;
}

+ (FCName *)instanceFromDictionary:(NSDictionary *)aDictionary {

	FCName *instance = [[FCName alloc] init];
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

	if (self.familyName) {
		[dictionary setObject:self.familyName forKey:@"familyName"];
	}

	if (self.givenName) {
		[dictionary setObject:self.givenName forKey:@"givenName"];
	}

	if (self.middleName) {
		[dictionary setObject:self.middleName forKey:@"middleName"];
	}

	return dictionary;

}

@end
