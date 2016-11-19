//
//  ViewController.m
//  Firebase-C
//
//  Created by Rui on 2016-11-17.
//  Copyright © 2016 Rui. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <Photos/Photos.h>

@interface ViewController ()

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (strong, nonatomic) FIRStorageReference *storageRef;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //initial UI style
    [self setUITextViewStyle];
    [self setUIImageViewStyle];
    
    self.storageRef = [[FIRStorage storage] referenceForURL:@"gs://assignment3-49d31.appspot.com"];
    
    //Set dataTime
    self.datetimeLabel.text = [self getDateString];
    
    self.ref = [[FIRDatabase database] reference];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)photoButton:(UIButton *)sender {
    
    //Define an image picker
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
#if TARGET_IPHONE_SIMULATOR
    //use Photo Library
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
#elif TARGET_OS_IPHONE
    //use camera
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
#endif
    
    //present picker
    [self presentViewController:picker animated:YES completion:NULL];
    
}

// Select Operation
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    self.photo.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    NSURL *referenceUrl = info[UIImagePickerControllerReferenceURL];
    
    if (referenceUrl) {
        PHFetchResult* assets = [PHAsset fetchAssetsWithALAssetURLs:@[referenceUrl] options:nil];
        PHAsset *asset = [assets firstObject];
        [asset requestContentEditingInputWithOptions:nil
                                   completionHandler:^(PHContentEditingInput *contentEditingInput,
                                                       NSDictionary *info) {
                                       NSURL *imageFile = contentEditingInput.fullSizeImageURL;
                                       NSString *filePath = [NSString stringWithFormat:@"images/%@", [imageFile lastPathComponent]];
                                       // [START uploadimage]
                                       [[_storageRef child:filePath]
                                        putFile:imageFile metadata:nil
                                        completion:^(FIRStorageMetadata *metadata, NSError *error) {
                                            if (error) {
                                                NSLog(@"Error uploading: %@", error);
                                                return;
                                            }
                                            [self uploadSuccess:metadata storagePath:filePath];
                                        }];
                                       // [END uploadimage]
                                   }];
        
    } else {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
        NSString *imagePath =
        [NSString stringWithFormat:@"Images/%lld.jpg",
         (long long)([[NSDate date] timeIntervalSince1970] * 1000.0)];
        FIRStorageMetadata *metadata = [FIRStorageMetadata new];
        metadata.contentType = @"image/jpeg";
        [[_storageRef child:imagePath] putData:imageData metadata:metadata
                                    completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                                        if (error) {
                                            NSLog(@"Error uploading: %@", error);
                                            return;
                                        }
                                        [self uploadSuccess:metadata storagePath:imagePath];
                                    }];
    }
    
    
}

// Cancel Operation
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

//Set UITextView Border
-(void) setUITextViewStyle{
    UIColor *borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    
    //Face
    self.messageTextView.layer.borderColor = borderColor.CGColor;
    self.messageTextView.layer.borderWidth = 1.0;
    self.messageTextView.layer.cornerRadius = 5.0;
    
}

//Set UIImageView Border
-(void) setUIImageViewStyle{
    UIColor *borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    
    //Face
    self.faceImageView.layer.borderColor = borderColor.CGColor;
    self.faceImageView.layer.borderWidth = 1.0;
    self.faceImageView.layer.cornerRadius = 5.0;
    
    //Photo
    self.photo.layer.borderColor = borderColor.CGColor;
    self.photo.layer.borderWidth = 1.0;
    self.photo.layer.cornerRadius = 5.0;
}

//Convert Data to String With Format
-(NSString *)getDateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    NSDate *now = [NSDate date];
    NSString *dateString = [dateFormatter stringFromDate:now];
    return dateString;
}

- (IBAction)postButton:(UIButton *)sender {
    
    NSString *imageString;
    
    if(self.posterImageView.image != nil){
        UIImage *uploadImage = self.posterImageView.image;
        imageString = [self encodeToBase64String:uploadImage];
    }else{
        imageString = @"";
    }
    
    [[_ref child: self.datetimeLabel.text] setValue:@{@"Location": @"Kitchener",
                                                      @"Poster": self.posterTextView.text,
                                                      @"Image": imageString}];
}


- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (void)uploadSuccess:(FIRStorageMetadata *) metadata storagePath: (NSString *) storagePath {
    NSLog(@"Upload Succeeded!");
    NSLog(@"image file path = %@", storagePath);
    [[NSUserDefaults standardUserDefaults] setObject:storagePath forKey:@"storagePath"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
