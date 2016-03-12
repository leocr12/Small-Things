//
//  SmallThingsViewController.h
//  Small Things
//
//  Created by Leonardo S Rangel on 7/14/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallThing+CoreDataProperties.h"
#import "Person+CoreDataProperties.h"

@interface SmallThingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *memory;
@property (strong, nonatomic) NSMutableArray *person;

@end
