//
//  ComplainListController.swift
//  IntelligentCommunityProprietorClient
//
//  Created by liyangyang on 2018/7/12.
//  Copyright © 2018年 liyangyang. All rights reserved.
//

//投诉列表
import UIKit
import Moya
import RxSwift
import EmptyKit
import MJRefresh
import WTCommonSDK
import SKPhotoBrowser

class ComplainListController: BaseViewController {
    
    let disposeBag = DisposeBag()
    
    var tableView: UITableView!
    
    var dataSource: [RepairListModel] = Array()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.hudShowWait(nil)
        loadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "投诉"
        view.backgroundColor = COLOR_BG
        
        loadUI()
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.loadData()
        })
        
    }
    
    private func loadData() {
        provider.rx.request(MultiTarget(ServiceApi.getComplainList(userid: UserInfo.share.Id!)))
            .handleError()
            .mapObject(RepairListResultModel.self)
            .subscribe(onSuccess: { [weak self] (result) in
                self?.view.hudHide()
                self?.tableView.mj_header.endRefreshing()
                self?.isLoading = true
                self?.dataSource = result.data!
                self?.tableView.reloadData()
                
                
            }) { [weak self] (error) in
                self?.tableView.mj_header.endRefreshing()
                self?.view.hudShowResultError(error: error)
            }
            .disposed(by: disposeBag)
        
    }
    
    
    
    private func loadUI() {
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = COLOR_BG
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.ept.dataSource = self
        tableView.ept.delegate = self
        tableView.register(ComplainListCell.self, forCellReuseIdentifier: ComplainListCell.cellIdentifier)
        tableView.register(ListEvaluatedCell.self, forCellReuseIdentifier: ListEvaluatedCell.cellIdentifier)
        view.addSubview(tableView)
        
        
        let addButton = UIButton(type: .custom)
        addButton.setTitle("+新增投诉", for: .normal)
        addButton.setTitleColor(UIColor.white, for: .normal)
        addButton.backgroundColor = COLOR_18ceb4
        addButton.layer.cornerRadius = 3
        addButton.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        view.addSubview(addButton)
        
        
        
        addButton.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
//            make.top.equalTo(tableView.snp.bottom).offset(5)
            make.height.equalTo(50)
            make.bottom.equalTo(self.view.snp_bottomMargin).offset(-10)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(addButton.snp.top).offset(-5)
        }
        
        
    }
    
    
    //MARK: - 添加投诉
    @objc private func addAction() {
        let controller = AddComplainController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension ComplainListController: UITableViewDelegate {
    
    
    
    
}

extension ComplainListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = dataSource[indexPath.row]
        if model.IsDeal == 2 && model.Score != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: ListEvaluatedCell.cellIdentifier, for: indexPath) as! ListEvaluatedCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.model = model
            cell.type = .complain
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ComplainListCell.cellIdentifier, for: indexPath) as! ComplainListCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.model = dataSource[indexPath.row]
            return cell
        }
        
    }
    
}

extension ComplainListController: RepairCellDelegate {
    
    func multiAction(model: RepairListModel) {
        switch model.IsDeal! {
        case 0:
            //提醒物业
            self.view.hudShowWait(nil)
            provider.rx.request(MultiTarget(ServiceApi.addSystemMessage(CmpId: UserInfo.share.CmpId ?? 0, CId: UserInfo.share.CId ?? 0, UserId: UserInfo.share.Id ?? 0, SourceId: model.Id ?? 0, MsgType: "5")))
                .subscribe(onSuccess: { [weak self] (result) in
                    //
                    self?.view.hudShowSuccess("已发送提醒")
                }) { [weak self] (error) in
                    //
                    self?.view.hudShowResultError(error: error)
                }
                .disposed(by: disposeBag)
            
            
        case 1:
            //确认解决
            UIAlertController.showConfirm(title: "贴心提醒", message: "确定此次问题解决了吗？", confirmButtonTitle: "确定", in: self) { [weak self] _ in
                //
                self?.view.hudShowWait(nil)
                provider.rx.request(MultiTarget(ServiceApi.confirmComplain(Id: model.Id!)))
                    .handleError()
                    .subscribe(onSuccess: { (result) in
                        self?.view.hudShowSuccess(nil)
                        self?.loadData()
                    }, onError: { (error) in
                        self?.view.hudShowResultError(error: error)
                    })
                    .disposed(by: (self?.disposeBag)!)
            }
            
        case 2:
            
            if model.Score != nil {
                //查看评价
                XLog("查看评价")
                let alert = XInputController(type: .evaluateAction)
                alert.confirmAction = { [weak self] (level, content) in
                    self?.view.hudShowWait(nil)
                    provider.rx.request(MultiTarget(ServiceApi.evaluateComplain(Id: model.Id!, Score: level, ScDesc: content)))
                        .handleError()
                        .subscribe(onSuccess: { (result) in
                            self?.view.hudHide()
                            MBProgressHUD.showSuccess("已评价")
                            self?.loadData()
                        }, onError: { (error) in
                            self?.view.hudShowResultError(error: error)
                        })
                        .disposed(by: (self?.disposeBag)!)
                    
                }
                self.present(alert, animated: true)

                
            } else {
                //评价
                let alert = XInputController(type: .evaluateAction)
                alert.confirmAction = { [weak self] (level, content) in
                    self?.view.hudShowWait(nil)
                    provider.rx.request(MultiTarget(ServiceApi.evaluateComplain(Id: model.Id!, Score: level, ScDesc: content)))
                        .handleError()
                        .subscribe(onSuccess: { (result) in
                            self?.view.hudHide()
                            MBProgressHUD.showSuccess("已评价")
                            self?.loadData()
                        }, onError: { (error) in
                            self?.view.hudShowResultError(error: error)
                        })
                        .disposed(by: (self?.disposeBag)!)
                    
                }
                self.present(alert, animated: true)
            }
            
        default:
            XLog("no")
        }
    }
    
    func cancelAction(model: RepairListModel) {
        switch model.IsDeal! {
        case 0:
            //取消报修
            XLog("取消投诉")
            
            UIAlertController.showConfirm(title: "贴心提醒", message: "取消后此投诉将删除，确定要取消此次投诉吗？", confirmButtonTitle: "确定", in: self) { [weak self] _ in
                self?.view.hudShowWait(nil)
                provider.rx.request(MultiTarget(ServiceApi.cancelComplain(Ids: model.Id!.stringValue)))
                    .handleError()
                    .subscribe(onSuccess: { (result) in
                        self?.view.hudHide()
                        MBProgressHUD.showSuccess(nil)
                        self?.loadData()
                        
                    }, onError: { (error) in
                        self?.view.hudShowResultError(error: error)
                    })
                    .disposed(by: (self?.disposeBag)!)
            }
            
        default:
            XLog("no")
        }
        
    }
    
    func showImage(model: RepairListModel, index: Int) {
        
        var images = [SKPhotoProtocol]()
        for urlstr in model.ImgList1! {
            let photo = SKPhoto.photoWithImageURL(urlstr)
            images.append(photo)
        }
        
        let browser = SKPhotoBrowser(photos: images, initialPageIndex: index)
        present(browser, animated: true, completion: {})
        
    }
    
}


extension ComplainListController: EmptyDataSource {
    func customViewForEmpty(in view: UIView) -> UIView? {
        
        let aview = CustomEmptyView(type: .Tousu)
        return aview
    }
}
extension ComplainListController: EmptyDelegate {
    func emptyShouldDisplay(in view: UIView) -> Bool {
        return self.isLoading;
    }
}


