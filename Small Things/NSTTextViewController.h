//
//  NSTTextViewController.h
//  Small Things
//
//  Created by Leonardo S Rangel on 7/20/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"

@interface NSTTextViewController : UIViewController

@property (strong, nonatomic) SZTextView *stText;
@property (nonatomic) BOOL flag;

@end
