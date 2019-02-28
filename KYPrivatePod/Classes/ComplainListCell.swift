//
//  ComplainListCell.swift
//  IntelligentCommunityProprietorClient
//
//  Created by liyangyang on 2018/7/13.
//  Copyright © 2018年 liyangyang. All rights reserved.
//

import UIKit
import Kingfisher
import WTCommonSDK

//protocol ComplainListCellDelegate: NSObjectProtocol {
//    //第一个按钮的代理方法
//    func multiAction(model: RepairListModel)
//    //第二个按钮的代理方法
//    func cancelAction(model: RepairListModel)
//    
//    //点击图片
//    func showImage(model: RepairListModel, index: Int)
//}


class ComplainListCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    
    weak var delegate: RepairCellDelegate?
    
    var imageArray = [String]()
    
    //
    var titleLab: UILabel!
    //维修进度
    var repairProgressLab: UILabel!
    //期望维修时间
    var repairExpectedTimeLab: UILabel!
    //
    var detailInfoLab: UILabel!
    
    var collectionView: UICollectionView!
    
    var collectionBottomLine: UIView!
    
    var button1: UIButton!
    
    var button2: UIButton!
    
    
    var model: RepairListModel! {
        didSet {
            if model != nil {
                titleLab.text = model.Title
                detailInfoLab.text = model.Contents
                
                switch model.IsDeal {
                case 0:
                    repairProgressLab.text = "待处理"
                    repairProgressLab.textColor = COLOR_f7c83d
                    
                    button1.setTitle("提醒物业", for: .normal)
                    button2.isHidden = false
                    button2.setTitle("取消投诉", for: .normal)
                    
                case 1:
                    repairProgressLab.text = "处理中"
                    repairProgressLab.textColor = COLOR_45aef8
                    
                    button1.setTitle("确认解决", for: .normal)
                    button2.isHidden = true
                    
                case 2:
                    
                    repairProgressLab.text = "处理完成"
                    repairProgressLab.textColor = COLOR_45aef8
                    
                    button1.setTitle("评价", for: .normal)
                    button2.isHidden = true
                    
                    //已评价
                    if model.Score != nil {
                        button1.setTitle("查看评价", for: .normal)
                    }
                    
                default:
                    XLog("")
                }
                
                if model.HopeBgnTime != nil && model.HopeEndTime != nil {
                    repairExpectedTimeLab.text = (model.HopeBgnTime?.transformDayString() ?? "") + "至" + (model.HopeEndTime?.transformDayString() ?? "")
                } else {
                    repairExpectedTimeLab.text = ""
                }
                
                
                imageArray = model.ImgList1 ?? []
                if model.ImgList1?.count == 0 {
                    //修改约束
                    collectionView.isHidden = true
                    collectionBottomLine.snp.remakeConstraints { (make) in
                        make.left.right.equalToSuperview()
                        make.height.equalTo(0.5)
                        make.top.equalTo(detailInfoLab.snp.bottom)
                    }
                    
                } else {
                    
                    collectionView.isHidden = false
                    collectionView.reloadData()
                    
                    collectionBottomLine.snp.remakeConstraints { (make) in
                        make.left.right.equalToSuperview()
                        make.height.equalTo(0.5)
                        make.top.equalTo(collectionView.snp.bottom).offset(10)
                    }
                }
                
            }
            
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        loadUI()
        
    }
    
    private func loadUI() {
        contentView.backgroundColor = COLOR_BG
        
        let bgView = UIView(backgroundColor: UIColor.white)
        contentView.addSubview(bgView)
        
        titleLab = UILabel(font: FONT16, tColor: COLOR_474744, tAligment: .left)
        titleLab.numberOfLines = 0
        bgView.addSubview(titleLab)
        
        repairProgressLab = UILabel(font: FONT16, tColor: COLOR_f7c83d, tAligment: .right)
        bgView.addSubview(repairProgressLab)
        
        let repairExpectedTimeTitle = UILabel(title: "期望解决时间：",font: FONT14, tColor: COLOR_7a7a75, tAligment: .left)
        bgView.addSubview(repairExpectedTimeTitle)
        
        repairExpectedTimeLab = UILabel(font: FONT14, tColor: COLOR_7a7a75, tAligment: .left)
        bgView.addSubview(repairExpectedTimeLab)
        
        detailInfoLab = UILabel(font: FONT14, tColor: COLOR_7a7a75, tAligment: .left)
        detailInfoLab.numberOfLines = 0
        bgView.addSubview(detailInfoLab)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (SCREEN_WIDTH-20) / 5, height: (SCREEN_WIDTH-20) / 5)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "ImageBrowserCell", bundle: Bundle.main), forCellWithReuseIdentifier: ImageBrowserCell.cellIdentifier)
        
        bgView.addSubview(collectionView)
        
        collectionBottomLine = UIView(backgroundColor: COLOR_dededc)
        bgView.addSubview(collectionBottomLine)
        
        button1 = UIButton(type: .custom)
        button1.setTitleColor(COLOR_18ceb4, for: .normal)
        button1.titleLabel?.font = FONT14
        button1.setTitle("提醒物业", for: .normal)
        button1.layer.borderWidth = 1.0
        button1.layer.cornerRadius = 3
        button1.layer.borderColor = COLOR_18ceb4.cgColor
        button1.addTarget(self, action: #selector(button1Action(button:)), for: .touchUpInside)
        bgView.addSubview(button1)
        
        
        button2 = UIButton(type: .custom)
        button2.setTitleColor(COLOR_18ceb4, for: .normal)
        button2.titleLabel?.font = FONT14
        button2.setTitle("取消投诉", for: .normal)
        button2.layer.borderWidth = 1.0
        button2.layer.cornerRadius = 3
        button2.layer.borderColor = COLOR_18ceb4.cgColor
        button2.addTarget(self, action: #selector(button2Action(button:)), for: .touchUpInside)
        bgView.addSubview(button2)
        
        let bottomLine = UIView(backgroundColor: COLOR_dededc)
        bgView.addSubview(bottomLine)
        
        
        bgView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(0)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(repairProgressLab.snp.left)
            make.height.greaterThanOrEqualTo(30)
        }
        
        repairProgressLab.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab.snp.right)
            make.top.equalTo(10)
            make.height.equalTo(20)
            make.right.equalTo(-10)
        }
        
        repairExpectedTimeTitle.setContentHuggingPriority(UILayoutPriority.init(252), for: .horizontal)
        repairExpectedTimeTitle.setContentCompressionResistancePriority(UILayoutPriority.init(751), for: .horizontal)
        repairExpectedTimeTitle.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab.snp.left)
            make.top.equalTo(titleLab.snp.bottom).offset(5)
            make.height.equalTo(20)
        }
        
        repairExpectedTimeLab.snp.makeConstraints { (make) in
            make.left.equalTo(repairExpectedTimeTitle.snp.right)
            make.centerY.equalTo(repairExpectedTimeTitle.snp.centerY)
            make.height.equalTo(20)
            make.right.equalTo(-10)
        }
        
        detailInfoLab.snp.makeConstraints { (make) in
            make.left.equalTo(repairExpectedTimeTitle.snp.left)
            make.top.equalTo(repairExpectedTimeLab.snp.bottom).offset(5)
            make.right.equalTo(-10)
            make.height.greaterThanOrEqualTo(30)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(detailInfoLab.snp.bottom)
            make.height.equalTo((SCREEN_WIDTH-20) / 5)
        }
        
        collectionBottomLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(collectionView.snp.bottom).offset(10)
        }
        
        button1.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(collectionBottomLine.snp.bottom).offset(10)
            make.width.equalTo(70)
            make.height.equalTo(30)
            make.bottom.equalTo(-10)
        }
        
        button2.snp.makeConstraints { (make) in
            make.right.equalTo(button1.snp.left).offset(-10)
            make.centerY.equalTo(button1)
            make.height.width.equalTo(button1)
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        
    }
    
    @objc func button1Action(button: UIButton) {
        self.delegate?.multiAction(model: self.model)
    }
    
    @objc func button2Action(button: UIButton) {
        self.delegate?.cancelAction(model: self.model)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageBrowserCell.cellIdentifier, for: indexPath) as! ImageBrowserCell
        
        cell.picture?.kf.setImage(with: URL.init(string: imageArray[indexPath.row]))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.showImage(model: self.model, index: indexPath.row)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
