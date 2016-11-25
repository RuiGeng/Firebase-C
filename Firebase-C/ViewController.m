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

@property NSURL *imageReferenceUrl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Initialize locationManger object
    CLLocationManager *locationManager=[[CLLocationManager alloc]init];
    self.locationManager = locationManager;
    
    
    //CLLocationManager is not enabled
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"The location service is not already open on the device");
    }
    
    //if current device is newer then 8.0
    if ([UIDevice currentDevice].systemVersion.floatValue >=8.0) {
        //Ask always Authorization
        [locationManager requestAlwaysAuthorization];
        //Ask Authorization only when applibation be used
        [locationManager requestWhenInUseAuthorization];
    }
    
    //set delegate is locationManager itself
    locationManager.delegate=self;
    //set accuracy
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    
    //set relocation distance
    CLLocationDistance distance=10;
    locationManager.distanceFilter=distance;
    
    //start location manager
    [locationManager startUpdatingLocation];
    
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
    
    //UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    //self.photo.image = chosenImage;
    
    //Save image Reference URL
    self.imageReferenceUrl = info[UIImagePickerControllerReferenceURL];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    self.photo.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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
    
    //Save image to Firebase Storage
    [self uploadImagetoStorage:self.imageReferenceUrl];
    
}

- (void)uploadImagetoStorage: (NSURL*) imageReferenceURL {
    
    if (imageReferenceURL) {
        PHFetchResult* assets = [PHAsset fetchAssetsWithALAssetURLs:@[imageReferenceURL] options:nil];
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
        //UIImage *image = info[UIImagePickerControllerOriginalImage];
        UIImage *image = self.posterImageView.image;
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

- (void)uploadSuccess:(FIRStorageMetadata *) metadata storagePath: (NSString *) storagePath {
    NSLog(@"Upload Succeeded!");
    NSLog(@"image file path = %@", storagePath);
    [[NSUserDefaults standardUserDefaults] setObject:storagePath forKey:@"storagePath"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[_ref child: @"Rui/Post"] setValue:@{@"PostTime": self.datetimeLabel.text,
                                          @"Location": self.locationLabel.text,
                                          @"Poster": self.posterTextView.text,
                                          @"ImageURL": storagePath}];
    
    [self cleanItems];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Infomation Message"
                                                    message:@"The message was successfully sent."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

- (void)cleanItems{
    self.posterImageView.image = nil;
    self.posterTextView.text = @"";
    self.datetimeLabel.text = [self getDateString];
    self.locationLabel.text = @"Location: ";
}

- (IBAction)locationButton:(id)sender {
    
    [self AntiEncoder: self.locationManager.location.coordinate];
}


// Converting Coordinates into Place Names
- (void)AntiEncoder: (CLLocationCoordinate2D)currentLocation {
    
    //Create geocoder object
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    
    //Create Location
    CLLocation *location=[[CLLocation alloc]initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];
    
    __block NSString *addressString = nil;
    
    //reverse Geocode Location
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error !=nil || placemarks.count == 0) {
            NSLog(@"%@",error);
            return ;
        }
        
        for (CLPlacemark *placemark in placemarks) {
            //address
            //self.addressLabel.text = [NSString stringWithFormat:@"Address: %@", placemark.name];

            //use addressDictionary
            NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
            addressString = [lines componentsJoinedByString:@" "];
            NSLog(@"Address: %@", addressString);
            self.locationLabel.text = addressString;
        }
    }];
}

@end
