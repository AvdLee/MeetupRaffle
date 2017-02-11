//
//  MRButton.swift
//  MeetupRaffle
//
//  Created by Antoine van der Lee on 11/02/17.
//  Copyright © 2017 alee. All rights reserved.
//

import Foundation
import UIKit

final class MRButton : UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup(){
        setTitleColor(AppSettings.Colors.buttonText, for: UIControlState.normal)
    }
    
}
