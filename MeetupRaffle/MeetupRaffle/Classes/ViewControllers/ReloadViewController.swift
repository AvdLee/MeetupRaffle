//
//  ReloadViewController.swift
//  CocoaHeads
//
//  Created by Antoine van der Lee on 08/11/16.
//  Copyright © 2016 alee. All rights reserved.
//

import UIKit
import ALDataRequestView

final class ReloadViewController: UIViewController, ALDataReloadType {

    @IBOutlet var retryButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppSettings.Colors.primaryBackground
    }

    func setupForReloadType(reloadType:ReloadType){
        
    }

}
