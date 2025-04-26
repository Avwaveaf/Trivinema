//
//  TNTitleLabel.swift
//  Trivinema
//
//  Created by Afif Fadillah on 26/04/25.
//

import UIKit

class TNTitleLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(ofSize: CGFloat){
        super.init(frame: .zero)
        self.font = UIFont.systemFont(ofSize: ofSize, weight: .bold)
        configure()
    }
    
    private func configure(){
        numberOfLines       = 0
        lineBreakMode       = .byWordWrapping
        translatesAutoresizingMaskIntoConstraints = false
    }
}
