//
//  VoESmallThingViewController.m
//  Small Things
//
//  Created by Leonardo S Rangel on 7/28/15.
//  Copyright © 2015 Leonardo S Rangel. All rights reserved.
//

#import "VoESmallThingViewController.h"
#import "SWRevealViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface VoESmallThingViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *personTextField;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *stText;
@property (weak, nonatomic) IBOutlet UIButton *stAudio;
@property (weak, nonatomic) IBOutlet UIImageView *stPhoto;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *imageTap;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property (strong,nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;

@end

@implementation VoESmallThingViewController

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark - View Methods
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.stText setDelegate:self];
    
    self.image = [[UIImage alloc]initWithData:self.smallThing.smallphoto];
    [self imageCheck];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.audioURL = [prefs URLForKey:self.smallThing.title];
    
    
    [self.titleTextField setText:self.smallThing.title];
    [self.titleTextField addTarget:self action:@selector(titleChanged) forControlEvents:UIControlEventEditingChanged];
    
    [self.personTextField setText:self.person.name];
    [self.personTextField addTarget:self action:@selector(personChanged) forControlEvents:UIControlEventEditingChanged];
    
    [self.stText setText:self.smallThing.smalltext];
    [self.stPhoto setImage:self.image];
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:@"edit small thing"];
    [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NexaBold" size:20] range:NSMakeRange(0, 4)];
    [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NexaLight" size:20] range:NSMakeRange(4, 12)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    //label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:1 green:0.702 blue:0.349 alpha:1];
    self.navigationItem.titleView = label;
    label.attributedText = titleString;
    [label sizeToFit];
}

- (void)titleChanged {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    self.smallThing.title = self.titleTextField.text;
    [self.smallThing setValue:self.titleTextField.text forKey:@"title"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)personChanged {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    self.smallThing.person.name = self.personTextField.text;
    [self.person setValue:self.personTextField.text forKey:@"name"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)imageCheck {
    if (self.image == nil) {
        //self.cameraButton.alpha = 1;
        [self.cameraButton setEnabled:YES];
        [[self.cameraButton superview] bringSubviewToFront:self.cameraButton];
    } else {
        //self.cameraButton.alpha = 0;
        //[self.cameraButton setEnabled:NO];
        [[self.cameraButton superview] sendSubviewToBack:self.cameraButton];
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    self.smallThing.smalltext = self.stText.text;
    [self.smallThing setValue:self.stText.text forKey:@"smalltext"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.stPhoto.layer.cornerRadius = self.stPhoto.frame.size.height /2;
    self.stPhoto.layer.masksToBounds = YES;
    self.stPhoto.layer.borderWidth = 0.1;
    
    self.stText.layer.cornerRadius = 8.f;
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1]];
    
    [self.stopButton setEnabled:NO];
    
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
    [self.stPhoto addGestureRecognizer:longPress];
}

- (void)tapCheck:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {

    }
    else if (sender.state == UIGestureRecognizerStateBegan){
        [self cameraTapped:self.cameraButton];
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (IBAction)cameraTapped:(UIButton *)sender {
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

- (IBAction)playTapped:(UIButton *)sender {
    if (!self.recorder.recording){
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioURL error:nil];
        [self.player setDelegate:self];
        [self.player play];
        
        if (self.player.playing) {
            [self.playButton setEnabled:NO];
        } else {
            [self.playButton setEnabled:YES];
        }
    }
}

- (IBAction)recordTapped:(UIButton *)sender {
    [self.stopButton setEnabled:YES];
    
    if (self.player.playing) {
        [self.player stop];
    }
    
    if (!self.recorder.recording) {
        NSArray *pathComponents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath_ = [pathComponents objectAtIndex: 0];
        self.pathToSave = [documentPath_ stringByAppendingPathComponent:self.smallThing.title];
        self.audioURL = [NSURL fileURLWithPath:self.pathToSave];
        
        // Setup audio session
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        // Define the recorder setting
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        // Initiate and prepare the recorder
        self.recorder = [[AVAudioRecorder alloc] initWithURL:self.audioURL settings:recordSetting error:NULL];
        self.recorder.delegate = self;
        self.recorder.meteringEnabled = YES;
        [self.recorder prepareToRecord];
        
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setURL:self.audioURL forKey:self.smallThing.title];
        [prefs synchronize];
        
        
        // Start recording
        [self.recorder record];
    }
}

- (IBAction)stopTapped:(UIButton *)sender {
    [self.recorder stop];
    [self.recordButton setEnabled:YES];
    [self.playButton setEnabled:YES];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
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
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        //set the photo that was taken as your photo property
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(self.image, 0.8f);
        //set your imageViews image to the image property
        [self.stPhoto setImage:self.image];
        self.smallThing.smallphoto = imageData;
        
        [self.smallThing setValue:imageData forKey:@"smallphoto"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        [self imageCheck];
        
        if(self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            //save the image to the photos album
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
        
        
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AVAudioPlayer Delegate

- (void)audioPlayerDidFinishPlaying:(nonnull AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.playButton setEnabled:YES];
    //[self.pauseButton setEnabled:NO];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    //[recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    
    [self.stopButton setEnabled:NO];
    [self.playButton setEnabled:YES];
}

#pragma mark - Main Method
- (IBAction)enlargeImage:(UITapGestureRecognizer *)sender {
    PhotoEnlargedViewController *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"customModal"];
    
    
    modalVC.transitioningDelegate = self;
    
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    
    modalVC.image = self.image;
    
    modalVC.view.frame = self.view.frame;
    
    [self.navigationController presentViewController:modalVC animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitionDelegate 

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)so
{
    return [[PresentingAnimationController alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[DismissingAnimationController alloc] init];
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
