//
//  AddComplainController.swift
//  IntelligentCommunityProprietorClient
//
//  Created by liyangyang on 2018/7/12.
//  Copyright © 2018年 liyangyang. All rights reserved.
//
//新增投诉
import UIKit
import Moya
import RxSwift
import SwiftyJSON
import WTCommonSDK

class AddComplainController: BaseViewController, PhotoCellDelegate {

    let disposeBag = DisposeBag()
    
    var imageArray: [UIImage] = []
    
    @IBOutlet weak var titleLab: UITextField!
    
    @IBOutlet weak var contentText: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    //开始时间，结束时间
    @IBOutlet weak var startTime: UITextField!
    
    @IBOutlet weak var endTime: UITextField!
    
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "新增投诉"
        
        
        loadUI()
        
    }
    
    private func loadUI() {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: (SCREEN_WIDTH - 40) / 5, height: (SCREEN_WIDTH - 40) / 5)
        
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.cellIdentifier)
        collectionViewHeight.constant = (SCREEN_WIDTH - 40) / 5
        
        submitButton.layer.cornerRadius = 3
    }
    
    /// 删除照片
    ///
    /// - Parameter cell: 当前cell
    func deletePhoto(cell: PhotoCell) {
        XLog("删除图片")
        let indexPaht = collectionView.indexPath(for: cell)
        imageArray.remove(at: (indexPaht?.row)!)
        collectionView.reloadData()
    }
    
    @IBAction func voiceAction(_ sender: UIButton) {
        
        let voiceView = IFlyRecognizerView(center: CGPoint(x: SCREEN_WIDTH/2, y: SCREEN_HEIGHT/2))
        //设置为听写模式
        voiceView?.setParameter("iat", forKey: IFlySpeechConstant.ifly_DOMAIN())
        //asr_audio_path 是录音文件名，设置value为nil或者为空取消保存，默认保存目录在Library/cache下
        voiceView?.setParameter("iat.pcm", forKey: IFlySpeechConstant.asr_AUDIO_PATH())
        voiceView?.delegate = self
        voiceView?.start()
        view?.addSubview(voiceView!)
    }
    
    
    @IBAction func submitAction(_ sender: UIButton) {
        guard let title = titleLab.text, title != "" else {
            self.view.hudShowInfo("请输入报修问题")
            return
        }
        
        guard let content = contentText.text, content != "" else {
            self.view.hudShowInfo("请输入报修详情")
            return
        }
        
        //        guard imageArray.count > 0 else {
        //            self.view.hudShowInfo("请上传图片")
        //            return
        //        }
//        guard let start = startTime.text, let end = endTime.text, start != "" && end != "" else {
//            self.view.hudShowInfo("请选择时间")
//            return
//        }
        
        
        var uploadImages = [String: Any]()
        for (i, image) in imageArray.enumerated() {
            let imageName = "image" + String(i)
            XLog(imageName)
            uploadImages.updateValue(image, forKey: imageName)
        }
        uploadImages.updateValue(uploadFilePlace, forKey: "tp")
        XLog(uploadImages)
        //先上传图片
        view.hudShowWait(nil)
        provider.rx.request(MultiTarget(LoginApi.multiUploadImage(datas: uploadImages)))
            .handleError()
            .subscribe(onSuccess: { [weak self] (result) in
                
                //提交信息
                if let data = try? result.mapJSON() {
                    let json = JSON(data)
                    XLog(json["ret"].numberValue)
                    XLog(json["data"].arrayObject)
                    XLog(json["data"].arrayValue)
                    XLog(json["data"].arrayValue)
                    
                    var imageArguments = [[String: String]]()
                    if let array = json["data"].arrayObject as? [String] {
                        for item in array {
                            var dic = [String: String]()
                            dic.updateValue(item, forKey: "ImgName")
                            dic.updateValue(item, forKey: "ImgPath")
                            imageArguments.append(dic)
                        }
                    }
                    provider.rx.request(MultiTarget(ServiceApi.addComplain(CId: UserInfo.share.CId!, CName: UserInfo.share.CName!, RepUserId: UserInfo.share.Id!, RepUserName: UserInfo.share.MainName!, RepTel: UserInfo.share.Phone!, title: title, contents: content, expectedStartTime: self?.startTime.text ?? "", expectedEndTime: self?.endTime.text ?? "", ImgList: imageArguments)))
                        .handleError()
                        .subscribe(onSuccess: { (result) in
                            self?.view.hudShowSuccess("提交成功", completion: {
                                self?.navigationController?.popViewController(animated: true)
                            })
                        }, onError: { (error) in
                            self?.view.hudShowResultError(error: error)
                        })
                        .disposed(by: (self?.disposeBag)!)
                } else {
                    self?.view.hudHide()
                }
                
            }) { [weak self] (error) in
                self?.view.hudShowResultError(error: error)
            }
            .disposed(by: disposeBag)
        
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension AddComplainController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.cellIdentifier, for: indexPath) as! PhotoCell
        cell.delegate = self
        if imageArray.count < 5 {
            if indexPath.row == imageArray.count {
                cell.delbutton?.isHidden = true
                cell.imageView?.image = UIImage(named: "photographIcon.png")
            } else {
                cell.delbutton?.isHidden = false
                cell.imageView?.image = imageArray[indexPath.row]
            }
        } else {
            cell.delbutton?.isHidden = false
            cell.imageView?.image = imageArray[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imageArray.count < 5 {
            return imageArray.count + 1
        } else {
            return imageArray.count
        }
    }
    
    
}

extension AddComplainController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if imageArray.count == indexPath.row {
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let photograph = UIAlertAction(title: "拍照", style: .default, handler: { [weak self] (alertAction) in
                //
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = UIImagePickerControllerSourceType.camera
                    self?.present(picker, animated: true, completion: nil)
                }
                
            })
            let photoLibraryAction = UIAlertAction(title: "相册", style: .default) { [weak self] (action) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary
                    self?.present(imagePicker, animated: true, completion: nil)
                }
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertController.addAction(photograph)
            alertController.addAction(photoLibraryAction)
            alertController.addAction(cancel)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
    }
    
}

extension AddComplainController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let selectImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        let compressedImage = Tool.compressImageSize(selectImage!, toByte: imageSizeConfig)
        
        //let resizeImage = selectImage?.wxCompress()
        //        let compressedImage = UIImage(data: CompressImage.zipImage(originImage: selectImage!, maxImageSize: Int(1000 * 1000 * 0.2))!)
        //        let compressedImage = Tool.compressImageSize(selectImage!, toByte: 300*1024)
        //        self.argumentImageArray.append(["filename":CompressImage.getImageName(), "basecode":CompressImage.getBase64ImageStringFromImage(compressedImage)!])
        //        ZKProgressHUD.dismiss()
        self.imageArray.append(compressedImage)
        //        if imageArray.count > 3 {
        //            collectionViewHeight.constant = (SCREEN_WIDTH - 10) / 2 + 10
        //
        //        } else {
        //            collectionViewHeight.constant = (SCREEN_WIDTH - 10) / 4 + 10
        //        }
        
        self.collectionView.reloadData()
    }
    
}


extension AddComplainController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField === startTime {
            let inputController = XInputController(type: .timeAction)
            inputController.determineHandler = { date in
                textField.text = date.transformDayString()
            }
            self.present(inputController, animated: true)
            return false
        }
        
        if textField === endTime {
            let inputController = XInputController(type: .timeAction)
            inputController.determineHandler = { date in
                textField.text = date.transformDayString()
            }
            self.present(inputController, animated: true)
            return false
            
        }
        return true
    }
    
}

extension AddComplainController: IFlyRecognizerViewDelegate {
    
    func onCompleted(_ error: IFlySpeechError!) {
        XLog(error)
        
        if error.errorCode != 0 {
            MBProgressHUD.showInfo(error.errorDesc)
        }
        
    }
    
    
    func onResult(_ resultArray: [Any]!, isLast: Bool) {
        
        var resultStr: String = ""
        let resultDic = resultArray[0] as! [String: Any]
        
        for dic in resultDic {
            resultStr.append(dic.key)
        }
        
        
        var content = contentText.text as String
        content.append(ISRDataHelper.string(fromJson: resultStr))
        contentText.text = content
        
    }
    
    
}
