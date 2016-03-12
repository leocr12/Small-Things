//
//  NewSmallThingViewController.h
//  Small Things
//
//  Created by Leonardo S Rangel on 7/16/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>
#import "PresentingAnimationController.h"
#import "DismissingAnimationController.h"

@interface NewSmallThingViewController : UIViewController <UIViewControllerTransitioningDelegate>

@property (strong,nonatomic) SmallThing *smallThing;
@property (strong,nonatomic) Person *person;
@property (strong, nonatomic) NSString* stText;
@property (strong, nonatomic) NSString *pathToSave;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImagePickerController *imagePicker;


@end
