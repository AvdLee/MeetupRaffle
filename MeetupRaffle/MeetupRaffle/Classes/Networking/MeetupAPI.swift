//
//  MeetupAPI.swift
//  CocoaHeads
//
//  Created by Antoine van der Lee on 08/11/16.
//  Copyright © 2016 alee. All rights reserved.
//

import Foundation
import Moya

let provider = ReactiveCocoaMoyaProvider<MeetupAPI>()

enum MeetupAPI {
    case rsvps(groupName:String, eventId:Int)
}

extension MeetupAPI: TargetType {
    var baseURL: URL { return URL(string: "https://api.meetup.com")! }
    var path: String {
        switch self {
        case .rsvps(let groupName, let eventId):
            return "/\(groupName)/events/\(eventId)/rsvps"
        }
    }
    var method: Moya.Method {
        switch self {
        case .rsvps(_, _):
            return .get
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .rsvps(_, _):
            return [
                "sig_id": 187030538, // Make sure these are up to date for your account
                "sig": "1753151958af38f404ef59fbc434a6fa8a8f6097",  // Make sure these are up to date for your account
                "photo-host": "public"
            ]
        }
    }
    var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
    var task: Task {
        switch self {
        case .rsvps(_, _):
            return .request
        }
    }
    var multipartBody: [MultipartFormData]? {
        // Optional
        return nil
    }
}
