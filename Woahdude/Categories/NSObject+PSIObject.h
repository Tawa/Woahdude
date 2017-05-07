//
//  NSObject+PSIObject.h
//  SharingConversation
//
//  Created by Tawa on 18/4/17.
//  Copyright © 2017 MobileAppsForEntertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PSIObject) <NSCoding>

/**
 Should Cache Shared Instance

 @return BOOL, default is NO, subclasses must return YES in case they want their sharedInstance to be saved for later use
 */
+(BOOL)shouldCacheSharedInstance;
/**
 Shared Instance
 Returns shared instance that is loaded depending on +(BOOL)shouldCacheSharedInstance method, it's either loaded from the cached file or created programmatically

 @return singleton
 */
+(instancetype)sharedInstance;

/**
 Method used to save sharedInstance to the file named in the class method +fileName
 */
+(void)save;

/**
 Method used to save the object to the file named in the method -fileName
 */
-(void)save;


/**
 initWithDictionary method is used to fill the object properties from a dictionary.
 This is mostly used to parse objects from JSON responses from servers

 @param dictionary - JSON Object to be parsed
 @return instancetype, the object with filled properties
 */
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;


/**
 toParameters is used to transform objects into parameters for API Calls

 @return NSDictionary with key:value from object properties
 */
-(NSDictionary *)toParameters;


/**
 fileName for the object that will be saved locally.

 @return NSString
 */
-(NSString *)fileName;

/**
 fileName for the sharedInstance that will be saved locally

 @return NSString
 */
+(NSString *)fileName;

/**
 loadFromFile is used to load shared instance from fileName returned in +fileName method

 @return instancetype loaded from file or nil
 */
+(instancetype)loadFromFile;

/**
 loadFromFile: is used to load specific object from a specific file

 @param fileName - name of file for the object to be loaded from
 @return instancetype loaded from file or nil
 */
+(instancetype)loadFromFile:(NSString *)fileName;


/**
 propertyKeyMapping is used to specify which name of the property belongs to which parameterName
 Example: If a property is named sessionToken, but on the server is called session_token, we would return the dictionary @{"sessionToken":@"session_token"}

 @return NSDictionary with propertyName:parameterName
 */
+(NSDictionary *)propertyKeyMapping;
+(NSDictionary *)propertyArrayClasses;
+(NSDictionary *)propertyDictionaryClasses;

/**
 Resets the properties of the sharedInstance of that class and saves it

 @param keys - Properties that should not be reset
 */
+(void)resetPropertiesExcept:(NSArray *)keys;

/**
 Resets all the properties of the sharedInstance and saves it
 */
+(void)resetProperties;

/**
 Resets the properties of the sender object and saves it.

 @param keys - Properties that should not be reset
 */
-(void)resetPropertiesExcept:(NSArray *)keys;

/**
 Resets all the properties of the sender object and saves it.
 */
-(void)resetProperties;

-(void)debug_printProperties;

@end
