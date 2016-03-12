//
//  SmallThing+CoreDataProperties.h
//  Small Things
//
//  Created by Leonardo Silva Rangel on 9/17/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SmallThing.h"

NS_ASSUME_NONNULL_BEGIN

@interface SmallThing (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *smallaudio;
@property (nullable, nonatomic, retain) NSData *smallphoto;
@property (nullable, nonatomic, retain) NSString *smalltext;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSDate *smalldate;
@property (nullable, nonatomic, retain) Person *person;

@end

NS_ASSUME_NONNULL_END
