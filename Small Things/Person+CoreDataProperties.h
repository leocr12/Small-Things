//
//  Person+CoreDataProperties.h
//  Small Things
//
//  Created by Leonardo Silva Rangel on 9/17/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSDate *persondate;
@property (nullable, nonatomic, retain) SmallThing *smallthing;

@end

NS_ASSUME_NONNULL_END
