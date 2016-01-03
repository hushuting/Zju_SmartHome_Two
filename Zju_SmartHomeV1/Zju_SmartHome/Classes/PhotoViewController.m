

//
//  PhotoViewController.m
//  Zju_SmartHome
//
//  Created by chenyufeng on 15/12/12.
//  Copyright © 2015年 GJY. All rights reserved.
//

#import "PhotoViewController.h"
#import "HttpRequest.h"
#import "MBProgressHUD+MJ.h"
#import "STSaveSceneView.h"
#import "JYNewSqlite.h"
#import "YSRGBPatternViewController.h"
#define SCREEN_WIDTH self.view.frame.size.width
#define SCREEN_HEIGHT self.view.frame.size.height
@interface PhotoViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate,STSaveSceneViewDelegate>


@property(nonatomic,strong)UIImageView *imageView;
@property (strong, nonatomic) UIPopoverController *imagePickerPopover;
@property (nonatomic,assign) BOOL isOpenCameraOrAlbum;

@property(nonatomic,strong)STSaveSceneView *stView;

@property(nonatomic,copy)NSString *patternName;
@property(nonatomic,copy)NSString *rValue;
@property(nonatomic,copy)NSString *gValue;
@property(nonatomic,copy)NSString *bValue;

@end

@implementation PhotoViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setNavigationBar];
    
}
-(void)setNavigationBar
{
    UIButton *leftButton=[[UIButton alloc]init];
    [leftButton setImage:[UIImage imageNamed:@"ct_icon_leftbutton"] forState:UIControlStateNormal];
    leftButton.frame=CGRectMake(0, 0, 25, 25);
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [leftButton addTarget:self action:@selector(leftBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem=[[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    self.navigationItem.leftBarButtonItem = leftItem;
    UILabel *titleView=[[UILabel alloc]init];
    [titleView setText:@"照片取色"];
    titleView.frame=CGRectMake(0, 0, 100, 16);
    titleView.font=[UIFont systemFontOfSize:16];
    [titleView setTextColor:[UIColor whiteColor]];
    titleView.textAlignment=NSTextAlignmentCenter;
    self.navigationItem.titleView=titleView;
    
    //保存按钮
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(rightBtnClicked)];
    self.navigationItem.rightBarButtonItem=rightItem;
}
-(void)rightBtnClicked
{
    NSLog(@"===%@ %@ %@ %@ %@",self.logic_id,self.patternName,self.rValue,self.gValue,self.bValue);
    STSaveSceneView *stView=[STSaveSceneView initWithSaveScene];
    stView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    stView.delegate=self;
    [self.view addSubview:stView];
    self.navigationItem.rightBarButtonItem.enabled=NO;
}

- (void)viewWillAppear:(BOOL)animated{

  [super viewWillAppear:animated];

  if (!self.isOpenCameraOrAlbum) {
    if ([self.imagePickerPopover isPopoverVisible]) {
      [self.imagePickerPopover dismissPopoverAnimated:YES];
      self.imagePickerPopover = nil;
      return;
    }

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.editing = YES;
    imagePicker.delegate = self;
    //这里可以设置是否允许编辑图片；
    imagePicker.allowsEditing = false;

    imagePicker.sourceType = self.openType;

    //创建UIPopoverController对象前先检查当前设备是不是ipad
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
      self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
      self.imagePickerPopover.delegate = self;
    }
    else{
      [self presentViewController:imagePicker animated:YES completion:nil];
    }
    self.isOpenCameraOrAlbum = !self.isOpenCameraOrAlbum;
  }

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{

  UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
  
    NSLog(@"%f  %f",image.size.width,image.size.height);
  //将照片放入UIImageView对象中；
 // self.imageView.image = image;
    UIImageView *imageView=[[UIImageView alloc]init];
    imageView.frame=CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    [imageView setImage:image];
    [self.view addSubview:imageView];
    self.imageView=imageView;

  if (self.openType == UIImagePickerControllerSourceTypeCamera) {

    //将图片保存到图库
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);

  }else if(self.openType == UIImagePickerControllerSourceTypePhotoLibrary){

    //本身是从图库打开的，就不用保存到图库了；

  }

  //判断UIPopoverController对象是否存在
  if (self.imagePickerPopover) {
    [self.imagePickerPopover dismissPopoverAnimated:YES];
    self.imagePickerPopover = nil;
  }
  else
  {
    //关闭以模态形式显示的UIImagePickerController
    [self dismissViewControllerAnimated:YES completion:nil];
  }
    
}

#pragma mark 图片保存完毕的回调
- (void) image: (UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInf
{
  
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"不管怎样都会来到这里吧");
    //触点对象
    UITouch *touch=touches.anyObject;
    //触点位置
    CGPoint touchLocation=[touch locationInView:self.imageView];
    //触点颜色
    UIColor *positionColor=[self getPixelColorAtLocation:touchLocation];
    
    const CGFloat *components=CGColorGetComponents(positionColor.CGColor);
    
    NSString *rValue=[NSString stringWithFormat:@"%d",(int)(components[0]*255)];
    NSString *gValue=[NSString stringWithFormat:@"%d",(int)(components[1]*255)];
    NSString *bValue=[NSString stringWithFormat:@"%d",(int)(components[2]*255)];
    NSLog(@"我看看结果:%@ %@ %@",rValue,gValue,bValue);
    
    self.rValue=rValue;
    self.gValue=gValue;
    self.bValue=bValue;

  NSString *r = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[rValue intValue]]];
  NSString *g = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[gValue intValue]]];

  NSString *b = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[bValue intValue]]];

  [HttpRequest sendRGBColorToServer:self.logic_id redValue:r greenValue:g blueValue:b
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {

                              NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                              NSLog(@"成功: %@", string);


                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                              NSLog(@"失败: %@", error);
                              [MBProgressHUD showError:@"请检查网关"];

                            }];


}

- (UIColor*) getPixelColorAtLocation:(CGPoint)point
{
    UIColor* color = nil;
    UIImageView *colorImageView=self.imageView;
    CGImageRef inImage = colorImageView.image.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL)
    {
        return nil;
    }
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL)
    {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        @try
        {
            int offset = 4*((w*round(point.y))+round(point.x));
            //NSLog(@"offset: %d", offset);
            int alpha =  data[offset];
            int red = data[offset+1];
            int green = data[offset+2];
            int blue = data[offset+3];
            //            NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
            color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        }
        @catch (NSException * e)
        {
            NSLog(@"%@",[e reason]);
        }
        @finally
        {
            
        }
        
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data)
    {
        free(data);
    }
    
    return color;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage
{
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (int)(pixelsWide * 4);
    bitmapByteCount     =(int)(bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}



//实现的代理方法
-(void)cancelSaveScene
{
    [self.stView removeFromSuperview];
    self.navigationItem.rightBarButtonItem.enabled=YES;
}
-(void)noSaveScene
{
    [self.stView removeFromSuperview];
    self.navigationItem.rightBarButtonItem.enabled=YES;
}
-(void)saveNewScene:(NSString *)newSceneName
{
    self.navigationItem.rightBarButtonItem.enabled=YES;
    NSLog(@"－－－－%@",newSceneName);
    
    JYNewSqlite *jySqlite=[[JYNewSqlite alloc]init];
    jySqlite.patterns=[[NSMutableArray alloc]init];
    
    //打开数据库
    [jySqlite openDB];
    //创建表（如果已经存在时不会再创建的）
    [jySqlite createTable];
    //获取表中所有记录
    [jySqlite getAllRecord];
    
    //柔和模式
    [jySqlite insertRecordIntoTableName:@"patternTable" withField1:@"name" field1Value:newSceneName andField2:@"logoName" field2Value:@"rouhe_icon" andField3:@"bkgName" field3Value:@"rouhe_bg" andField4:@"rValue" field4Value:self.rValue andField5:@"gValue" field5Value:self.gValue andField6:@"bValue" field6Value:self.bValue];
    
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[YSRGBPatternViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

-(void)leftBtnClicked
{
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[YSRGBPatternViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}
@end
