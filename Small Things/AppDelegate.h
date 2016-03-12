//
//  AppDelegate.h
//  Small Things
//
//  Created by Leonardo S Rangel on 7/13/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL terminated;
@property (nonatomic) BOOL backgroundOnly;
@property (nonatomic) BOOL once;
@property (nonatomic) BOOL first;
@property (nonatomic) BOOL tutorial;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

