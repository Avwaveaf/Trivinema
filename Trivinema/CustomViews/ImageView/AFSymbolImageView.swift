//
//  AFSymbolImageView.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//

import UIKit

class AFSfSymbolImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(systemName sfSymbolName: String? = "exclamationmark.triangle.fill" ,withColor color: UIColor? = .systemGreen){
        super.init(frame: .zero)
        tintColor = color
        let imgConfig = UIImage.SymbolConfiguration(scale: .large)
        
        image = UIImage(systemName: sfSymbolName!, withConfiguration: imgConfig)
        config()
    }
    
    init(of symbol: SFSymbols, withColor color: UIColor? = .systemGreen){
        super.init(frame: .zero)
        
        tintColor       = color
        let imgConfig   = UIImage.SymbolConfiguration(scale: .large)
        image           = UIImage(systemName: symbol.rawValue, withConfiguration: imgConfig)
        config()
    }
    
    func setSymbol(systemName: String){
        image = UIImage(systemName: systemName)
    }
    
    func setSymbol(of: SFSymbols){
        image = UIImage(systemName: of.rawValue)
    }
    
    private func config(){
        translatesAutoresizingMaskIntoConstraints = false
    }
}

extension AFSfSymbolImageView {
    
    static func makeImage(systemName: String = "exclamationmark.triangle.fill", color: UIColor = .label, scale: UIImage.SymbolScale = .large) -> UIImage? {
        let config  = UIImage.SymbolConfiguration(scale: scale)
        let image   = UIImage(systemName: systemName, withConfiguration: config)?.withTintColor(color, renderingMode: .alwaysOriginal)
        return image
    }

    static func makeImage(symbol: SFSymbols, scale: UIImage.SymbolScale = .medium) -> UIImage? {
        let config  = UIImage.SymbolConfiguration(scale: scale)
        let image   = UIImage(systemName: symbol.rawValue, withConfiguration: config)
        return image
    }
}
