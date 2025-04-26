//
//  TNBodyLabel.swift
//  Trivinema
//
//  Created by Afif Fadillah on 26/04/25.
//

import UIKit

class TNBodyLabel: UILabel {

   override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }

    required init?(coder: NSCoder) {
        fatalError("Unimplemented!")
    }
    
    init(withTextAlignment tAlign: NSTextAlignment = .left){
        super.init(frame:.zero)
        self.textAlignment = tAlign
        config()
    }
    
    private func config(){
        textColor                   = .secondaryLabel
        font                        = UIFont.preferredFont(forTextStyle: .caption1)
        // autoshrink font size match width
        adjustsFontSizeToFitWidth   = true
        minimumScaleFactor          = 0.70
        lineBreakMode               = .byWordWrapping
        translatesAutoresizingMaskIntoConstraints = false
    }

}
