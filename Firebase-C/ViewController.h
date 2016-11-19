//
//  ViewController.h
//  Firebase-C
//
//  Created by Rui on 2016-11-17.
//  Copyright © 2016 Rui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *datetimeLabel;
@property (weak, nonatomic) IBOutlet UITextView *posterTextView;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;


@end

