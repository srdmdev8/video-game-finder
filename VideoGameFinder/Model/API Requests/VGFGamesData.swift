//
//  VGFGamesData.swift
//  VideoGameFinder
//
//  Created by Shawn Moran on 12/28/20.
//

import Foundation

class VGFGamesData {
    
    var game = [VGFGame]()
    
    // MARK: Shared Instance
    class func sharedInstance() -> VGFGamesData {
        struct Singleton {
            static var sharedInstance = VGFGamesData()
        }
        return Singleton.sharedInstance
    }
}
