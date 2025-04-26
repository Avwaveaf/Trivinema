//
//  HomeHeaderTopOverviewSectionView.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//

import UIKit

class HomeHeaderTopOverviewSectionView: UIView {
    
    private lazy var sectionTitle               = TNTitleLabel()
    private lazy var sectionDescription         = TNBodyLabel()
    private lazy var genreLabel                 = TNSecondaryLabel()
    
    private lazy var detailButton               = AFVerticalIconButton(icon: .info, title: "Detail")
    private lazy var addToListButton            = AFVerticalIconButton(icon: .add, title: "Add to list")
    private lazy var playButton: AFIconButton   = {
        let button = AFIconButton()
        button.set(title: "Play", icon: .play, style: .outlined)
        return button
    }()
    
    private lazy var actionButtonStack: UIStackView = {
        let stack           = UIStackView(arrangedSubviews: [addToListButton, playButton, detailButton])
        stack.axis          = .horizontal
        stack.alignment     = .center
        stack.distribution  = .fillEqually
        stack.spacing       = 16
        return stack
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack           = UIStackView(arrangedSubviews: [sectionTitle, genreLabel, sectionDescription, actionButtonStack])
        stack.axis          = .vertical
        stack.spacing       = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var overview: MoviewOverview?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with overview: MoviewOverview) {
        self.overview           = overview
        sectionTitle.text       = overview.originalTitle
        sectionDescription.text = overview.overview
        genreLabel.text         = overview.genreIds.map { MovieGenre.from(id: $0) }.joined(separator: " ・ ")
    }
    
    private func configureView() {
        sectionTitle.numberOfLines = 2
        sectionDescription.numberOfLines = 0
        genreLabel.numberOfLines = 1
        
        addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
