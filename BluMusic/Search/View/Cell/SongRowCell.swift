//
//  SongRowCell.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import UIKit
import Kingfisher

final class SongRowCell: UITableViewCell {
    static let reuseIdentifier = "SongRowCell"

    private lazy var mainSV = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        stack.addArrangedSubview(thumbnail)
        stack.addArrangedSubview(texts)
        stack.addArrangedSubview(soundWave)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private lazy var texts = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.addArrangedSubview(songTitle)
        stack.addArrangedSubview(artist)
        stack.addArrangedSubview(album)
        return stack
    }()

    let thumbnail = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    let songTitle = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        return label
    }()
    let artist = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        return label
    }()
    let album = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        return label
    }()

    private let soundWave = {
        let soundWaveOri = SoundWave()
        let view = HostingView(rootView: soundWaveOri)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        soundWave.isHidden = !selected
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        contentView.addSubview(mainSV)
        NSLayoutConstraint.activate([
            mainSV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainSV.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainSV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainSV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            thumbnail.heightAnchor.constraint(equalToConstant: 64),
            thumbnail.widthAnchor.constraint(equalToConstant: 64),

            soundWave.heightAnchor.constraint(equalToConstant: 32),
            soundWave.widthAnchor.constraint(equalToConstant: 32),
        ])

        selectionStyle = .none
    }

    func setupContent(thumbnailURL: String, songTitle: String, artist: String, album: String) {
        let url = URL(string: thumbnailURL)
        self.thumbnail.kf.setImage(with: url)
        self.songTitle.text = songTitle
        self.artist.text = artist
        self.album.text = album
    }
}
