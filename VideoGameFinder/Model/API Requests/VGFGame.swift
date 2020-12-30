//
//  VGFGame.swift
//  VideoGameFinder
//
//  Created by Shawn Moran on 12/28/20.
//

extension VGFGamesData {

    // MARK: VGFGame
    struct VGFGame {
        
        // MARK: Properties
        let name: String
        let detail: String
        let released: String
        let backgroundImage: String
        let website: String
        let platforms: String
        let publishers: String

        // MARK: Initializers

        // construct a OTMStudentLocation from a dictionary
        init(name: String, detail: String, released: String, backgroundImage: String, website: String, platforms: String, publishers: String) {
            self.name = name
            self.detail = detail
            self.released = released
            self.backgroundImage = backgroundImage
            self.website = website
            self.platforms = platforms
            self.publishers = publishers
        }

        static func gameDetailsFromResults(_ results: [String:AnyObject]) -> VGFGame {
            // Gather platform info
            var platformString = ""
            if let platforms = results[VGFClient.JSONResponseKeys.Platforms] as? [[String:AnyObject]] {
                for item in platforms {
                    if let platform = item[VGFClient.JSONResponseKeys.Platform] as? [String:AnyObject] {
                        var currentPlatform = platform[VGFClient.JSONResponseKeys.PlatformName] as! String
                        // Change Playstation to PS where necessary
                        if currentPlatform.contains("Playstation") || currentPlatform.contains("PlayStation"), (currentPlatform != "Playstation" || currentPlatform != "PlayStation") {
                            currentPlatform = "PS" + currentPlatform.suffix(1)
                        }
                        // Concat platforms into one string
                        if platformString == "" {
                            platformString = currentPlatform
                        } else {
                            platformString = platformString + ", " + currentPlatform
                        }
                    }
                }
            }
            
            // Gather publishers info
            var publisherString = ""
            if let publishers = results[VGFClient.JSONResponseKeys.Publishers] as? [[String:AnyObject]] {
                for publisher in publishers {
                    // Concat platforms into one string
                    if publisherString == "" {
                        publisherString = publisher[VGFClient.JSONResponseKeys.PublisherName] as! String
                    } else {
                        publisherString = publisherString + ", " + (publisher[VGFClient.JSONResponseKeys.PublisherName] as! String)
                    }
                }
            }

            let game = VGFGame(name: results[VGFClient.JSONResponseKeys.Name] as! String, detail: results[VGFClient.JSONResponseKeys.Description] as! String, released: results[VGFClient.JSONResponseKeys.Released] as! String, backgroundImage: results[VGFClient.JSONResponseKeys.BackgroundImage] as! String, website: results[VGFClient.JSONResponseKeys.Website] as! String, platforms: platformString, publishers: publisherString)

            return game
        }
    }
}
