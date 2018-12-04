//
//  FiveADayDetailViewController.swift
//  TheBarCode
//
//  Created by Aasna Islam on 08/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable


protocol FiveADayDetailViewControllerDelegate: class {
    func fiveADayDetailViewController(controller: FiveADayDetailViewController, cancelButtonTapped sender: UIButton)
}

class FiveADayDetailViewController: UIViewController {

    @IBOutlet weak var imageView: AsyncImageView!
    
    @IBOutlet weak var gradientTitleView: GradientView!
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiveADayDetailViewControllerDelegate!

    var deal : FiveADayDeal!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(cellType: DealDetailTableViewCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.imageView.setImageWith(url: URL(string: self.deal.imageUrl.value), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        
        gradientTitleView.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: .bottom)
        gradientTitleView.alpha = 0.34

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: My Methods
    func showBarDetail(bar: Bar){
        let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
        let barDetailController = (barDetailNav.viewControllers.first as! BarDetailViewController)
        barDetailController.selectedBar = bar
        barDetailController.delegate = self
        self.present(barDetailNav, animated: true, completion: nil)
    }
    
    func showDirection(bar: Bar){
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let urlString = String(format: "comgooglemaps://?daddr=%f,%f&directionsmode=driving",bar.latitude.value,bar.longitude.value)
            let url = URL(string: urlString)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            let url = URL(string: "https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    //MARK: IBAction
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate.fiveADayDetailViewController(controller: self, cancelButtonTapped: sender)
        }
    }
    
}

extension FiveADayDetailViewController : UITableViewDelegate , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: DealDetailTableViewCell.self)
        cell.delegate = self
        cell.configCell(deal: deal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let bar = self.deal.establishment.value {
            self.showBarDetail(bar: bar)
        } else {
            debugPrint("Deal establishment not found")
        }
    }    
}

extension FiveADayDetailViewController : DealDetailTableViewCellDelegate {
    func dealDetailCell(cell: DealDetailTableViewCell, viewBarDetailButtonTapped sender: UIButton) {
        
        if let bar = self.deal.establishment.value {
            self.showBarDetail(bar: bar)
        } else {
            debugPrint("Deal establishment not found")
        }
        
    }
    
    func dealDetailCell(cell: DealDetailTableViewCell, viewDirectionButtonTapped sender: UIButton) {
        
        if let bar = self.deal.establishment.value {
            self.showDirection(bar: bar)
        } else {
            debugPrint("Deal establishment not found")
        }
    }    
}

//MARK: BarDetailViewControllerDelegate
extension FiveADayDetailViewController : BarDetailViewControllerDelegate {
    func barDetailViewController(controller: BarDetailViewController, cancelButtonTapped sender: UIBarButtonItem) {
    }
}
