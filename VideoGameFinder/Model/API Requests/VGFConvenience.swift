//
//  VGFConvenience.swift
//  VideoGameFinder
//
//  Created by Shawn Moran on 12/28/20.
//

import UIKit
import Foundation

extension VGFClient {
    
    // MARK: GET Convenience Methods
    
    func getGamesForSearchString(_ searchString: String, completionHandlerForGames: @escaping (_ result: [[String:AnyObject]]?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [
            VGFClient.ParameterKeys.ApiKey: VGFClient.Constants.ApiKey,
            VGFClient.ParameterKeys.Search: searchString
        ]
        
        /* 2. Make the request */
        let task = taskForGETMethod(Methods.GameSearch, parameters: parameters as [String:AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForGames(nil, error)
            } else {
                
                if let results = results?[VGFClient.JSONResponseKeys.GameResults] as? [[String:AnyObject]] {
                    let games = results
                    completionHandlerForGames(games, nil)
                } else {
                    completionHandlerForGames(nil, NSError(domain: "getMoviesForSearchString parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMoviesForSearchString"]))
                }
            }
        }
        
        return task
    }
    
    func getSelectedGameDetails(_ game: String, completionHandlerForGameDetails: @escaping (_ result: VGFGamesData.VGFGame?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [
            VGFClient.ParameterKeys.ApiKey: VGFClient.Constants.ApiKey
        ]
        var mutableMethod: String = Methods.GameDetails
        mutableMethod = substituteKeyInMethod(mutableMethod, key: VGFClient.URLKeys.Game, value: game)!
        
        /* 2. Make the request */
        let task = taskForGETMethod(mutableMethod, parameters: parameters as [String:AnyObject]) { (results, error) in
            DispatchQueue.main.async {
                /* 3. Send the desired value(s) to completion handler */
                if let error = error {
                    completionHandlerForGameDetails(nil, error)
                } else {
                    if let results = results as? [String:AnyObject] {
                        let gameDetails = VGFGamesData.VGFGame.gameDetailsFromResults(results)
                        completionHandlerForGameDetails(gameDetails, nil)
                    } else {
                        completionHandlerForGameDetails(nil, NSError(domain: "getSelectedGameDetails parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getSelectedGameDetails"]))
                    }
                }
            }
        }
        
        return task
    }
}
