//
//  AFNetworkImageView.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//

import UIKit

class AFNetworkImageView: UIImageView {
    private var currentURLString: String?
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
    
    func decodeImage(from data: Data) -> UIImage? {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func load(from urlString: String) {
        currentURLString = urlString
        image = placeholderImage
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
                response.statusCode == 200
            else { return }
            
            if let cgDecodedImage = self.decodeImage(from: data) {
                self.cache.setObject(cgDecodedImage, forKey: cacheKey)
                
                DispatchQueue.main.async {
                    if self.currentURLString == urlString {
                        self.image = cgDecodedImage
                    }
                }
            }
        }.resume()
    }
}
