//
//  NSObject+PSIObject.m
//  SharingConversation
//
//  Created by Tawa on 18/4/17.
//  Copyright © 2017 MobileAppsForEntertainment. All rights reserved.
//

#import "NSObject+PSIObject.h"
#import <objc/runtime.h>

@implementation NSObject (PSIObject)

+(NSMutableDictionary *)sharedInstances
{
	static NSMutableDictionary *instances;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instances = [NSMutableDictionary dictionary];
	});
	
	return instances;
}

+(instancetype)sharedInstance
{
	static id object;
	
	NSMutableDictionary *instances = [self sharedInstances];
	NSString *key = NSStringFromClass([self class]);
	object = instances[key];
	if (object == nil) {
		if ([self shouldCacheSharedInstance]) {
			object = [self loadFromFile:[self fileName]];
		}
		if (object == nil) {
			object = [self new];
		}
		[instances setObject:object forKey:key];
	}
	
	return object;
}

-(void)enumerateProperties:(void(^)(NSString *key, id value))action
{
	unsigned int count;
	objc_property_t *properties = class_copyPropertyList([self class], &count);
	
	for (int i = 0; i < count; i++) {
		NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
		id value = [self valueForKey:key];
		action(key, value);
	}
	
	free(properties);
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [self init];
	if (self) {
		NSDictionary *map = [[self class] propertyKeyMapping];
		[self enumerateProperties:^(NSString *key, id value) {
			NSString *k = [map objectForKey:key];
			
			id newValue;
			NSString *newKey = k?k:key;
			
			newValue = dictionary[newKey];
			
			if (newValue) {
				Class class = [[self class] propertyArrayClasses][newKey];
				if (class) {
					NSMutableArray *mutableArray = [NSMutableArray array];
					NSArray *array = newValue;
					for (int i = 0; i < [array count]; i++) {
						id obj = [[class alloc] initWithDictionary:array[i]];
						[mutableArray insertObject:obj atIndex:i];
					}
					newValue = [mutableArray copy];
				} else {
					class = [[self class] propertyDictionaryClasses][newKey];
					if (class) {
						NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
						NSDictionary *dictionary = newValue;
						NSArray *allKeys = [dictionary allKeys];
						for (int i = 0; i < [allKeys count]; i++) {
							NSString *dictionaryKey = [allKeys objectAtIndex:i];
							id obj = dictionary[dictionaryKey];
							[mutableDictionary setValue:obj forKey:dictionaryKey];
						}
						newValue = [mutableDictionary copy];
					}
				}
			}
			
			[self setValue:newValue forKey:key];
		}];
	}
	
	return self;
}

-(NSDictionary *)toParameters
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	
	NSDictionary *map = [[self class] propertyKeyMapping];
	
	[self enumerateProperties:^(NSString *key, id value) {
		if (value != nil) {
			NSString *k = [map objectForKey:key];
			if (k) {
				[dictionary setValue:value forKey:k];
			} else {
				[dictionary setValue:value forKey:key];
			}
		}
	}];
	
	return [dictionary copy];
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[self enumerateProperties:^(NSString *key, id value) {
		[aCoder encodeObject:value forKey:key];
	}];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [self init];
	if (self) {
		[self enumerateProperties:^(NSString *key, id value) {
			[self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
		}];
	}
	
	return self;
}

+(BOOL)shouldCacheSharedInstance
{
	return NO;
}

-(void)save
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
	[data writeToFile:[[self class] filePath:[self fileName]] atomically:YES];
}

+(void)save
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[self sharedInstance]];
	[data writeToFile:[[self class] filePath] atomically:YES];
}

-(NSString *)fileName
{
	NSAssert(NO, @"Must implement this method");
	return @"";
}
 +(NSString *)fileName
{
	NSAssert(NO, @"Must implement this method");
	return @"";
}

+(instancetype)loadFromFile:(NSString *)fileName
{
	NSData *decodedData = [NSData dataWithContentsOfFile:[self filePath:fileName]];
	if (decodedData) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
	}
	return nil;
}

+(instancetype)loadFromFile
{
	return [self loadFromFile:[[self class] fileName]];
}

+(NSString *)filePath:(NSString *)fileName
{
	return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", NSStringFromClass([self class]), fileName]];
}

+(NSString *)filePath
{
	return [self filePath:[[self class] fileName]];
}

+(NSDictionary *)propertyKeyMapping
{
	return @{};
}

+(NSDictionary *)propertyArrayClasses
{
	return @{};
}

+(NSDictionary *)propertyDictionaryClasses
{
	return @{};
}

+(void)resetObject:(NSObject *)object except:(NSArray *)keys
{
	[object enumerateProperties:^(NSString *key, id value) {
		if (!keys || ![keys containsObject:key]) {
			if ([value isKindOfClass:[NSNumber class]]) {
				[object setValue:[NSNumber numberWithInt:0] forKey:key];
			} else {
				[object setValue:nil forKey:key];
			}
		}
	}];

}

+(void)resetPropertiesExcept:(NSArray *)keys
{
	[self resetObject:[[self class] sharedInstance] except:keys];
	
	[[self class] save];
}

+(void)resetProperties
{
	[self resetPropertiesExcept:nil];
}

-(void)resetPropertiesExcept:(NSArray *)keys
{
	[[self class] resetObject:self except:keys];
	
	[self save];
}

-(void)resetProperties
{
	[self resetPropertiesExcept:nil];
}

-(void)debug_printProperties
{
	NSLog(@"Describing %@ Object %@", NSStringFromClass([self class]), self);
	[self enumerateProperties:^(NSString *key, id value) {
		NSLog(@"\t\t%@: %@ = %@", [value class], key,value);
	}];
	NSLog(@"End of Description");
}

@end
