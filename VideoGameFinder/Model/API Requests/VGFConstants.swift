//
//  VGFConstants.swift
//  VideoGameFinder
//
//  Created by Shawn Moran on 12/28/20.
//

extension VGFClient {
    
    // MARK: - Constants

    struct Constants {
        
        // MARK: API Key
        static let ApiKey = "7a473f253af246c7ab7fad4b7469fe49"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.rawg.io"
        static let ApiPath = "/api"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Games
        static let GameSearch = "/games"
        
        // MARK: Game Details
        static let GameDetails = "/games/{game}"
        
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let Game = "game"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "key"
        static let Search = "search"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        // MARK: Games
        static let GameResults = "results"
        static let Name = "name"
        static let Description = "description_raw"
        static let Metacritic = "metacritic"
        static let Released = "released"
        static let BackgroundImage = "background_image"
        static let BackgroundImageAdd = "background_image_additional"
        static let Website = "website"
        static let Rating = "rating"
        static let RatingTop = "rating_top"
        
        // MARK: Game Platforms
        static let Platforms = "platforms"
        static let Platform = "platform"
        static let PlatformName = "name"
        static let ImageBackground = "image_background"
        
        // MARK: Game Publishers
        static let Publishers = "publishers"
        static let PublisherName = "name"
        static let PubImageBackground = "image_background"
        
        // MARK: Game Clip
        static let Clip = "clip"
    }
}
