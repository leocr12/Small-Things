//
//  VoESmallThingViewController.h
//  Small Things
//
//  Created by Leonardo S Rangel on 7/28/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallThing+CoreDataProperties.h"
#import "Person+CoreDataProperties.h"
#import "PhotoEnlargedViewController.h"
#import "PresentingAnimationController.h"
#import "DismissingAnimationController.h"
#import <pop/POP.h>

@interface VoESmallThingViewController : UIViewController <UIViewControllerTransitioningDelegate>


@property (strong, nonatomic) SmallThing *smallThing;
@property (strong, nonatomic) Person *person;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSURL *audioURL;
@property (strong, nonatomic) NSString *pathToSave;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end
