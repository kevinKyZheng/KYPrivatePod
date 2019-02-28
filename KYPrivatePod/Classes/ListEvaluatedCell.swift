//
//  ListEvaluatedCell.swift
//  IntelligentCommunityProprietorClient
//
//  Created by liyangyang on 2018/9/6.
//  Copyright © 2018年 liyangyang. All rights reserved.
//
//投诉、报修已评价cell
import UIKit
import WTCommonSDK

class ListEvaluatedCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    enum CellType {
        case repair//报修
        case complain//投诉
    }
    
    var imageArray = [String]()
    
    weak var delegate: RepairCellDelegate?
    
    //
    var titleLab: UILabel!
    //维修进度
    var repairProgressLab: UILabel!
    //期望维修时间
    var repairExpectedTimeLab: UILabel!
    //
    var detailInfoLab: UILabel!
    
    //评价信息
    var evaluateInfo: UIPaddingLabel!
    
    var collectionView: UICollectionView!
    
    var repairExpectedTimeTitle: UILabel!
    //cell类型
    var type: CellType!
    
    var model: RepairListModel! {
        didSet {
            if model != nil {
                if type == CellType.repair {
                    repairExpectedTimeTitle.text = "期望解决时间："
                } else {
                    repairExpectedTimeTitle.text = "期望维修时间："
                }
                
                titleLab.text = model.Title
                
                detailInfoLab.text = model.Contents
                
                if model.IsDeal == 2 && model.Score != nil {
                    repairProgressLab.text = "已评价"
                } else {
                    repairProgressLab.text = ""
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
                    evaluateInfo.snp.remakeConstraints { (make) in
                        make.top.equalTo(detailInfoLab.snp.bottom).offset(10)
                        make.left.equalTo(10)
                        make.right.equalTo(-10)
                        make.bottom.equalTo(-10)
                        make.height.greaterThanOrEqualTo(30)
                    }
                    
                } else {
                    
                    collectionView.isHidden = false
                    collectionView.reloadData()
                    
                    evaluateInfo.snp.remakeConstraints { (make) in
                        make.top.equalTo(collectionView.snp.bottom).offset(10)
                        make.left.equalTo(10)
                        make.right.equalTo(-10)
                        make.bottom.equalTo(-10)
                        make.height.greaterThanOrEqualTo(30)
                    }
                }
                
                switch model.Score! {
                case 1:
                    evaluateInfo.text = "评价：" + "好评，" + model.ScDesc!
                    case 2:
                    evaluateInfo.text = "评价：" + "好评，" + model.ScDesc!
                    case 3:
                    evaluateInfo.text = "评价：" + "好评，" + model.ScDesc!
                default:
                    XLog("无评价等级")
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
        
        repairProgressLab = UILabel(font: FONT16, tColor: COLOR_45aef8, tAligment: .right)
        bgView.addSubview(repairProgressLab)
        
        repairExpectedTimeTitle = UILabel(title: "期望解决时间：",font: FONT14, tColor: COLOR_7a7a75, tAligment: .left)
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
        
        
//        evaluateInfo = UILabel(font: FONT16, tColor: COLOR_7a7a75, tAligment: .left)
        evaluateInfo = UIPaddingLabel()
        evaluateInfo.font = FONT14
        evaluateInfo.textColor = COLOR_7a7a75
        evaluateInfo.textAlignment = .left
        evaluateInfo.textInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        evaluateInfo.backgroundColor = COLOR_fbfbf7
        evaluateInfo.layer.cornerRadius = 5
        evaluateInfo.layer.borderWidth = 0.1
        evaluateInfo.numberOfLines = 0
        evaluateInfo.layer.borderColor = COLOR_dededc.cgColor
        bgView.addSubview(evaluateInfo)
        
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
        
        evaluateInfo.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
            make.height.greaterThanOrEqualTo(30)
        }
        
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
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
