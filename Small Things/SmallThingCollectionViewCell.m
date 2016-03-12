//
//  SmallThingCollectionViewCell.m
//  Small Things
//
//  Created by Leonardo S Rangel on 8/4/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//

#import "SmallThingCollectionViewCell.h"

@implementation SmallThingCollectionViewCell

- (void)configureCellWithName:(NSString *)name {
    [_nameLabel setText:name];
}

@end
