//
//  RSVPMemberList.swift
//  CocoaHeads
//
//  Created by Antoine van der Lee on 08/11/16.
//  Copyright © 2016 alee. All rights reserved.
//

import Foundation
import JASON
import Moya_JASONMapper
import ALDataRequestView

struct RSVPMemberList : ALJSONAble {
    
    let attending:[RSVPMember]
    let notAttending:[RSVPMember]
    
    init?(jsonData: JSON) {
        let allMembers = jsonData.jsonArrayValue.map { RSVPMember(jsonData: $0)! }
        attending = allMembers.filter({ (member) -> Bool in
            return member.eventResponse == .attending
        })
        notAttending = allMembers.filter({ (member) -> Bool in
            return member.eventResponse == .notAttending
        })
    }
    
    func giveMeARandomAttendingMember() -> RSVPMember {
        return attending.randomElement
    }
}

extension RSVPMemberList : Emptyable {
    var isEmpty:Bool {
        return attending.count == 0 // We only check the attending members for an event
    }
}

private extension Array {
    var randomElement: Element {
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
}
