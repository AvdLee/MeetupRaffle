//
//  RSVPMember.swift
//  CocoaHeads
//
//  Created by Antoine van der Lee on 08/11/16.
//  Copyright © 2016 alee. All rights reserved.
//

import Foundation
import JASON
import Moya_JASONMapper

enum RSVPMemberResponse : String {
    case attending = "yes"
    case notAttending = "no"
}

struct RSVPMember : ALJSONAble {
    
    let name:String
    let eventResponse:RSVPMemberResponse?
    let photoUrl:URL?
    
    init?(jsonData:JSON){
        name = jsonData["member"]["name"].stringValue
        photoUrl = jsonData["member"]["photo"]["highres_link"].nsURL
        eventResponse = RSVPMemberResponse(rawValue: jsonData["response"].stringValue)
    }
    
}
