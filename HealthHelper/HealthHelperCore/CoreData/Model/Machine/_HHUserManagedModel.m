// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HHUserManagedModel.m instead.

#import "_HHUserManagedModel.h"

@implementation HHUserManagedModelID
@end

@implementation _HHUserManagedModel

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"HHUserManagedModel" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"HHUserManagedModel";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"HHUserManagedModel" inManagedObjectContext:moc_];
}

- (HHUserManagedModelID*)objectID {
	return (HHUserManagedModelID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic birthday;

@dynamic dataId;

@dynamic email;

@dynamic firstName;

@dynamic lastName;

@end

@implementation HHUserManagedModelAttributes 
+ (NSString *)birthday {
	return @"birthday";
}
+ (NSString *)dataId {
	return @"dataId";
}
+ (NSString *)email {
	return @"email";
}
+ (NSString *)firstName {
	return @"firstName";
}
+ (NSString *)lastName {
	return @"lastName";
}
@end

