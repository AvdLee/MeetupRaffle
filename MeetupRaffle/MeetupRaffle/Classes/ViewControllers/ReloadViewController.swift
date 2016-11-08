//
//  ReloadViewController.swift
//  CocoaHeads
//
//  Created by Antoine van der Lee on 08/11/16.
//  Copyright © 2016 alee. All rights reserved.
//

import UIKit
import ALDataRequestView

class ReloadViewController: UIViewController, ALDataReloadType {

    @IBOutlet var retryButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func setupForReloadType(reloadType:ReloadType){
        
    }

}
