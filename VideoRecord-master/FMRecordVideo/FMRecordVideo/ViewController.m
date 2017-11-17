//
//  ViewController.m
//  FMRecordVideo
//
//  Created by qianjn on 2017/2/27.
//  Copyright © 2017年 SF. All rights reserved.
//
//  Github:https://github.com/suifengqjn
//  blog:http://gcblog.github.io/
//  简书:http://www.jianshu.com/u/527ecf8c8753
#import "ViewController.h"
#import "FMImagePicker.h"
#import "FMFileVideoController.h"
#import "FMWriteVideoController.h"
#import "PickerViewController.h"
#import "PickeViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)UIImagePicker:(id)sender {
    
    PickeViewController *picker = [[PickeViewController alloc] initWithCaptureMode:CaptureModeVideo];
//    [self.navigationController pushViewController:picker animated:YES];
    [self presentViewController:picker animated:YES completion:nil];
    
}


- (IBAction)fileOut:(id)sender {
    
    FMFileVideoController *fileVC = [[FMFileVideoController alloc] init];
    UINavigationController *NAV = [[UINavigationController alloc] initWithRootViewController:fileVC];
    [self presentViewController:NAV animated:YES completion:nil];
    
    
}

- (IBAction)writer:(id)sender {
    
    FMWriteVideoController *writeVC = [[FMWriteVideoController alloc] init];
    UINavigationController *NAV = [[UINavigationController alloc] initWithRootViewController:writeVC];
    [self presentViewController:NAV animated:YES completion:nil];
    
}

-(UIView *)findView:(UIView *)aView withName:(NSString *)name{
    Class cl = [aView class];
    NSString *desc = [cl description];
    if ([name isEqualToString:desc])
        return aView;
    for (UIView *view in aView.subviews) {
        Class cll = [view class];
        NSString *stringl = [cll description];
        if ([stringl isEqualToString:name]) {
            return view;
        }
    }
    return nil;
}

-(void)addSomeElements:(UIViewController *)viewController{
    UIView *PLCameraView = [self findView:viewController.view withName:@"PLCameraView"];
    UIView *PLCropOverlay = [self findView:PLCameraView withName:@"PLCropOverlay"];
    UIView *bottomBar = [self findView:PLCropOverlay withName:@"PLCropOverlayBottomBar"];
    UIImageView *bottomBarImageForSave = [bottomBar.subviews objectAtIndex:0];
    UIButton *retakeButton=[bottomBarImageForSave.subviews objectAtIndex:0];
    [retakeButton setTitle:@"重拍"  forState:UIControlStateNormal];
    UIButton *useButton=[bottomBarImageForSave.subviews objectAtIndex:1];
    [useButton setTitle:@"保存" forState:UIControlStateNormal];
    UIImageView *bottomBarImageForCamera = [bottomBar.subviews objectAtIndex:1];
    UIButton *cancelButton=[bottomBarImageForCamera.subviews objectAtIndex:1];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self addSomeElements:viewController];
}



@end
