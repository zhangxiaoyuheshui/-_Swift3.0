//
//  ViewController.swift
//  ScanQRCode
//
//  Created by 张玉 on 16/11/23.
//  Copyright © 2016年 iHealth. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.标题
        title = "主页"
        
        // 2.button
        let button = UIButton(type: UIButtonType.custom)
        button.addTarget(self, action: #selector(startScan), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
        button.center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        if #available(iOS 10.0, *) {
            button.backgroundColor = UIColor(displayP3Red: 76.0/255, green: 160.0/255, blue: 220.0/255, alpha: 1)
        } else {
            // Fallback on earlier versions
        }
        button.setTitle("开始扫描", for: UIControlState.normal)
        button.adjustsImageWhenHighlighted = true
        view.addSubview(button);
        
    }
    
    func startScan() {
        
        let second = SecondViewController()
        
        navigationController?.pushViewController(second, animated: true)
        
        weak var weakSelf = self
        
        second.sencodBlock {(result: String) ->() in
            
            //显示扫描结果
            let label = UILabel(frame: CGRect(x: 100, y: 200, width: 100, height: 50))
            label.center = CGPoint(x: (weakSelf?.view.frame.width)!/2, y: (weakSelf?.view.frame.height)!/2 + 100)
            label.text = result
            weakSelf?.view .addSubview(label)
        }
    }
}

