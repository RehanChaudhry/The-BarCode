//
//  SplitBillScannerViewController.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 13/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import AVFoundation

class SplitBillScannerViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
    
    @IBOutlet var tableHeaderView: UIView!
    @IBOutlet var tableFooterView: UIView!
    
    @IBOutlet var cameraContainer: UIView!
    
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    var session: AVCaptureSession?
    
    let scanSize = CGSize(width: 180.0, height: 180.0)
    
    var contentW: CGFloat = 0.0
    var contentH: CGFloat = 0.0
    
    var rectImageView: UIImageView!
    var scanningImageView: UIImageView!
    
    var viewModels: [OrderViewModel] = []
    
    var order: Order!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.order = Order.getMyCartDummyOrders().first
        
        self.cancelBarButtonItem.image = self.cancelBarButtonItem.image?.withRenderingMode(.alwaysOriginal)
        
        self.tableView.tableHeaderView = self.tableHeaderView
        self.tableView.tableFooterView = self.tableFooterView
        
        self.cameraContainer.layer.borderWidth = 2.0
        self.cameraContainer.layer.borderColor = UIColor.appGrayColor().cgColor
        
        self.contentW = self.view.frame.size.width - 32.0
        self.contentH = cameraContainer.frame.size.height
        
        self.tableView.register(cellType: OrderInfoTableViewCell.self)
        self.tableView.register(cellType: OrderStatusTableViewCell.self)
        self.tableView.register(cellType: OrderPaymentTableViewCell.self)
        
        self.rectImageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: self.scanSize))
        self.rectImageView.image = UIImage(named: "code-scanning-frame")
        self.cameraContainer.addSubview(self.rectImageView)
        
        self.scanningImageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 237.0, height: 43.0)))
        self.scanningImageView.image = UIImage(named: "splash-logo-scanning-line")
        self.cameraContainer.addSubview(self.scanningImageView)
        
        self.setUpCamera()
        self.setUpQRMask()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session?.startRunning()
        self.startAnimatingScanner()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.session?.stopRunning()
        self.stopAnimatingScanner()
    }
    
    //MARK: My Methods
    func resetScannerFrame() {
        let centerRect = CGRect(x: (contentW-scanSize.width)/2.0, y: (contentH-scanSize.height)/2.0, width: scanSize.width, height: scanSize.height)
        self.rectImageView.frame = centerRect
        self.scanningImageView.center = self.rectImageView.center
        
        var scanningImageViewFrame = self.scanningImageView.frame
        scanningImageViewFrame.origin.y = self.rectImageView.frame.origin.y
        self.scanningImageView.frame = scanningImageViewFrame
    }
    
    func startAnimatingScanner() {
        
        self.resetScannerFrame()
        
        var frame = self.scanningImageView.frame
        UIView.animate(withDuration: 0.8, delay: 0.1, options: [.curveEaseInOut, .autoreverse, .repeat], animations: {
            frame.origin.y = self.rectImageView.frame.origin.y + self.rectImageView.frame.height
            self.scanningImageView.frame = frame
        }) { (finished) in
            
        }
    }
    
    func stopAnimatingScanner() {
        self.scanningImageView.layer.removeAllAnimations()
    }
    
    func setupViewModel() {
        
        self.activityIndicatorView.stopAnimating()
        self.viewModels.removeAll()
        
        let barInfo = BarInfo(barName: self.order.barName)
        let barInfoSection = BarInfoSection(items: [barInfo])
        self.viewModels.append(barInfoSection)

        let orderProductsSection = OrderProductsInfoSection(items: self.order.orderItems)
        self.viewModels.append(orderProductsSection)

        let orderDiscountInfo1 = OrderDiscountInfo(title: "Standard offer redeem", price: -2.2)
        let orderDiscountInfo2 = OrderDiscountInfo(title: "Voucher - Buy one get one free", price: 0.0 )
        let orderDiscountSection = OrderDiscountSection(items: [orderDiscountInfo1, orderDiscountInfo2])
        self.viewModels.append(orderDiscountSection)
        
        let orderTotalBillInfo = OrderTotalBillInfo(title: "Total", price: 23.0 )
        let orderTotalBillInfoSection = OrderTotalBillInfoSection(items: [orderTotalBillInfo])
        self.viewModels.append(orderTotalBillInfoSection)
        
        self.tableView.reloadData()
    }
    
    //MARK: My IBActions
    @IBAction func closeBarButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}

// MARK: AVCaptureMetadataOutputObjectsDelegate
extension SplitBillScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        var stringValue = ""
        if metadataObjects.count > 0 {
            let metaDataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            if metaDataObject.type == AVMetadataObject.ObjectType.qr {
                stringValue = metaDataObject.stringValue ?? ""
            }
        }
        
        if stringValue.count > 0 {
            session?.stopRunning()
            print("QRCode: \(stringValue)")
            
            DispatchQueue.main.async {
                self.stopAnimatingScanner()
                self.setupViewModel()
            }
        }
    }
}

// MARK: Private Methods
extension SplitBillScannerViewController {
    
    func setUpCamera() {
        if checkCameraAvaliable() {
            if checkCameraAuthorise() {
                let device = AVCaptureDevice.default(for: AVMediaType.video)
                var input: AVCaptureDeviceInput;
                do {
                    input = try AVCaptureDeviceInput(device: device!)
                } catch let error as NSError {
                    print("error:\(error.localizedDescription)")
                    return
                }
                
                session = AVCaptureSession()
                
                session!.sessionPreset = AVCaptureSession.Preset.high
                if session!.canAddInput(input) {
                    session!.addInput(input)
                }
                
                let metaDataOutput = AVCaptureMetadataOutput()
                if session!.canAddOutput(metaDataOutput) {
                    session!.addOutput(metaDataOutput)
                }
                
                let dispatchQueue = DispatchQueue(label: "com.thebarcode.ios")
                metaDataOutput.setMetadataObjectsDelegate(self, queue: dispatchQueue)
                metaDataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
                
                var scanRect = CGRect(x: (contentW-scanSize.width)/2.0, y: (contentH-scanSize.height)/2.0, width: scanSize.width, height: scanSize.height)
            
                scanRect = CGRect(x: scanRect.origin.y/contentH, y: scanRect.origin.x/contentW, width: scanRect.size.height/contentH, height: scanRect.size.width/contentW)
                
                metaDataOutput.rectOfInterest = scanRect
                
                let previewLayer = AVCaptureVideoPreviewLayer(session: session!)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                
                let cameraContainerBounds = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width - 32.0, height: 218.0)
                previewLayer.frame = cameraContainerBounds
                self.cameraContainer.layer.insertSublayer(previewLayer, at: 0)
            }
        } else {
            debugPrint("Camera not available")
        }
    }
    
    func setUpQRMask() {
        
        self.resetScannerFrame()
        
        let centerRect = CGRect(x: (contentW-scanSize.width)/2.0, y: (contentH-scanSize.height)/2.0, width: scanSize.width, height: scanSize.height)
        
        let cameraContainerBounds = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width - 32.0, height: 218.0)
        let path = UIBezierPath(rect: cameraContainerBounds)
        let centerPath = UIBezierPath(rect: centerRect)
        path.append(centerPath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.black.withAlphaComponent(0.4).cgColor
        self.cameraContainer.layer.addSublayer(fillLayer)
    }
    
    func checkCameraAvaliable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera);
    }
    
    func checkCameraAuthorise() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if status == .restricted || status == .denied {
            
            let alertActionController = UIAlertController(title: "", message: "Please allow camera access to proceed", preferredStyle: .alert)
            alertActionController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertActionController, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension SplitBillScannerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let viewModel = self.viewModels[section]
        return viewModel.rowCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let viewModel = self.viewModels[indexPath.section]
        
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == viewModel.rowCount - 1
        
        if let section = viewModel as? OrderStatusSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderStatusTableViewCell.self)
            cell.setupCell(orderStatusInfo: section.items[indexPath.row], showSeparator: false)
            return cell

        } else if let section = viewModel as? BarInfoSection {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(barInfo: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
        
        } else if let section = viewModel as? OrderProductsInfoSection {
     
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderItem: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell

        } else if let section = viewModel as? OrderDiscountSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDiscountInfo: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? OrderDeliveryInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDeliveryInfo: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? OrderTotalBillInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderTotalBillInfo: section.items[indexPath.row], showSeparator: false)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else {
            
            return UITableViewCell()
        
        }
    }
         
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        
    }
}
