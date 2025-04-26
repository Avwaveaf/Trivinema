import UIKit

enum AFIconButtonStyle {
    case filled
    case outlined
    case plain
}

class AFIconButton: UIButton {

    private var currentStyle: AFIconButtonStyle = .plain
    private let spacing: CGFloat = 8  // 👈 control spacing between icon and title
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureBase()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureBase()
    }
    
    func set(
        title: String,
        icon: SFSymbols,
        style: AFIconButtonStyle = .plain
    ) {
        setTitle(title, for: .normal)
        setImage(UIImage(systemName: icon.rawValue), for: .normal)
        currentStyle = style
        applyStyle(style)
        alignTextAndImage()
    }
    
    private func configureBase() {
        tintColor = .label
        setTitleColor(.label, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        layer.cornerRadius = 12
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        semanticContentAttribute = .forceLeftToRight
    }
    
    private func applyStyle(_ style: AFIconButtonStyle) {
        switch style {
        case .filled:
            backgroundColor = UIColor.label.withAlphaComponent(0.1)
            layer.borderWidth = 0
            layer.borderColor = nil
        case .outlined:
            backgroundColor = .clear
            layer.borderWidth = 1
            layer.borderColor = UIColor.label.cgColor
        case .plain:
            backgroundColor = .clear
            layer.borderWidth = 0
            layer.borderColor = nil
        }
    }
    
    private func alignTextAndImage() {
        guard let imageView = imageView, let titleLabel = titleLabel else { return }
        
        // Reset any previous insets
        imageEdgeInsets = .zero
        titleEdgeInsets = .zero
        
        // Apply spacing manually
        let imageWidth = imageView.frame.width
        titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: spacing,  // 👈 push title away from image
            bottom: 0,
            right: -spacing
        )
        contentEdgeInsets = UIEdgeInsets(
            top: 8,
            left: 12,
            bottom: 8,
            right: 12 + spacing  // 👈 add extra padding to the right
        )
    }
}
