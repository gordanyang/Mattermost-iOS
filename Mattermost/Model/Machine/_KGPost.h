// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KGPost.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "KGManagedObject.h"

NS_ASSUME_NONNULL_BEGIN

@class KGUser;
@class KGChannel;

@interface KGPostID : NSManagedObjectID {}
@end

@interface _KGPost : KGManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) KGPostID *objectID;

@property (nonatomic, strong, nullable) NSString* channelId;

@property (nonatomic, strong, nullable) NSDate* createdAt;

@property (nonatomic, strong, nullable) NSDate* deletedAt;

@property (nonatomic, strong, nullable) NSString* identifier;

@property (nonatomic, strong, nullable) NSString* message;

@property (nonatomic, strong, nullable) NSString* type;

@property (nonatomic, strong, nullable) NSDate* updatedAt;

@property (nonatomic, strong, nullable) NSString* userId;

@property (nonatomic, strong, nullable) KGUser *author;

@property (nonatomic, strong, nullable) KGChannel *channel;

@end

@interface _KGPost (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveChannelId;
- (void)setPrimitiveChannelId:(NSString*)value;

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSDate*)primitiveDeletedAt;
- (void)setPrimitiveDeletedAt:(NSDate*)value;

- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;

- (NSString*)primitiveMessage;
- (void)setPrimitiveMessage:(NSString*)value;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (NSString*)primitiveUserId;
- (void)setPrimitiveUserId:(NSString*)value;

- (KGUser*)primitiveAuthor;
- (void)setPrimitiveAuthor:(KGUser*)value;

- (KGChannel*)primitiveChannel;
- (void)setPrimitiveChannel:(KGChannel*)value;

@end

@interface KGPostAttributes: NSObject 
+ (NSString *)channelId;
+ (NSString *)createdAt;
+ (NSString *)deletedAt;
+ (NSString *)identifier;
+ (NSString *)message;
+ (NSString *)type;
+ (NSString *)updatedAt;
+ (NSString *)userId;
@end

@interface KGPostRelationships: NSObject
+ (NSString *)author;
+ (NSString *)channel;
@end

NS_ASSUME_NONNULL_END