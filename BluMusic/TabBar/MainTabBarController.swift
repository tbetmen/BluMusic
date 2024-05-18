//
//  MainTabBarController.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import UIKit

protocol MainTabBarControllerDelegate: AnyObject {
    func minimizedPlayer()
    func maximizedPlayer(song: SongItem?)
}

class MainTabBarController: UITabBarController {
    private let songPlayerView = SongPlayerView()
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!

    let searchViewController = SearchViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        viewControllers = [
            UINavigationController(rootViewController: searchViewController)
        ]
        searchViewController.tabBarDelegate = self
        setupSongPlayer()
    }

    private func setupSongPlayer() {
        songPlayerView.translatesAutoresizingMaskIntoConstraints = false
        songPlayerView.mainTabBarDelegate = self
        songPlayerView.delegate = searchViewController
        view.insertSubview(songPlayerView, belowSubview: tabBar)

        maximizedTopAnchorConstraint = songPlayerView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        minimizedTopAnchorConstraint = songPlayerView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -80)
        bottomAnchorConstraint = songPlayerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint.isActive = true
        bottomAnchorConstraint.isActive = true

        NSLayoutConstraint.activate([
            songPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            songPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}


extension MainTabBarController: MainTabBarControllerDelegate {
    func maximizedPlayer(song: SongItem?) {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0

        UIView.animate(
            withDuration: 1,
            delay: 0, 
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseInOut,
            animations: {
                self.view?.layoutIfNeeded()
                self.songPlayerView.minimizedView.alpha = 0
                self.songPlayerView.maximizedView.alpha = 1
            },
            completion: nil
        )

        guard let song = song else { return }
        self.songPlayerView.setup(with: song)
    }

    func minimizedPlayer() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        UIView.animate(
            withDuration: 1,
            delay: 0, usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseInOut,
            animations: {
                self.view?.layoutIfNeeded()
                self.songPlayerView.minimizedView.alpha = 1
                self.songPlayerView.maximizedView.alpha = 0
            },
            completion: nil)
    }
}
