//
//  CreditsViewController.m
//  Small Things
//
//  Created by Leonardo Silva Rangel on 10/15/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//

#import "CreditsViewController.h"
#import "SWRevealViewController.h"

@interface CreditsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@end

@implementation CreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.menuButton setTarget: self.revealViewController];
        [self.menuButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    UIImage *menuImage = [UIImage imageNamed:@"menu-st.png"];
    self.menuButton.image = menuImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:@"app credits"];
    [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NexaBold" size:20] range:NSMakeRange(0, 11)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    //label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:1 green:0.702 blue:0.349 alpha:1];
    self.navigationItem.titleView = label;
    label.attributedText = titleString;
    [label sizeToFit];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
