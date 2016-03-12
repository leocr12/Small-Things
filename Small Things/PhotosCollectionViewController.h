//
//  PhotosCollectionViewController.h
//  Small Things
//
//  Created by Leonardo Silva Rangel on 8/18/15.
//  Copyright (c) 2015 Leonardo S Rangel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallThing+CoreDataProperties.h"
#import "SmallPhotoCollectionViewCell.h"

@interface PhotosCollectionViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) UIImage *image;

@end
