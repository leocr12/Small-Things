//
//  NewSmallThingViewController.m
//  Small Things
//
//  Created by Leonardo S Rangel on 7/16/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//

#import "SmallThing+CoreDataProperties.h"
#import "Person+CoreDataProperties.h"

#import "NewSmallThingViewController.h"
#import "NSTTextViewController.h"
#import "SWRevealViewController.h"
#import "PhotoEnlargedViewController.h"
#import "DNTutorial.h"
#import "AppDelegate.h"

#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface NewSmallThingViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DNTutorialDelegate>

@property (strong,nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *textButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UITextField *titleEditText;
@property (weak, nonatomic) IBOutlet UITextField *personEditText;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) NSURL *audioOutput;
//@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@end

@implementation NewSmallThingViewController
@synthesize recorder;
@synthesize player;
@synthesize recordButton;
@synthesize textButton;
@synthesize stopButton;
@synthesize playButton;
//@synthesize pauseButton;
@synthesize audioOutput;
@synthesize stText;

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (IBAction)unwindToNST:(UIStoryboardSegue *)sender {
    [DNTutorial completedStepForKey:@"textStep2"];
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    delegate.first = NO;
}

#pragma mark - View Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self styleNavBar];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
    item.title = @"";
    [item setBackButtonBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem = item;
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:@"new small thing"];
    [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NexaBold" size:20] range:NSMakeRange(0, 3)];
    [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NexaLight" size:20] range:NSMakeRange(4, 11)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:1 green:0.702 blue:0.349 alpha:1];
    self.navigationItem.titleView = label;
    label.attributedText = titleString;
    [label sizeToFit];
    
    [self imageCheck];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1]];
    
    // Do any additional setup after loading the view.
    [stopButton setEnabled:NO];
    [playButton setEnabled:NO];
    
    self.imageView.layer.cornerRadius = self.imageView.frame.size.height /2;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.borderWidth = 0.1;
    
    
    
    UIImage *buttonImage = [UIImage imageNamed:@"back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapCheck:)];
    [longPress setMinimumPressDuration:1.0f];
    [self.imageView addGestureRecognizer:longPress];
}

- (void)imageCheck {
    if (self.image == nil) {
        //self.cameraButton.alpha = 1;
        [self.photoButton setEnabled:YES];
        [[self.photoButton superview] bringSubviewToFront:self.photoButton];
    } else {
        [[self.photoButton superview] sendSubviewToBack:self.photoButton];
    }
}

- (void)tapCheck:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {

    }
    else if (sender.state == UIGestureRecognizerStateBegan){
        [DNTutorial completedStepForKey:@"photoStep"];
        [self takePhoto:self.photoButton];
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"stText"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (IBAction)textThing:(UIButton *)sender {
    NSTTextViewController *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"customNST"];
    
    modalVC.transitioningDelegate = self;
    
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    
    [self.navigationController presentViewController:modalVC animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[PresentingAnimationController alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[DismissingAnimationController alloc] init];
}

#pragma mark - Photo Method

- (IBAction)takePhoto:(UIButton *)sender {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = NO;
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction
                                   actionWithTitle:@"Take Photo"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       //NSLog(@"Photo Library action");
                                       self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                       [self presentViewController:self.imagePicker animated:YES completion:NULL];
                                       
                                   }];
    
    UIAlertAction *libraryAction = [UIAlertAction
                               actionWithTitle:@"Photo Library"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   //NSLog(@"Take Photo action");
                                   self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                   [self presentViewController:self.imagePicker animated:YES completion:NULL];
                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
    
    [alertController addAction:cameraAction];
    [alertController addAction:libraryAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)enlargeImage:(UITapGestureRecognizer *)sender {
    PhotoEnlargedViewController *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"customModal"];
    
    
    modalVC.transitioningDelegate = self;
    
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    
    modalVC.image = self.image;
    
    modalVC.view.frame = self.view.frame;
    
    [self.navigationController presentViewController:modalVC animated:YES completion:nil];
}

#pragma mark - Core Data Method

- (IBAction)saveST:(id)sender {
    if ((self.titleEditText.text != nil && ![self.titleEditText.text isEqualToString:@""]) && (self.personEditText.text != nil && ![self.personEditText.text isEqualToString:@""])) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"stText"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        self.smallThing = [NSEntityDescription insertNewObjectForEntityForName:@"SmallThing" inManagedObjectContext:context];
        
        [self.smallThing setValue:self.titleEditText.text forKey:@"title"];
        //[self.smallThing setValue:[NSData dataWithContentsOfURL:self.audioOutput] forKey:@"smallaudio"];
        [self.smallThing setValue:stText forKey:@"smalltext"];
        
        NSData *imageData = UIImageJPEGRepresentation(self.image, 0.8f);
        [self.smallThing setValue:imageData forKey:@"smallphoto"];
        
        NSLocale* currentLocale = [NSLocale currentLocale];
        NSDate *cDate = [NSDate date];
        [cDate descriptionWithLocale:currentLocale];
        [self.smallThing setValue:cDate forKey:@"smalldate"];
            
        self.person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
        [self.person setValue:self.personEditText.text forKey:@"name"];
        [self.person setValue:self.smallThing forKey:@"smallthing"];
        [self.person setValue:cDate forKey:@"persondate"];
            
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }else {
            [self imageCheck];
            [self performSegueWithIdentifier:@"unwindToSTVC-Segue" sender:nil];
        }
    } else {
        POPSpringAnimation *shake = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        POPSpringAnimation *shake2 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        
        shake.springBounciness = 20;
        shake.velocity = @(2000);
        
        shake2.springBounciness = 15;
        shake2.velocity = @(2500);
        
        if (self.personEditText.text != nil && ![self.personEditText.text isEqualToString:@""]) {
            [self.titleEditText.layer pop_addAnimation:shake forKey:@"shakeTitle"];
        } else {
            [self.personEditText.layer pop_addAnimation:shake2 forKey:@"shakePerson"];
        }
        
        if (self.titleEditText.text != nil && ![self.titleEditText.text isEqualToString:@""]) {
            [self.personEditText.layer pop_addAnimation:shake2 forKey:@"shakePerson"];
        } else {
            [self.titleEditText.layer pop_addAnimation:shake forKey:@"shakeTitle"];
        }
    }
    
}

#pragma mark - Audio Methods

- (IBAction)recordThing:(UIButton *)sender {
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording && self.titleEditText.text != nil && ![self.titleEditText.text isEqualToString:@""]) {
        NSArray *pathComponents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath_ = [pathComponents objectAtIndex: 0];
        self.pathToSave = [documentPath_ stringByAppendingPathComponent:self.titleEditText.text];
        audioOutput = [NSURL fileURLWithPath:self.pathToSave];
        
        // Setup audio session
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        // Define the recorder setting
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        // Initiate and prepare the recorder
        recorder = [[AVAudioRecorder alloc] initWithURL:audioOutput settings:recordSetting error:NULL];
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
        [recorder prepareToRecord];
        
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setURL:audioOutput forKey:self.titleEditText.text];
        [prefs synchronize];
        
        
        // Start recording
        [recorder record];
        
        if (stopButton.alpha == 0) {
            stopButton.alpha = 0;
            stopButton.hidden = NO;
            [UIView animateWithDuration:1 animations:^{
                stopButton.alpha = 1;
            }];
        }
        
        if (playButton.alpha == 0) {
            playButton.alpha = 0;
            playButton.hidden = NO;
            [UIView animateWithDuration:1 animations:^{
                playButton.alpha = 1;
            }];
        }
        
        [stopButton setEnabled:YES];
        [playButton setEnabled:NO];
        [recordButton setEnabled:NO];
    } else {
        POPSpringAnimation *shake = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        
        shake.springBounciness = 20;
        shake.velocity = @(2000);
        
        [self.titleEditText.layer pop_addAnimation:shake forKey:@"shakeTitle"];
    }
}

- (IBAction)pauseTapped:(UIButton *)sender {
    [recorder pause];
    [recordButton setEnabled:YES];
    //[pauseButton setEnabled:NO];
}

- (IBAction)stopTapped:(UIButton *)sender {
    [recorder stop];
    //[pauseButton setEnabled:YES];
    [recordButton setEnabled:YES];
    [playButton setEnabled:YES];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (IBAction)playTapped:(UIButton *)sender {
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioOutput error:nil];
        [player setDelegate:self];
        [player play];
        
        if (player.playing) {
            [playButton setEnabled:NO];
        } else {
            [playButton setEnabled:YES];
        }
    }
}

#pragma mark - AVAudioPlayer Delegate

- (void)audioPlayerDidFinishPlaying:(nonnull AVAudioPlayer *)player successfully:(BOOL)flag {
    [playButton setEnabled:YES];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    //[recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    
    [stopButton setEnabled:NO];
    [playButton setEnabled:YES];
}

#pragma mark - ImagePickerController Delegate

//handles cancelation
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

//this runs when you finish taking a picture
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        //set the photo that was taken as your photo property
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //set your imageViews image to the image property
        self.imageView.image = self.image;
        
        CGFloat centerX = self.imageView.center.x;
        CGFloat centerY = self.imageView.center.y;
        
        CGPoint center = CGPointMake(centerX, centerY);
        
        DNTutorialBanner *banner = [DNTutorialBanner bannerWithMessage:@"Tap to see the photo or hold to change it" completionMessage:@"Superb! You're a fast learner!" key:@"banner"];
        
        [banner styleWithColor:[UIColor colorWithRed:1 green:0.702 blue:0.349 alpha:1] completedColor:[UIColor colorWithRed:0.392 green:0.761 blue:0.784 alpha:1] opacity:1 font:[UIFont fontWithName:@"NexaBold" size:18]];
        
        DNTutorialGesture *scrollGesture = [DNTutorialGesture gestureWithPosition:center type:DNTutorialGestureTypeTap key:@"gesture"];
        
        DNTutorialStep *step = [DNTutorialStep stepWithTutorialElements:@[banner, scrollGesture] forKey:@"photoStep"];
        
        [DNTutorial presentTutorialWithSteps:@[step] inView:self.view delegate:self];
        
        if(self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            //save the image to the photos album
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
            
        }
        
        [self.imageView setUserInteractionEnabled:YES];
    }
    
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
