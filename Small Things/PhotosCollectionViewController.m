//
//  PhotosCollectionViewController.m
//  Small Things
//
//  Created by Leonardo Silva Rangel on 8/18/15.
//  Copyright (c) 2015 Leonardo S Rangel. All rights reserved.
//

#import "PhotosCollectionViewController.h"
#import "SmallThingsViewController.h"
#import "SWRevealViewController.h"
#import "ABPadLockScreenViewController.h"
#import "AppDelegate.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "VoESmallThingViewController.h"

@interface PhotosCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ABPadLockScreenViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (strong, nonatomic) NSString *pin;
@property (nonatomic) BOOL isPin;

@property (strong, nonatomic) NSMutableArray *memory;
@property (strong, nonatomic) NSMutableArray *person;

@end

@implementation PhotosCollectionViewController

static NSString * const reuseIdentifier = @"photoCell";

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SmallThing"];
    NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] initWithEntityName:@"SmallThing"];
    NSFetchRequest *fetchRequest3 = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"smallphoto", nil]];
    self.photos = [[managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
    self.memory = [[managedObjectContext executeFetchRequest:fetchRequest2 error:nil]mutableCopy];
    self.person = [[managedObjectContext executeFetchRequest:fetchRequest3 error:nil]mutableCopy];
    
    self.images = [[NSMutableArray alloc] init];
    [self convertDataToImage];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
        [self.collectionView reloadData];
    });
    
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
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:@"small photos"];
    [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NexaBold" size:20] range:NSMakeRange(0, 12)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    //label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:1 green:0.702 blue:0.349 alpha:1];
    self.navigationItem.titleView = label;
    label.attributedText = titleString;
    [label sizeToFit];
    
    UIImage *menuImage = [UIImage imageNamed:@"menu-st.png"];
    self.menuButton.image = menuImage;
}

- (NSMutableArray *)convertDataToImage {
    for (NSDictionary *dictionary in self.photos) {
        NSData *data = dictionary[@"smallphoto"];
        UIImage *image = [[UIImage alloc] initWithData:data];
        CGImageRef cgref = [image CGImage];
        CIImage *cim = [image CIImage];
        
        if (cim == nil && cgref == NULL) {
            
        } else {
            [self.images addObject:image];
        }
    }
    if (self.images == nil && [self.images count] == 0) {
        return self.images;
    } else {
        return nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    
    // Do any additional setup after loading the view.
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    
    [self.collectionView setBackgroundColor:[UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1]];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1]];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.menuButton setTarget: self.revealViewController];
        [self.menuButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SmallPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (cell) {
        UIImage *image = self.images[indexPath.row];
        cell.smallPhoto.image = image;

    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    VoESmallThingViewController *voe = [storyboard instantiateViewControllerWithIdentifier:@"VoEView"];
    voe.smallThing = [self.memory objectAtIndex:indexPath.row];
    voe.person = [self.person objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:voe animated:YES];
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

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize photoSize = CGSizeMake(150, 150);
    
    return photoSize;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 20, 50, 20);
}

@end
