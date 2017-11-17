//
//  PickeViewController.m
//  FMRecordVideo
//
//  Created by 王战胜 on 2017/11/16.
//  Copyright © 2017年 SF. All rights reserved.
//

#import "PickeViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
//相册
#import <AssetsLibrary/AssetsLibrary.h>
#define BAKit_ShowAlertWithMsg(msg) UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:msg preferredStyle:UIAlertControllerStyleAlert];\
UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确 定" style:UIAlertActionStyleDefault handler:nil];\
[alert addAction:sureAction];\
[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];

@interface PickeViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, assign)CaptureMode captureMode;
@end

@implementation PickeViewController

- (instancetype)initWithCaptureMode:(CaptureMode)mode
{
    self = [super init];
    if (self) {
        _captureMode = mode;
        /**
         拾取源类型，sourceType是枚举类型：
         UIImagePickerControllerSourceTypePhotoLibrary：照片库
         ，默认值
         UIImagePickerControllerSourceTypeCamera：摄像头
         UIImagePickerControllerSourceTypeSavedPhotosAlbum：相簿
         */
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        /**
         摄像头设备，cameraDevice是枚举类型：
         UIImagePickerControllerCameraDeviceRear：后置摄像头
         UIImagePickerControllerCameraDeviceFront：前置摄像头
         */
        self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        
        /*! 视频最大录制时长，默认为10 minutes */
        self.videoMaximumDuration = CGFLOAT_MAX;
        
        /**
         闪光灯模式，枚举类型：
         UIImagePickerControllerCameraFlashModeOff：关闭闪光灯
         UIImagePickerControllerCameraFlashModeAuto：闪光灯自动
         UIImagePickerControllerCameraFlashModeOn：打开闪光灯
         */
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        
        self.delegate = self;
        /*! 添加代理 */
        switch (mode) {
            case CaptureModeVideo:
            
                /**
                 媒体类型,默认情况下此数组包含kUTTypeImage，所以拍照时可以不用设置；但是当要录像的时候必须设置，可以设置为kUTTypeVideo（视频，但不带声音）或者kUTTypeMovie（视频并带有声音）
                 */
                self.mediaTypes = @[(NSString *)kUTTypeMovie];
                
                /**
                 视频质量，枚举类型：
                 UIImagePickerControllerQualityTypeHigh：高清质量
                 UIImagePickerControllerQualityTypeMedium：中等质量，适合WiFi传输
                 UIImagePickerControllerQualityTypeLow：低质量，适合蜂窝网传输
                 UIImagePickerControllerQualityType640x480：640*480
                 UIImagePickerControllerQualityTypeIFrame1280x720：1280*720
                 UIImagePickerControllerQualityTypeIFrame960x540：960*540
                 */
                self.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
                
                /**
                 摄像头捕获模式，捕获模式是枚举类型：
                 UIImagePickerControllerCameraCaptureModePhoto：拍照模式
                 UIImagePickerControllerCameraCaptureModeVideo：视频录制模式
                 */
                self.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
                
                break;
            case CaptureModePhoto:
                self.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                break;
                
            default:
                break;
        }
        
    }
    return self;
}



#pragma mark UIImagePickerControllerDelegate
/*! 完成拾取 */
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

/*! 取消拾取 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"取消拾取");
    [picker dismissViewControllerAnimated:YES completion:nil];
}




- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //检测相机是否打开
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) ) {
        /**
         AVAuthorizationStatusNotDetermined = 0,   //用户还未决定是否给程序授权相机权限
         AVAuthorizationStatusRestricted,<span style="white-space:pre">    </span>//没有授权相机权限，可能是家长控制权限
         AVAuthorizationStatusDenied,<span style="white-space:pre">        </span>//用户拒绝程序拥有相机权限
         AVAuthorizationStatusAuthorized<span style="white-space:pre">     </span>//用户授权程序访问相机
         */
        NSString *mediaType = AVMediaTypeVideo;// Or AVMediaTypeAudio
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        NSLog(@"---cui--authStatus--------%ld",(long)authStatus);
        // This status is normally not visible—the AVCaptureDevice class methods for discovering devices do not return devices the user is restricted from accessing.
        if(authStatus ==AVAuthorizationStatusRestricted){
            NSLog(@"Restricted");
        }else if(authStatus == AVAuthorizationStatusDenied){
            // The user has explicitly denied permission for media capture.
            NSLog(@"Denied");     //应该是这个，如果不允许的话
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:actionCancel];
            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            [alert addAction:actionOK];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if(authStatus == AVAuthorizationStatusAuthorized){//允许访问
            // The user has explicitly granted permission for media capture, or explicit user permission is not necessary for the media type in question.
            NSLog(@"Authorized");
            
        }else if(authStatus == AVAuthorizationStatusNotDetermined){
            // Explicit user permission is required for media capture, but the user has not yet granted or denied such permission.
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                if(granted){//点击允许访问时调用
                    //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                    NSLog(@"Granted access to %@", mediaType);
                }
                else {
                    NSLog(@"Not granted access to %@", mediaType);
                }
                
            }];
        }else {
            NSLog(@"Unknown authorization status");
        }
    }
    
    //检测麦克风功能是否打开
    if (_captureMode == CaptureModeVideo) {
        [[AVAudioSession sharedInstance]requestRecordPermission:^(BOOL granted) {
            if (!granted)
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在设备的\"设置-隐私-麦克风\"中允许访问麦克风。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
                [alert addAction:actionCancel];
                UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                [alert addAction:actionOK];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
    
    
    /**
     ALAuthorizationStatusNotDetermined = 0, 用户尚未做出了选择这个应用程序的问候
     ALAuthorizationStatusRestricted,        此应用程序没有被授权访问的照片数据。可能是家长控制权限。
     ALAuthorizationStatusDenied,            用户已经明确否认了这一照片数据的应用程序访问.
     ALAuthorizationStatusAuthorized         用户已授权应用访问照片数据.
     */
    int author = [ALAssetsLibrary authorizationStatus];
    NSLog(@"author type:%d",author);
    if(author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
        // The user has explicitly denied permission for media capture.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法使用相册"
                                                        message:@"请在iPhone的\"设置-隐私-照片\"中允许访问照片。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
    // Do any additional setup after loading the view.
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
