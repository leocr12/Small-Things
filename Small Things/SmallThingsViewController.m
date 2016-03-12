//
//  SmallThingsViewController.m
//  Small Things
//
//  Created by Leonardo S Rangel on 7/14/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//

#import "SmallThingsViewController.h"
#import "SmallThingTableViewCell.h"
#import "VoESmallThingViewController.h"
#import "SWRevealViewController.h"
#import "ABPadLockScreenViewController.h"
#import "AppDelegate.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "DNTutorial.h"
#import "YCTutorialBox.h"

@interface SmallThingsViewController () <ABPadLockScreenViewControllerDelegate, UIAlertViewDelegate, DNTutorialDelegate>

@property (strong, nonatomic) NSString *pin;
@property (nonatomic) BOOL isPin;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) UIButton *fakeButton;

@end

@implementation SmallThingsViewController
@synthesize memory;
@synthesize person;

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}



#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UITextField * alertTextField = [alertView textFieldAtIndex:0];
        
        if ([alertTextField.text isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"secretAnswer"]]) {

            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thePin"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secretAnswer"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.pin = nil;
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        // Add another action here
    }
}

#pragma mark - View Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"thePin"] != nil) {
        self.pin = [[NSString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"thePin"]];
    }
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    if (!delegate.backgroundOnly) {
        delegate.backgroundOnly = YES;
        
        
        if (!self.pin) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else if (!self.isPin) {
            
            ABPadLockScreenViewController *lockScreen = [[ABPadLockScreenViewController alloc] initWithDelegate:self complexPin:YES];
            [lockScreen setAllowedAttempts:100];
            [lockScreen setCancelButtonText:@"Forgot?"];
            
            
            lockScreen.modalPresentationStyle = UIModalPresentationFullScreen;
            lockScreen.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            [self.navigationController presentViewController:lockScreen animated:YES completion:nil];
        }
    }
    
    if (delegate.tutorial) {
        NSMutableAttributedString *headline = [[NSMutableAttributedString alloc] initWithString:@"WELCOME TO SMALL THINGS"];
        [headline addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NexaBold" size:20] range:NSMakeRange(0, 23)];
        [headline addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1 green:0.702 blue:0.349 alpha:1] range:NSMakeRange(0, 23)];
        
        NSMutableAttributedString *helptext = [[NSMutableAttributedString alloc] initWithString:@"WE HOPE TO HELP YOU APPRECIATE THE SMALLEST THINGS IN LIFE"];
        [helptext addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NexaLight" size:18] range:NSMakeRange(0, 58)];
        [helptext addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1 green:0.702 blue:0.349 alpha:1] range:NSMakeRange(0, 58)];
        
        YCTutorialBox *tutorial = [[YCTutorialBox alloc] initWithHeadline:headline withHelpText:helptext withCompletionBlock:^{
            delegate.tutorial = NO;
        }];
        [tutorial setBlurRadius:0.1f];
        [tutorial showAndFocusView:self.view];
    }
    
    DNTutorialBanner *banner = [DNTutorialBanner bannerWithMessage:@"Tap the + to start" completionMessage:@"Congratulations!" key:@"banner"];
    
    [banner styleWithColor:[UIColor colorWithRed:1 green:0.702 blue:0.349 alpha:1] completedColor:[UIColor colorWithRed:0.392 green:0.761 blue:0.784 alpha:1] opacity:1 font:[UIFont fontWithName:@"NexaBold" size:18]];
    
    DNTutorialStep *step = [DNTutorialStep stepWithTutorialElements:@[banner] forKey:@"step"];
    
    [DNTutorial presentTutorialWithSteps:@[step] inView:self.view delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SmallThing"];
    NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    self.memory = [[managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
    self.person = [[managedObjectContext executeFetchRequest:fetchRequest2 error:nil]mutableCopy];
    
    NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"smalldate" ascending:NO];
    NSSortDescriptor* sortByDate2 = [NSSortDescriptor sortDescriptorWithKey:@"persondate" ascending:NO];
    [self.memory sortUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
    [self.person sortUsingDescriptors:[NSArray arrayWithObject:sortByDate2]];
    
    [self.tableView reloadData];
}

- (IBAction)addST:(UIBarButtonItem *)sender {
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [DNTutorial completedStepForKey:@"step"];
    
    if (delegate.first) {
        double delayInSeconds = 1.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSegueWithIdentifier:@"STToNew" sender:sender];
        });
    } else {
        [self performSegueWithIdentifier:@"STToNew" sender:sender];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1]];
    [self.view setBackgroundColor:[UIColor colorWithRed:1 green:0.702 blue:0.349 alpha:1]];
    
    UIImage *menuImage = [UIImage imageNamed:@"menu-st.png"];
    self.menuButton.image = menuImage;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.menuButton setTarget: self.revealViewController];
        [self.menuButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:@"small things"];
    [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NexaBold" size:20] range:NSMakeRange(0, 12)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    //label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:1 green:0.702 blue:0.349 alpha:1];
    self.navigationItem.titleView = label;
    label.attributedText = titleString;
    [label sizeToFit];
}

- (IBAction)unwindToSTVC:(UIStoryboardSegue *)sender {

}

#pragma mark - ABPadLockScreen Delegate

- (void)unlockWasSuccessfulForPadLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)unlockWasUnsuccessful:(NSString *)falsePin afterAttemptNumber:(NSInteger)attemptNumber padLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController {
    UIAlertController *alertController3 = [UIAlertController alertControllerWithTitle:@"Wrong pin" message:@"Try again" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noButton3 = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController3 addAction:noButton3];
    
    [padLockScreenViewController presentViewController:alertController3 animated:YES completion:nil];
}

- (void)unlockWasCancelledForPadLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController {
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"Touch ID to get access if pin is forgotten.";
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thePin"];
                                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secretAnswer"];
                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                        
                                        self.pin = nil;
                                        
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    });
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"What was your first school name ?" preferredStyle:UIAlertControllerStyleAlert];
                                        
                                        UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                            UITextField *textField = alertController.textFields[0];
                                            
                                            if ([textField.text isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"secretAnswer"]]) {
                                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thePin"];
                                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secretAnswer"];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                
                                                self.pin = nil;
                                                
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                            }
                                        }];
                                        
                                        UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                                        
                                        [alertController addAction:yesButton];
                                        [alertController addAction:noButton];
                                        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                                            textField.placeholder = @"Secret Answer";
                                            textField.keyboardType = UIKeyboardAppearanceDefault;
                                        }];
                                        
                                        [padLockScreenViewController presentViewController:alertController animated:YES completion:nil];
                                    });
                                }
                            }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController2 = [UIAlertController alertControllerWithTitle:@"Error" message:@"What was your first school name ?" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *yesButton2 = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *textField2 = alertController2.textFields[0];
                
                if ([textField2.text isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"secretAnswer"]]) {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thePin"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secretAnswer"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    self.pin = nil;
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
            
            UIAlertAction *noButton2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            
            [alertController2 addAction:yesButton2];
            [alertController2 addAction:noButton2];
            [alertController2 addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Secret Answer";
                textField.keyboardType = UIKeyboardAppearanceDefault;
            }];
            
            [padLockScreenViewController presentViewController:alertController2 animated:YES completion:nil];
        });
    }
}

- (void)attemptsExpiredForPadLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController {
    
}

- (BOOL)padLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController validatePin:(NSString*)pin {
    
    self.isPin = YES;
    
    return [self.pin isEqualToString:pin];
}

#pragma mark - Table View Data Source
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memory.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier = @"customCell";
    SmallThingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    SmallThing *memoryData = [self.memory objectAtIndex:indexPath.row];
    Person *personData = [self.person objectAtIndex:indexPath.row];
    
    [cell configureCellWithTitle:[memoryData valueForKey:@"title"] andSubtitle:[personData valueForKey:@"name"]];
    [cell setBackgroundColor:[UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1]];
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    VoESmallThingViewController *voe = [storyboard instantiateViewControllerWithIdentifier:@"VoEView"];
    voe.smallThing = [self.memory objectAtIndex:indexPath.row];
    voe.person = [self.person objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:voe animated:YES];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self managedObjectContext];
        
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [context deleteObject:[self.memory objectAtIndex:indexPath.row]];
            [context deleteObject:[self.person objectAtIndex:indexPath.row]];
            
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Cant delete! %@ %@", error, [error localizedDescription]);
                return;
            }
            
            [self.memory removeObjectAtIndex:indexPath.row];
            [self.person removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
                                  
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ABPadLockScreenViewController *lockScreen = (ABPadLockScreenViewController *)segue.destinationViewController;
    lockScreen.delegate = self;
}
*/

@end
