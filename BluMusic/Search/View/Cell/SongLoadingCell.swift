//
//  SongLoadingCell.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import UIKit

final class SongLoadingCell: UITableViewCell {
    static let reuseIdentifier = "SongLoadingCell"

    private lazy var mainSV = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center

        let st = UIStackView()
        st.axis = .horizontal
        st.axis = .horizontal
        st.alignment = .center
        st.spacing = 16
        st.addArrangedSubview(loader)
        st.addArrangedSubview(loadingLabel)

        stack.addArrangedSubview(st)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "LOADING..."
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        return label
    }()

    private var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        return loader
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        contentView.addSubview(mainSV)
        NSLayoutConstraint.activate([
            mainSV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainSV.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainSV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainSV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])

        selectionStyle = .none
        contentView.backgroundColor = UIColor.black
    }

    func animating() {
        loader.startAnimating()
    }
}

