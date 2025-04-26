//
//  AFVerticalIconButton.swift
//  Trivinema
//
//  Created by Afif Fadillah on 26/04/25.
//

import UIKit

class AFVerticalIconButton: UIView {
    
    private let imageView       = UIImageView()
    private let titleLabel      = UILabel()
    private let tapGesture      = UITapGestureRecognizer()
    private var currentStyle: AFIconButtonStyle = .plain
    
    var onTap: (() -> Void)?
    
    init(icon: SFSymbols, title: String) {
        super.init(frame: .zero)
        setupViews()
        configure(icon: UIImage(systemName: icon.rawValue), title: title)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        imageView.contentMode       = .scaleAspectFit
        imageView.tintColor         = .label
        titleLabel.font             = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment    = .center
        titleLabel.numberOfLines    = 1
        titleLabel.textColor        = .label
        
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(handleTap))
        
        layer.cornerRadius = 12
        clipsToBounds   = true
        backgroundColor = UIColor.label.withAlphaComponent(0.05)
    }
    
    private func configure(icon: UIImage?, title: String) {
        imageView.image = icon
        titleLabel.text = title
        applyStyle(currentStyle)
    }
    
    private func applyStyle(_ style: AFIconButtonStyle) {
          switch style {
          case .plain:
              backgroundColor   = .clear
              layer.borderWidth = 0
              layer.borderColor = nil
          case .filled:
              backgroundColor   = UIColor.label.withAlphaComponent(0.05)
              layer.borderWidth = 0
              layer.borderColor = nil
          case .outlined:
              backgroundColor   = .clear
              layer.borderWidth = 1
              layer.borderColor = UIColor.label.cgColor
          }
      }
    
    @objc private func handleTap() {
        onTap?()
    }
}
