//
//  SongPlayerView.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import UIKit
import Kingfisher
import AVKit

protocol SongPlayerDelegate {
    func moveToPrevious() -> SongItem?
    func moveToNext() -> SongItem?
}

class SongPlayerView: UIView {
    static let identifier = "SongPlayerView"
    @IBOutlet weak var minimizedView: UIView!
    @IBOutlet weak var miniThumbnail: UIImageView!
    @IBOutlet weak var miniSongTitle: UILabel!
    @IBOutlet weak var miniPrevButton: UIButton!
    @IBOutlet weak var miniPlayPauseButton: UIButton!
    @IBOutlet weak var miniNextButton: UIButton!

    @IBOutlet weak var maximizedView: UIStackView!
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var currentTimeSong: UILabel!
    @IBOutlet var durationSong: UILabel!
    @IBOutlet var songTitle: UILabel!
    @IBOutlet var artist: UILabel!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    var delegate: SongPlayerDelegate?
    weak var mainTabBarDelegate: MainTabBarControllerDelegate?

    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let nib = UINib(nibName: Self.identifier, bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        else { fatalError("Unable to convert nib") }

        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        setupGestures()
        setupSongTime()
        view.backgroundColor = UIColor.black
        minimizedView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    }

    private func playSong(url: String?) {
        guard let url = URL(string: url ?? "") else { return }
        let newItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: newItem)
        player.play()
    }

    func setup(with song: SongItem) {
        miniSongTitle.text = song.trackName
        songTitle.text = song.trackName
        artist.text = song.artistName
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)

        playSong(url: song.previewUrl)

        guard let url = URL(string: song.artworkUrl500) else { return }
        miniThumbnail.kf.setImage(with: url)
        thumbnail.kf.setImage(with: url)
    }
}

// MARK: - Gestures

extension SongPlayerView {
    private func setupGestures() {
        minimizedView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
        minimizedView.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        )
        addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(handleDismissalSwipe))
        )
    }

    @objc 
    private func handleTap() {
        mainTabBarDelegate?.maximizedPlayer(song: nil)
    }

    @objc 
    private func handleSwipeGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            handlePanChanged(gesture: gesture)
        case .ended:
            handlePanEnded(gesture: gesture)
        default:()
        }
    }

    private func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        transform = CGAffineTransform(translationX: 0, y: translation.y)

        let newAlpha = 1 + translation.y / 200
        minimizedView.alpha = newAlpha < 0 ? 0 : newAlpha
        maximizedView.alpha = -translation.y / 200
    }

    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                self.transform = .identity
                if translation.y < -200 || velocity.y < -500 {
                    self.mainTabBarDelegate?.maximizedPlayer(song: nil)
                } else {
                    self.minimizedView.alpha = 1
                    self.maximizedView.alpha = 0
                }
            },
            completion: nil
        )
    }

    @objc 
    private func handleDismissalSwipe(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: superview)
            maximizedView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        case .ended:
            let translation = gesture.translation(in: superview)
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 1,
                options: .curveEaseOut,
                animations: {
                    self.maximizedView.transform = .identity
                    if translation.y > 50 {
                        self.mainTabBarDelegate?.minimizedPlayer()
                    }
                },
                completion: nil
            )
         default:()
        }
    }
}

// MARK: - Song Time setup

extension SongPlayerView {

    private func setupSongTime() {
        observePlayerCurrentTime()
    }

    private func observePlayerCurrentTime() {
        let interval = CMTime(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            self?.currentTimeSong.text = time.convertToString()

            let durationTime = self?.player.currentItem?.duration
            let currentDurationText = ((durationTime ?? CMTime(value: 1, timescale: 1)) - time).convertToString()
            self?.durationSong.text = "-\(currentDurationText)"
            self?.updateCurrentTimeSlider()
        }

        player.addPeriodicTimeObserver(
            forInterval: interval, 
            queue: .main
        ) { [weak self] time in
            if self?.player.currentItem?.duration.seconds == time.seconds {
                self?.miniNextButton.sendActions(for: .touchUpInside)
            }
        }
    }

    private func updateCurrentTimeSlider() {
        let currentTimeInSeconds = CMTimeGetSeconds(player.currentTime())
        let durationInSeconds = CMTimeGetSeconds(
            player.currentItem?.duration ?? CMTime(value: 1, timescale: 1)
        )
        let percentage = currentTimeInSeconds / durationInSeconds
        self.timeSlider.value = Float(percentage)
    }
}

// MARK: - Actions

extension SongPlayerView {
    @IBAction func currentTimeChanged(_ sender: Any) {
        guard let duration = player.currentItem?.duration else { return }
        let percentage = timeSlider.value
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }

    @IBAction func previousSongTapped(_ sender: Any) {
        guard let song = delegate?.moveToPrevious() else { return }
        setup(with: song)
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }

    @IBAction func playPauseTapped(_ sender: Any) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else {
            player.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            miniPlayPauseButton.setImage(UIImage(named: "play"), for: .normal)
        }
    }

    @IBAction func nextSongTapped(_ sender: Any) {
        guard let song = delegate?.moveToNext() else {return}
        setup(with: song)
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
}
