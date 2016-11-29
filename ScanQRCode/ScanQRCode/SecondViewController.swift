//
//  SecondViewController.swift
//  ScanQRCode
//
//  Created by 张玉 on 16/11/24.
//  Copyright © 2016年 iHealth. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    var scanView: ScanView?
    
    var sBlock: ((_ result: String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "二维码扫描"
        
        scanView = ScanView.init(frame: view.frame, superView: view)
        
        scanView?.delegate = self
        
        view.addSubview(scanView!)
        
    }
    
    // 扫描的回调
    func sencodBlock(myblock:@escaping (_ result: String) -> ())
    {
        sBlock = myblock
    }
}

// MARK: scanView代理
extension SecondViewController: ScanViewDelegate {
    
    func scanResult(result: String) {
       
        _ = navigationController?.popViewController(animated: true)
        self.sBlock!(result)
    }
}
