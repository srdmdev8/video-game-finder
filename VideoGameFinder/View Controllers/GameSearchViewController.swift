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
    
    var fetchedResultsController:NSFetchedResultsController<Category>!
    
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var gameSearchBar: UISearchBar!
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "categories")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    override func viewDidLoad() {
        
        // configure tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch data via fetchedResultsController
        setUpFetchedResultsController()
        
        // Check if own and wish categories have been created. If not, create them
        createRequiredCategories()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func displayAlert() {
        let alert = UIAlertController(title: "Game Search Error", message: "We were unable to gather the game details for the selected game. Please try again in a few moments.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectedGameDetails" {
            if let gameDetailsVC = segue.destination as? GameDetailsViewController {
                gameDetailsVC.gameDetails = gameDetails
                gameDetailsVC.isGameSearch = true
                let categories = fetchedResultsController.fetchedObjects!
                guard let categoryIndex = categories.firstIndex(where: { (category) -> Bool in
                    category.name == "wish"
                }) else {
                    return
                }
                gameDetailsVC.dataController = dataController
                gameDetailsVC.category = categories[categoryIndex]
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

    func createRequiredCategories() {
        print(fetchedResultsController?.fetchedObjects)
        guard let categories = fetchedResultsController?.fetchedObjects, !categories.isEmpty else {
            print("calling addCategory")
            addCategory("wish")
            return
        }
        for category in categories {
            print(category.name)
        }
    }
    
    func addCategory(_ name: String) {
        print("inside addCategory")
        let category = Category(context: dataController.viewContext)
        category.name = name
        try? dataController.viewContext.save()
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> GameSearchViewController {
        struct Singleton {
            static var sharedInstance = GameSearchViewController()
        }
        return Singleton.sharedInstance
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
        
        // cancel the last task
        if let task = searchTask {
            task.cancel()
        }
        
        // if the text is empty we are done
        if searchText == "" {
            games = [[String:AnyObject]]()
            gameTableView?.reloadData()
            return
        }
        
        // new search
        searchTask = VGFClient.sharedInstance().getGamesForSearchString(searchText) { (games, error) in
            self.searchTask = nil
            if let games = games {
                self.games = games
                DispatchQueue.main.async {
                    self.gameTableView!.reloadData()
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
