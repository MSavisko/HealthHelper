// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HHUserManagedModel.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface HHUserManagedModelID : NSManagedObjectID {}
@end

@interface _HHUserManagedModel : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) HHUserManagedModelID *objectID;

@property (nonatomic, strong, nullable) NSDate* birthday;

@property (nonatomic, strong, nullable) NSString* dataId;

@property (nonatomic, strong, nullable) NSString* email;

@property (nonatomic, strong, nullable) NSString* firstName;

@property (nonatomic, strong, nullable) NSString* lastName;

@end

@interface _HHUserManagedModel (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSDate*)primitiveBirthday;
- (void)setPrimitiveBirthday:(nullable NSDate*)value;

- (nullable NSString*)primitiveDataId;
- (void)setPrimitiveDataId:(nullable NSString*)value;

- (nullable NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(nullable NSString*)value;

- (nullable NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(nullable NSString*)value;

- (nullable NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(nullable NSString*)value;

@end

@interface HHUserManagedModelAttributes: NSObject 
+ (NSString *)birthday;
+ (NSString *)dataId;
+ (NSString *)email;
+ (NSString *)firstName;
+ (NSString *)lastName;
@end

NS_ASSUME_NONNULL_END
