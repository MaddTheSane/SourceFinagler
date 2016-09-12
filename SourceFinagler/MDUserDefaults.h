//
//  MDUserDefaults.h
//  Font Finagler
//
//  Created by Mark Douma on 1/30/2008.
//  Copyright © 2008-2011 Mark Douma. All rights reserved.
//  


#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, MDUserDefaultsDomain) {
	MDUserDefaultsDomainUser = 1,
	MDUserDefaultsDomainLocal = 2,
	MDUserDefaultsDomainLocalAndUser = 3
};

NS_ASSUME_NONNULL_BEGIN

@interface MDUserDefaults : NSUserDefaults
+ (MDUserDefaults *)standardUserDefaults;

- (void)setObject:(nullable id)anObject forKey:(NSString *)aKey forAppIdentifier:(nullable NSString *)anIdentifier inDomain:(MDUserDefaultsDomain)aDomain;
- (nullable id)objectForKey:(NSString *)aKey forAppIdentifier:(nullable NSString *)anIdentifier inDomain:(MDUserDefaultsDomain)aDomain;
- (void)removeObjectForKey:(NSString *)aKey forAppIdentifier:(nullable NSString *)anIdentifier inDomain:(MDUserDefaultsDomain)aDomain;
@end

NS_ASSUME_NONNULL_END
