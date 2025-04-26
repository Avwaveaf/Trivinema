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
    
    private func configure(){
        font                = UIFont.preferredFont(forTextStyle: .largeTitle)
        numberOfLines       = 0
        lineBreakMode       = .byWordWrapping
        translatesAutoresizingMaskIntoConstraints = false
    }
}
