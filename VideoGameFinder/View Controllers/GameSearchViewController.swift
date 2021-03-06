//
//  ViewController.swift
//  VideoGameFinder
//
//  Created by Shawn Moran on 12/27/20.
//

import UIKit
import CoreData

// MARK: - GameSearchViewControllerDelegate

protocol GameSearchViewControllerDelegate {
    func gameSearch(_ gameSearch: GameSearchViewController, didPickGame game: VGFGamesData.VGFGame?)
}

class GameSearchViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var games = [[String:AnyObject]]()
    
    var gameDetails: VGFGamesData.VGFGame!
    
    var delegate: GameSearchViewControllerDelegate?
    
    var searchTask: URLSessionDataTask?
    
    var dataController: DataController!
    
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var gameSearchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        // configure tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func displayAlert(_ isInputSearch: Bool = false) {
        var message = ""
        if isInputSearch {
            message = "We were unable to gather a list of games for your most recent search."
        } else {
            message = "We were unable to gather the game details for the selected game."
        }
        let alert = UIAlertController(title: "Game Search Error", message: message + " Please try again in a few moments.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectedGameDetails" {
            if let gameDetailsVC = segue.destination as? GameDetailsViewController {
                gameDetailsVC.gameDetails = gameDetails
                gameDetailsVC.isGameSearch = true
                gameDetailsVC.dataController = dataController
            }
        }
    }
    
    private func getSelectedGameDetails(_ gameSlug: String) {
        searchTask = VGFClient.sharedInstance().getSelectedGameDetails(gameSlug) { (gameDetails, error) in
            // Check for error
            if error != nil {
                print(error!)
                self.displayAlert()
                return
            }
            if let gameDetails = gameDetails {
                self.gameDetails = gameDetails
                self.performSegue(withIdentifier: "SelectedGameDetails", sender: nil)
            }
        }
    }
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - GameSearchViewController: UIGestureRecognizerDelegate

extension GameSearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gameSearchBar.isFirstResponder
    }
}

// MARK: - GameSearchViewController: UISearchBarDelegate

extension GameSearchViewController: UISearchBarDelegate {
    
    // each time the search text changes we want to cancel any current download and start a new one
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Start animation when text changes
        activityIndicator.startAnimating()
        
        // cancel the last task
        if let task = searchTask {
            task.cancel()
        }
        
        // if the text is empty we are done
        if searchText == "" {
            games = [[String:AnyObject]]()
            gameTableView?.reloadData()
            // Stop animation if text was cleared
            activityIndicator.stopAnimating()
            return
        }
        
        // new search
        searchTask = VGFClient.sharedInstance().getGamesForSearchString(searchText) { (games, error) in
            self.searchTask = nil
            
            // Check for error
            if error != nil {
                print(error!)
                self.displayAlert(true)
                // Stop animation if error occurs
                self.activityIndicator.stopAnimating()
                return
            }
            
            if let games = games {
                self.games = games
                DispatchQueue.main.async {
                    self.gameTableView!.reloadData()
                    // Stop animation after we reload data
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - GameSearchViewController: UITableViewDelegate, UITableViewDataSource

extension GameSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "GameSearchCell"
        let game = games[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell?
        cell?.textLabel!.text = "\(game["name"]!)"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = games[(indexPath as NSIndexPath).row]
        let gameSlug = game["slug"] as! String
        getSelectedGameDetails(gameSlug)
    }
}
