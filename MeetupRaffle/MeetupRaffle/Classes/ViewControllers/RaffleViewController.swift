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

final class RaffleViewController: UIViewController {

    @IBOutlet private var dataRequestView: ALDataRequestView!
    @IBOutlet private var refreshMembersButton: UIButton!
    @IBOutlet private var startRaffleButton: UIButton!
    @IBOutlet private var membersStatusLabel: UILabel!
    @IBOutlet private var avatarImageView: UIImageView!
    
    private let membersList = MutableProperty<RSVPMemberList?>(nil)
    private let winningMember = MutableProperty<RSVPMember?>(nil)
    private let raffleIsRunning = MutableProperty<Bool>(false)
    private var raffleDisposable:Disposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Reveal license raffle"
        
        view.backgroundColor = AppSettings.Colors.primaryBackground
        membersStatusLabel.textColor = AppSettings.Colors.primaryText
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.layer.borderWidth = 2
        
        dataRequestView.dataSource = self
        dataRequestView.backgroundColor = view.backgroundColor
        
        // Bind the enabled state of the raffle button to the empty state of the memberslist
        startRaffleButton.reactive.isEnabled <~ SignalProducer.combineLatest(membersList.producer, raffleIsRunning.producer).map({ (membersList, raffleIsRunning) -> Bool in
            return membersList != nil && membersList?.isEmpty == false && raffleIsRunning == false
        }).observe(on: UIScheduler())
        
        // Disable the refresh button when a raffle is running
        refreshMembersButton.reactive.isEnabled <~ raffleIsRunning.producer.map { $0 == false }.observe(on: UIScheduler())
        
        // Bind the members status labels based on the memberslist
        membersStatusLabel.reactive.text <~ SignalProducer.combineLatest(membersList.producer, winningMember.producer).producer.map({ [weak self] (membersList, winningMember) -> String in
            if let winningMember = winningMember {
                return "Congratulations \(winningMember.name)!"
            } else if let membersList = membersList {
                return "A total of \(membersList.attending.count) members is attending \(AppSettings.Meetup.name)"
            } else {
                return "We didn't find any members for the raffle"
            }
        }).observe(on: UIScheduler())
        
        // Bind the image of the winning member. If empty, show the reveal app icon
        winningMember.producer.observe(on: UIScheduler()).onNext { [weak self] (member) in
            if let memberImageUrl = member?.photoUrl, let avatarImageView = self?.avatarImageView {
                Nuke.loadImage(with: memberImageUrl, into: avatarImageView)
            } else {
                self?.showRevealAppIcon()
            }
        }.start()
        
        // Get the event members on startup
        getEventMembers()
    }
    
    private func showRevealAppIcon(){
        avatarImageView.image = UIImage(named: "raffle_logo")
    }
    
    private func getEventMembers(){
        raffleDisposable?.dispose()
        provider.request(token: MeetupAPI.rsvps(groupName: AppSettings.Meetup.group, eventId: AppSettings.Meetup.eventId))
            .on(started: { [weak self] () in
                self?.showRevealAppIcon()
                self?.winningMember.value = nil
                self?.membersList.value = nil
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
        raffleDisposable?.dispose()
        raffleDisposable = membersList.producer
            .skipNil()
            .onStarted { [weak self] in
                self?.showRevealAppIcon()
                self?.raffleIsRunning.value = true // This will disable the raffle button
            }
            .delay(3.0, on: QueueScheduler()) // Make the raffle more exiting with a delay of 3.0 seconds!
            .onNext { [weak self] (membersList) in
                self?.winningMember.value = membersList.giveMeARandomAttendingMember()
                self?.raffleIsRunning.value = false // This will enable the raffle button again
            }
            .attachToDataRequestView(dataRequestView: dataRequestView)
            .start()
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
