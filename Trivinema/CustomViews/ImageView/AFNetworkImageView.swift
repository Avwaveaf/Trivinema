//
//  AFNetworkImageView.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//

import UIKit

class AFNetworkImageView: UIImageView {
    
    let placeholderImage    = UIImage(named: "ImagePlaceholder")!
    private let cache       = NetworkManager.shared.cache
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentMode     = .scaleToFill
        clipsToBounds   = true
        image           = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func load(from urlString: String) {
        let cacheKey = NSString(string: urlString)
        
        if let cachedImage = cache.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
    
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard
                let self = self,
                error == nil,
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let downloadedImage = UIImage(data: data)
            else { return }
            
            self.cache.setObject(downloadedImage, forKey: cacheKey)
            
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
        }.resume()
    }
}
