//
//  HomeHeaderView.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//

import UIKit

class HomeHeaderView: UIView {
    
    private lazy var imageCover: AFNetworkImageView = {
        let imageView           = AFNetworkImageView(frame: .zero)
        imageView.contentMode   = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var gradientOverlay: UIView = {
        let view             = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var appIconView    = TNAppIconView(image: UIImage(named: "TrivinemaDark"))
    lazy var overviewSection        = HomeHeaderTopOverviewSectionView()
    
    private var overview: MoviewOverview?
    private var gradientLayer: CAGradientLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with overview: MoviewOverview) {
        self.overview = overview
        overviewSection.configure(with: overview)
        
        if let backdropPath = overview.backdropPath {
            imageCover.load(from: "https://image.tmdb.org/t/p/original\(backdropPath)")
        } else {
            imageCover.image = UIImage(named: "placeholder-image")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if gradientLayer == nil {
            let layer           = CAGradientLayer()
            layer.colors        = [UIColor.black.cgColor, UIColor.clear.cgColor]
            layer.startPoint    = CGPoint(x: 0.5, y: 1.0)
            layer.endPoint      = CGPoint(x: 0.5, y: 0.0)
            layer.frame         = gradientOverlay.bounds
            gradientOverlay.layer.insertSublayer(layer, at: 0)
            gradientLayer       = layer
        } else {
            gradientLayer?.frame = gradientOverlay.bounds
        }
    }
    
    private func configureView() {
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        appIconView.translatesAutoresizingMaskIntoConstraints = false
        overviewSection.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageCover)
        addSubview(gradientOverlay)
        addSubview(appIconView)
        addSubview(overviewSection)
        
        NSLayoutConstraint.activate([
            imageCover.topAnchor.constraint(equalTo: topAnchor),
            imageCover.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageCover.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageCover.heightAnchor.constraint(equalToConstant: 380),
            
            gradientOverlay.topAnchor.constraint(equalTo: imageCover.topAnchor),
            gradientOverlay.leadingAnchor.constraint(equalTo: imageCover.leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: imageCover.trailingAnchor),
            gradientOverlay.bottomAnchor.constraint(equalTo: imageCover.bottomAnchor),
            
            appIconView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            appIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            appIconView.widthAnchor.constraint(equalToConstant: 40),
            appIconView.heightAnchor.constraint(equalTo: appIconView.widthAnchor),
            
            overviewSection.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            overviewSection.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            overviewSection.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }
}
