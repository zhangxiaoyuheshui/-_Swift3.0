//
//  ScanView.swift
//  ScanQRCode
//
//  Created by 张玉 on 16/11/23.
//  Copyright © 2016年 iHealth. All rights reserved.
//

import UIKit
import AVFoundation

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height

// 代理
protocol ScanViewDelegate:NSObjectProtocol {
    
    func scanResult(result: String)
    
}

class ScanView: UIView {
  
    var clearViewRect: CGRect?
    var scanView: UIView?
    var scanLineTimer:Timer?
    
    public weak var delegate:ScanViewDelegate?
    
    
    class func scanViewWithView(superView: UIView) ->ScanView {
        
        let scanView = ScanView(frame: superView.frame, superView: superView)
        
        return scanView
    }
    
    init(frame: CGRect, superView: UIView) {
       
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        setupScanView(superView: superView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupScanView(superView: UIView) {
        
        // 1.判断能否添加输入设备
        if !session.canAddInput(inputDevice)
        {
            return
        }
        // 2.判断能否添加输出对象
        if !session.canAddOutput(output)
        {
            return
        }
        // 3.添加输入输出对象
        session.addInput(inputDevice)
        session.addOutput(output)
        
        // 4.告诉输出对象的数据类型
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        // 5.设置代理监听输出对象输出的数据
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // 6.添加预览图层
        superView.layer.insertSublayer(previewLayer, at: 0)
        
        session.startRunning()
    }
    
    // MARK: 扫描页面绘画
    override func draw(_ rect: CGRect) {
        
    
        let screenRect: CGRect = UIScreen.main.bounds
        
        let screenSize: CGSize = screenRect.size
        
        let screenDrawRect: CGRect = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        
        let transparentArea = CGSize(width: 200, height: 200)
        
        let clearDrawRect = CGRect(x: screenDrawRect.size.width / 2 - transparentArea.width / 2, y: screenDrawRect.size.height / 2 - transparentArea.height / 2, width: transparentArea.width, height: transparentArea.height)
        
        clearViewRect = clearDrawRect
        
        let ctx = UIGraphicsGetCurrentContext()
        
        setViewRect(screenDrawRect: screenDrawRect, clearDrawRect: clearDrawRect, ctx: ctx!)
        
    }
    func setViewRect(screenDrawRect: CGRect, clearDrawRect:CGRect, ctx:CGContext) -> Void {
        // 1.整个背景的颜色
        ctx.setFillColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.5)
        ctx.fill(screenDrawRect)
        // 2.清空扫描框
        ctx.clear(clearDrawRect)  //clear the center rect  of the layer
        // 3.角
        addCornerLine(clearDrawRect: clearDrawRect, ctx: ctx)
        // 4.线
        scanView = UIView(frame: CGRect(x: clearDrawRect.origin.x, y: clearDrawRect.origin.y, width: clearDrawRect.size.width, height: 1.5))
        scanView?.backgroundColor = UIColor(colorLiteralRed: 80.0/255, green: 202.0/255, blue: 74.0/255, alpha: 1)
        self.addSubview(scanView!)
        
        if scanLineTimer == nil {
           
            moveUpAndDownLine()
            createTimer()
        }
    }
    func addCornerLine(clearDrawRect: CGRect, ctx:CGContext) -> Void {
        //画四个边角
        ctx.setLineWidth(2.5)
        ctx.setStrokeColor(red: 80.0/255, green: 202.0/255, blue: 74.0/255, alpha: 1)
        //左上角
        let poinsTopLeftA:[CGPoint] = [
            CGPoint(x: clearDrawRect.origin.x+0.7, y: clearDrawRect.origin.y),
            CGPoint(x:clearDrawRect.origin.x+0.7 , y:clearDrawRect.origin.y + 15)
        ]
        
        let ppoinsTopLeftB:[CGPoint] = [
            CGPoint(x: clearDrawRect.origin.x, y: clearDrawRect.origin.y + 0.7),
            CGPoint(x:clearDrawRect.origin.x+15 , y:clearDrawRect.origin.y + 0.7)
        ]
        ctx.addLines(between: poinsTopLeftA)
        ctx.addLines(between: ppoinsTopLeftB)

        //左xia角
        let poinsBottomLeftA:[CGPoint] = [
            CGPoint(x:clearDrawRect.origin.x + 0.7, y:clearDrawRect.origin.y + clearDrawRect.size.height - 15),
            CGPoint(x:clearDrawRect.origin.x + 0.7,y:clearDrawRect.origin.y + clearDrawRect.size.height)
        ]
        
        let poinsBottomLeftB:[CGPoint] = [
            CGPoint(x:clearDrawRect.origin.x , y:clearDrawRect.origin.y + clearDrawRect.size.height - 0.7),
            CGPoint(x:clearDrawRect.origin.x + 0.7 + 15, y:clearDrawRect.origin.y + clearDrawRect.size.height - 0.7)
        ]
        ctx.addLines(between: poinsBottomLeftA)
        ctx.addLines(between: poinsBottomLeftB)

        //右上角        
        //youshang角
        let poinsTopRightA:[CGPoint] = [
            CGPoint(x:clearDrawRect.origin.x + clearDrawRect.size.width - 15, y:clearDrawRect.origin.y + 0.7),
            CGPoint(x:clearDrawRect.origin.x + clearDrawRect.size.width, y:clearDrawRect.origin.y + 0.7)
        ]
        
        let poinsTopRightB:[CGPoint] = [
            CGPoint(x:clearDrawRect.origin.x + clearDrawRect.size.width - 0.7, y:clearDrawRect.origin.y),
            CGPoint(x:clearDrawRect.origin.x + clearDrawRect.size.width - 0.7, y:clearDrawRect.origin.y + 15 + 0.7)
        ]
        ctx.addLines(between: poinsTopRightA)
        ctx.addLines(between: poinsTopRightB)

        // youxiajiao
        let poinsBottomRightA:[CGPoint] = [
            CGPoint(x:clearDrawRect.origin.x + clearDrawRect.size.width - 0.7 , y:clearDrawRect.origin.y + clearDrawRect.size.height - 15),
            CGPoint(x:clearDrawRect.origin.x - 0.7 + clearDrawRect.size.width, y:clearDrawRect.origin.y + clearDrawRect.size.height)
        ]
        
        let poinsBottomRightB:[CGPoint] = [
            CGPoint(x:clearDrawRect.origin.x + clearDrawRect.size.width - 15 , y:clearDrawRect.origin.y + clearDrawRect.size.height-0.7),
            CGPoint(x:clearDrawRect.origin.x + clearDrawRect.size.width, y:clearDrawRect.origin.y + clearDrawRect.size.height - 0.7 )
        ]
        ctx.addLines(between: poinsBottomRightA)
        ctx.addLines(between: poinsBottomRightB)

        ctx.strokePath()

    }
    
    func moveUpAndDownLine() {
        let readerFrame = self.frame
        let viewFinderSize = clearViewRect!.size
        var scanLineframe = scanView!.frame
        scanLineframe.origin.y = (readerFrame.size.height - (viewFinderSize.height))/2
        scanView?.frame = scanLineframe
        scanView?.isHidden = false
        

        UIView.animate(withDuration:  2.0 - 0.05, animations: {() -> Void in
            var scanLineframe = self.scanView!.frame
            scanLineframe.origin.y =
                (readerFrame.size.height + viewFinderSize.height)/2 -
                self.scanView!.frame.size.height
            self.scanView!.frame = scanLineframe

        } , completion: {(Bool) -> Void in
            self.scanView?.isHidden = true
        })
        
    }
    
    /// 创建Timer
    func createTimer() {
        scanLineTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(moveUpAndDownLine), userInfo: nil, repeats: true)
    }
    // MARK: - private lazy
    
    // 1.回话
    lazy var session:AVCaptureSession  = AVCaptureSession()
    
    // 2.输入设备（相机）
    private lazy var inputDevice: AVCaptureDeviceInput? = {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do{
            return try AVCaptureDeviceInput(device: device)
        }catch{
            print(error)
            return nil
        }
    }()
    // 3.输出对象
    private lazy var output: AVCaptureMetadataOutput = {
        let out = AVCaptureMetadataOutput()
        
        // 一个out的属性，可设置扫描区域：rectOfInterest
        out.rectOfInterest = CGRect(x: 124.0/kScreenHeight, y:60.0/kScreenWidth, width: 200.0/kScreenHeight, height:200.0/kScreenWidth)
        return out
    }()
    
    // 4.预览
    private lazy var previewLayer: AVCaptureVideoPreviewLayer! = {
        // 1.创建预览
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        // 2.设置
        layer!.frame = self.frame
        // 3.设置填充模式
        layer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        return layer
    }()
}
extension ScanView:AVCaptureMetadataOutputObjectsDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
       
        let readableCodeObject: AVMetadataMachineReadableCodeObject = metadataObjects.last as! AVMetadataMachineReadableCodeObject

        print(readableCodeObject.stringValue)
        
        if scanLineTimer != nil
        {
            scanLineTimer?.invalidate()
            scanLineTimer = nil
        }
        session.stopRunning()
        // delegate
        delegate?.scanResult(result: readableCodeObject.stringValue)
        
    }
}

