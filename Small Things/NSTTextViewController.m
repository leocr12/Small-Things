//
//  NSTTextViewController.m
//  Small Things
//
//  Created by Leonardo S Rangel on 7/20/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//

#import "NSTTextViewController.h"
#import "SmallThing+CoreDataProperties.h"
#import "NewSmallThingViewController.h"
#import "DNTutorial.h"
#import "AppDelegate.h"

@interface NSTTextViewController () <UITextViewDelegate, DNTutorialDelegate>

@end

@implementation NSTTextViewController

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark - Save Method
- (IBAction)saveText:(id)sender {
    [DNTutorial completedStepForKey:@"textStep2"];
    
    if (self.stText.text.length > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:[self.stText text] forKey:@"stText"];
    }
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (delegate.first) {
        double delayInSeconds = 1.2f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dismissViewControllerAnimated:YES completion:nil];
            
            [self performSegueWithIdentifier:@"unwindToNST-Segue" sender:self.stText.text];
        });
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [self performSegueWithIdentifier:@"unwindToNST-Segue" sender:self.stText.text];
    }
}

#pragma mark - View Methods
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect textViewFrame = CGRectMake(10.0f, 10.0f, 250.0f, 200.0f);
    
    self.stText = [[SZTextView alloc] initWithFrame:textViewFrame];
    //self.stText.backgroundColor = [UIColor blackColor];
    
    if (!self.flag && [[NSUserDefaults standardUserDefaults] objectForKey:@"stText"] == nil) {
        self.stText.placeholder = @"Enter small text here";
        self.stText.placeholderTextColor = [UIColor lightGrayColor];
        self.stText.font = [UIFont fontWithName:@"NexaLight" size:18.0];
    }
    
    [self.view addSubview:self.stText];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [DNTutorial completedStepForKey:@"textStep2"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.flag = YES;
    
    if (self.flag && [[NSUserDefaults standardUserDefaults] objectForKey:@"stText"] != nil) {
        //self.stText.placeholderTextColor = [UIColor whiteColor];
        self.stText.font = [UIFont fontWithName:@"NexaLight" size:18.0];
        [self.stText setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"stText"]];
    }
    
    CGFloat centerX = self.view.superview.center.x;
    CGFloat centerY = self.view.superview.center.y;
    
    CGPoint center = CGPointMake(centerX, centerY);
    
    DNTutorialBanner *banner = [DNTutorialBanner bannerWithMessage:@"Swipe screen up to dismiss it" completionMessage:@"Awesome! You're getting the hang of it" key:@"banner"];
    
    [banner styleWithColor:[UIColor colorWithRed:1 green:0.702 blue:0.349 alpha:1] completedColor:[UIColor colorWithRed:0.392 green:0.761 blue:0.784 alpha:1] opacity:1 font:[UIFont fontWithName:@"NexaBold" size:18]];
    
    DNTutorialGesture *scrollGesture = [DNTutorialGesture gestureWithPosition:center type:DNTutorialGestureTypeSwipeUp key:@"gesture"];
    
    DNTutorialStep *step = [DNTutorialStep stepWithTutorialElements:@[banner, scrollGesture] forKey:@"textStep2"];
    
    [DNTutorial presentTutorialWithSteps:@[step] inView:self.view.superview delegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.layer.cornerRadius = 8.f;
    
    UISwipeGestureRecognizer *swipeToClose = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(saveText:)];
    [swipeToClose setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeToClose];
    
    self.view.layer.cornerRadius = 8.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(nonnull UITextView *)textView {
    
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"unwindToNST-Segue"]) {
        if([segue.destinationViewController isKindOfClass:[NewSmallThingViewController class]]) {             NewSmallThingViewController *destino = (NewSmallThingViewController *) segue.destinationViewController;
            [destino setStText:sender];
        }
    }
}


@end
