//
//  VideoResponse.swift
//  Trivinema
//
//  Created by Afif Fadillah on 30/04/25.
//

import Foundation

struct VideoResponse: Codable {
    let id: Int
    let results: [Video]
}
