//
//  PickerViewController.m
//  FMRecordVideo
//
//  Created by 王战胜 on 2017/11/16.
//  Copyright © 2017年 SF. All rights reserved.
//

#import "PickerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface PickerViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UIImageView *mImageview;
@property (nonatomic, assign) BOOL isTakeVideo;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) AVPlayer *player;
@end

@implementation PickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    btn.backgroundColor=[UIColor redColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // Do any additional setup after loading the view.
}

-(void)btnClick{
    _isTakeVideo = YES;
    [self showPicker];
}

- (void)showPicker
{
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc]init];
        /**
         拾取源类型，sourceType是枚举类型：
         UIImagePickerControllerSourceTypePhotoLibrary：照片库
         ，默认值
         UIImagePickerControllerSourceTypeCamera：摄像头
         UIImagePickerControllerSourceTypeSavedPhotosAlbum：相簿
         */
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        /**
         摄像头设备，cameraDevice是枚举类型：
         UIImagePickerControllerCameraDeviceRear：前置摄像头
         UIImagePickerControllerCameraDeviceFront：后置摄像头
         */
        _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        
        /*! 视频最大录制时长，默认为10 minutes */
        _imagePicker.videoMaximumDuration = CGFLOAT_MAX;
        
        if (self.isTakeVideo) {
            /**
             媒体类型,默认情况下此数组包含kUTTypeImage，所以拍照时可以不用设置；但是当要录像的时候必须设置，可以设置为kUTTypeVideo（视频，但不带声音）或者kUTTypeMovie（视频并带有声音）
             */
            _imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
            
            /**
             视频质量，枚举类型：
             UIImagePickerControllerQualityTypeHigh：高清质量
             UIImagePickerControllerQualityTypeMedium：中等质量，适合WiFi传输
             UIImagePickerControllerQualityTypeLow：低质量，适合蜂窝网传输
             UIImagePickerControllerQualityType640x480：640*480
             UIImagePickerControllerQualityTypeIFrame1280x720：1280*720
             UIImagePickerControllerQualityTypeIFrame960x540：960*540
             */
            _imagePicker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
            
            /**
             摄像头捕获模式，捕获模式是枚举类型：
             UIImagePickerControllerCameraCaptureModePhoto：拍照模式
             UIImagePickerControllerCameraCaptureModeVideo：视频录制模式
             */
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            
        }else{
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}


#pragma mark ===============  拾取完成 ===============
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *urlPath = [url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlPath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(urlPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }else{
            NSLog(@"无法将视频保存到相簿");
        }
    }else if ([type isEqualToString:(NSString *)kUTTypeImage]){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误,错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功");
        //        NSURL *url = [NSURL fileURLWithPath:videoPath];
        //        _player = [AVPlayer playerWithURL:url];
        //        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        //        playerLayer.frame = self.view.frame;
        //        [_player play];
    }
}

#pragma mark ===============  取消拾取 ===============
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"取消拾取");
    [picker dismissViewControllerAnimated:YES completion:nil];
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

@end
