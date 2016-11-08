//
//  RaffleViewController.swift
//  CocoaHeads
//
//  Created by Antoine van der Lee on 01/11/16.
//  Copyright © 2016 alee. All rights reserved.
//

import UIKit
import Moya
import JASON
import Moya_JASONMapper
import ALReactiveCocoaExtension
import ALDataRequestView
import ReactiveSwift
import ReactiveCocoa
import Nuke

enum MeetupGroup : String {
    case cocoaHeadsNL = "CocoaHeadsNL"
    
    var eventId:Int {
        switch self {
        case .cocoaHeadsNL:
            return 234463930
        }
    }
}

final class RaffleViewController: UIViewController {

    /// Change this to your meetup group
    private let currentMeetupGroup:MeetupGroup = .cocoaHeadsNL
    
    @IBOutlet private var dataRequestView: ALDataRequestView!
    @IBOutlet private var refreshMembersButton: UIButton!
    @IBOutlet private var startRaffleButton: UIButton!
    @IBOutlet private var membersStatusLabel: UILabel!
    @IBOutlet private var avatarImageView: UIImageView!
    
    private let membersList = MutableProperty<RSVPMemberList?>(nil)
    private let winningMember = MutableProperty<RSVPMember?>(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Reveal license raffle"
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.layer.borderWidth = 2
        
        dataRequestView.dataSource = self
        dataRequestView.backgroundColor = view.backgroundColor
        
        // Bind the enabled state of the raffle button to the empty state of the memberslist
        startRaffleButton.reactive.isEnabled <~ membersList.producer.map { $0 != nil && $0?.isEmpty == false }.observe(on: UIScheduler())
        
        // Bind the members status labels based on the memberslist
        membersStatusLabel.reactive.text <~ SignalProducer.combineLatest(membersList.producer, winningMember.producer).producer.map({ [weak self] (membersList, winningMember) -> String in
            if let winningMember = winningMember {
                return "Congratulations \(winningMember.name)!"
            } else if let membersList = membersList, let currentMeetupGroup = self?.currentMeetupGroup {
                return "A total of \(membersList.attending.count) members is attending \(currentMeetupGroup.rawValue) meetup"
            } else {
                return "We didn't find any members for the raffle"
            }
        }).observe(on: UIScheduler())
        
        // Bind the image of the winning member. If empty, show the reveal app icon
        winningMember.producer.onNext { [weak self] (member) in
            if let memberImageUrl = member?.photoUrl, let avatarImageView = self?.avatarImageView {
                Nuke.loadImage(with: memberImageUrl, into: avatarImageView)
            } else {
                // Show reveal app icon
                self?.avatarImageView.image = UIImage(named: "reveal_app_icon")
            }
        }.start()
        
        // Get the event members on startup
        getEventMembers()
    }
    
    private func getEventMembers(){
        provider.request(token: MeetupAPI.rsvps(groupName: currentMeetupGroup.rawValue, eventId: currentMeetupGroup.eventId))
            .on(started: { [weak self] () in
                self?.membersList.value = nil
                self?.winningMember.value = nil
            })
            .delay(1.0, on: QueueScheduler()) // A small delay to show the loading state for ALDataRequestView
            .filterSuccessfulStatusCodes() // Make sure only successful statuscodes pass
            .map(to: RSVPMemberList.self) // Map to the ALJSONAble object
            .attachToDataRequestView(dataRequestView: dataRequestView) // Attach it to our ALDataRequestView to show all states
            .onNext({ [weak self] (membersList) in
                self?.membersList.value = membersList
            })
            .start()
    }
    
    @IBAction func refreshMembers(_ sender: Any) {
        getEventMembers()
    }
    
    @IBAction func startRaffle(_ sender: Any) {
        winningMember.value = membersList.value?.giveMeARandomAttendingMember()
//        guard let membersList = membersList.value else { return }
//        let winner = membersList.giveMeARandomAttendingMember()
//        
//        let alert = UIAlertController(title: "The winner is..", message: "Congratulations \(winner.name)", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//        present(alert, animated: true, completion: nil)
    }
}

extension RaffleViewController : ALDataRequestViewDataSource {
    func loadingViewForDataRequestView(dataRequestView: ALDataRequestView) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    func reloadViewControllerForDataRequestView(dataRequestView: ALDataRequestView) -> ALDataReloadType? {
        guard let reloadVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReloadViewController") as? ALDataReloadType else { return nil }
        return reloadVC
    }
    
    func emptyViewForDataRequestView(dataRequestView: ALDataRequestView) -> UIView? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EmptyViewController").view
    }
}
