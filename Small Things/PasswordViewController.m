//
//  PasswordViewController.m
//  Small Things
//
//  Created by Leonardo Silva Rangel on 8/25/15.
//  Copyright (c) 2015 Leonardo S Rangel. All rights reserved.
//

#import "PasswordViewController.h"
#import "ABPadLockScreenSetupViewController.h"
#import "SWRevealViewController.h"

@interface PasswordViewController () <ABPadLockScreenSetupViewControllerDelegate, ABPadLockScreenDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UITextField *secretAnswerTextField;
@property (weak, nonatomic) IBOutlet UIButton *setPassword;
@property (weak, nonatomic) IBOutlet UIButton *removePassword;
@property (weak, nonatomic) IBOutlet UIImageView *trashImage;
@property (weak, nonatomic) IBOutlet UIImageView *setChangeImage;
@property (weak, nonatomic) IBOutlet UILabel *secretAnswerLabel;

@end

@implementation PasswordViewController

#pragma mark - View Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"LixoIcon.png"];
    [self.trashImage setImage:image];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.menuButton setTarget: self.revealViewController];
        [self.menuButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    UIImage *menuImage = [UIImage imageNamed:@"menu-st.png"];
    self.menuButton.image = menuImage;
    
    [self.secretAnswerTextField setDelegate:self];
    [self secretAnswerCheck];
}

- (void)secretAnswerCheck {
    if (self.secretAnswerTextField.text != nil && ![self.secretAnswerTextField.text isEqualToString:@""]) {
        [self.setPassword setEnabled:YES];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"thePin"]) {
            [self.setPassword setTitle:NSLocalizedString(@"Set up password", nil) forState:UIControlStateNormal];
            UIImage *setImage = [UIImage imageNamed:@"PasswordIconOrange.png"];
            [self.setChangeImage setImage:setImage];
        }
    } else {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"thePin"]) {
            [self.setPassword setEnabled:YES];
            [self.setPassword setTitle:NSLocalizedString(@"Change password", nil) forState:UIControlStateNormal];
            UIImage *changeImage = [UIImage imageNamed:@"ChangeIconOrange.png"];
            [self.setChangeImage setImage:changeImage];
            [self.secretAnswerLabel setHidden:YES];
            [self.secretAnswerTextField setHidden:YES];
        } else {
            [self.setPassword setEnabled:NO];
            [self.setPassword setTitle:NSLocalizedString(@"Define secret answer", nil) forState:UIControlStateNormal];
            UIImage *setImage = [UIImage imageNamed:@"PasswordIconOrange.png"];
            [self.setChangeImage setImage:setImage];
            [self.secretAnswerTextField setHidden:NO];
            [self.secretAnswerLabel setHidden:NO];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"thePin"]) {
        [self.setPassword setTitle:NSLocalizedString(@"Change password", nil) forState:UIControlStateNormal];
        [self.setPassword setEnabled:YES];
    } else {
        [self.removePassword setEnabled:NO];
        [self.setPassword setTitle:NSLocalizedString(@"Define secret answer", nil) forState:UIControlStateNormal];
    }
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:@"small password"];
    [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NexaBold" size:20] range:NSMakeRange(0, 14)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    //label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:1 green:0.702 blue:0.349 alpha:1];
    self.navigationItem.titleView = label;
    label.attributedText = titleString;
    [label sizeToFit];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.secretAnswerTextField.text != nil && ![self.secretAnswerTextField.text isEqualToString:@""]) {
        [[NSUserDefaults standardUserDefaults] setValue:self.secretAnswerTextField.text forKey:@"secretAnswer"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {

    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
    [self secretAnswerCheck];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"thePin"]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - ABPadLockScreen Methods

- (IBAction)setPin:(id)sender {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"thePin"]) {
        ABPadLockScreenSetupViewController *lockScreen = [[ABPadLockScreenSetupViewController alloc] initWithDelegate:self complexPin:YES subtitleLabelText:@"You need a PIN to continue"];
        lockScreen.tapSoundEnabled = YES;
        lockScreen.errorVibrateEnabled = YES;
        
        lockScreen.modalPresentationStyle = UIModalPresentationFullScreen;
        lockScreen.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        //	Example using an image
        //	UIImageView* backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wallpaper"]];
        //	backgroundView.contentMode = UIViewContentModeScaleAspectFill;
        //	backgroundView.clipsToBounds = YES;
        //	[lockScreen setBackgroundView:backgroundView];
        
        [self.removePassword setEnabled:YES];
        [self presentViewController:lockScreen animated:YES completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Confirming identity" message:@"What was your first school name ?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = alertController.textFields[0];
            
            if ([textField.text isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"secretAnswer"]]) {
                ABPadLockScreenSetupViewController *lockScreen = [[ABPadLockScreenSetupViewController alloc] initWithDelegate:self complexPin:YES subtitleLabelText:@"You need a PIN to continue"];
                lockScreen.tapSoundEnabled = YES;
                lockScreen.errorVibrateEnabled = YES;
                
                lockScreen.modalPresentationStyle = UIModalPresentationFullScreen;
                lockScreen.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                
                //	Example using an image
                //	UIImageView* backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wallpaper"]];
                //	backgroundView.contentMode = UIViewContentModeScaleAspectFill;
                //	backgroundView.clipsToBounds = YES;
                //	[lockScreen setBackgroundView:backgroundView];
                
                [self.removePassword setEnabled:YES];
                [self presentViewController:lockScreen animated:YES completion:nil];
            }
        }];
        
        UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:yesButton];
        [alertController addAction:noButton];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Secret Answer";
            textField.keyboardType = UIKeyboardAppearanceDefault;
        }];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)removePin:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Confirming identity" message:@"What was your first school name ?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields[0];
        
        if ([textField.text isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"secretAnswer"]]) {
            UIAlertController *alertController2 = [UIAlertController alertControllerWithTitle:@"Removing pin" message:@"Are you sure you want to remove your pin ? You may not be able to protect your information" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *yesButton2 = [UIAlertAction actionWithTitle:@"I'm sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thePin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                self.thePin = nil;
                
                [self.removePassword setEnabled:NO];
                [self.setPassword setEnabled:NO];
                [self.setPassword setTitle:@"Define secret answer" forState:UIControlStateNormal];
                UIImage *setImage = [UIImage imageNamed:@"PasswordIconOrange.png"];
                [self.setChangeImage setImage:setImage];
                [self.secretAnswerTextField setHidden:NO];
                [self.secretAnswerLabel setHidden:NO];
            }];
            
            UIAlertAction *noButton2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            
            [alertController2 addAction:yesButton2];
            [alertController2 addAction:noButton2];
            
            [self presentViewController:alertController2 animated:YES completion:nil];
        }
    }];
    
    UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:yesButton];
    [alertController addAction:noButton];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Secret Answer";
        textField.keyboardType = UIKeyboardAppearanceDefault;
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)pinSet:(NSString *)pin padLockScreenSetupViewController:(ABPadLockScreenSetupViewController *)padLockScreenViewController {
    self.thePin = pin;
    [[NSUserDefaults standardUserDefaults] setValue:self.thePin forKey:@"thePin"];
    UIImage *changeImage = [UIImage imageNamed:@"ChangeIconOrange.png"];
    [self.setChangeImage setImage:changeImage];
    [self.secretAnswerTextField setHidden:YES];
    [self.secretAnswerLabel setHidden:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)unlockWasCancelledForPadLockScreenViewController:(ABPadLockScreenAbstractViewController *)padLockScreenViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
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
