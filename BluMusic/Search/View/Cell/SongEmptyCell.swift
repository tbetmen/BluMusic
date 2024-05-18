//
//  SongEmptyCell.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import UIKit

final class SongEmptyCell: UITableViewCell {
    static let reuseIdentifier = "SongEmptyCell"

    let emptyTitle = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        contentView.addSubview(emptyTitle)
        NSLayoutConstraint.activate([
            emptyTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emptyTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            emptyTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emptyTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])

        selectionStyle = .none
        contentView.backgroundColor = UIColor.black
    }

    func setup(isError: Bool = false) {
        if isError {
            emptyTitle.text = "There is error while fetching song, please try again later."
        } else {
            emptyTitle.text = "Please enter song name or artist ..."
        }

    }
}
