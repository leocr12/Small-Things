//
//  PhotoEnlargedViewController.m
//  Small Things
//
//  Created by Leonardo S Rangel on 7/29/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//

#import "PhotoEnlargedViewController.h"

@interface PhotoEnlargedViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PhotoEnlargedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UISwipeGestureRecognizer *swipeToClose = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeOnClose:)];
    [swipeToClose setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeToClose];
    
    [self.imageView setImage:self.image];
    
    self.view.layer.cornerRadius = 8.f;
}

- (void)didSwipeOnClose:(UISwipeGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
