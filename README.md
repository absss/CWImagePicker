如何使用：

CWIPImagePickerOption * option = [[CWIPImagePickerOption alloc]init];
//可裁剪
option.needCrop = YES;
//使用相机还是相册
option.sourceType = CWImagePickerControllerSourceTypeCamera;

//使用自定义图片选择器，支持单选图片和裁剪，选多张图片，不支持拍照
CWImagePickerViewController * picker = [[CWImagePickerViewController alloc]initWithOption: option];

//使用系统提供的UIImagePickerController的子类，支持单张图片选择和裁剪，支持拍照
CWIPSystemImagePickViewController * picker2 = [[CWIPSystemImagePickViewController alloc]initWithOption: option];
//设置代理
picker2.cwDelegate = self;
picker.cwDelegate = self;
//弹出
[self presentViewController:picker2 animated:YES completion:nil];

注意事项：
3 只支持iOS8以上系统
2 拍照需要真机
3 在info.plist文件中确保存在以下keys:
Privacy - Camera Usage Description   //使用相机
Privacy - Photo Library Usage Description //使用相册
Localized resources can be mixed  //确保显示当地语言
