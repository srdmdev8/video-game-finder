//
//  WishlistViewController.swift
//  VideoGameFinder
//
//  Created by Shawn Moran on 12/28/20.
//

import UIKit
import CoreData

class WishlistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Game>!
    
    @IBOutlet weak var wishlistTableView: UITableView!
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Game> = Game.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "wished games")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        wishlistTableView.delegate = self
        
        // Fetch data via fetchedResultsController
        setUpFetchedResultsController()
        
        if let indexPath = wishlistTableView.indexPathForSelectedRow {
            wishlistTableView.deselectRow(at: indexPath, animated: false)
            wishlistTableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    @IBAction func onSearchGames(_ sender: Any) {
        performSegue(withIdentifier: "SearchGames", sender: nil)
    }
    
    // Deletes the `Note` at the specified index path
    func deleteGame(at indexPath: IndexPath) {
        let gameToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(gameToDelete)
        try? dataController.viewContext.save()
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> WishlistViewController {
        struct Singleton {
            static var sharedInstance = WishlistViewController()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aGame = fetchedResultsController.object(at: indexPath)
        let cell = wishlistTableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as UITableViewCell?

        // Configure cell
        cell?.textLabel!.text = aGame.name
        let imageURL = URL(string: aGame.backgroundImage!)
        if let data = try? Data(contentsOf: imageURL!) {
            cell?.imageView!.image = UIImage(data: data)
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let aGame = fetchedResultsController.object(at: indexPath)
        
        performSegue(withIdentifier: "WishlistGameDetails", sender: aGame)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchGames" {
            if let gameSearchVC = segue.destination as? GameSearchViewController {
                gameSearchVC.dataController = dataController
            }
        } else {
            if let gameDetailsVC = segue.destination as? GameDetailsViewController {
                gameDetailsVC.game = sender as? Game
                gameDetailsVC.dataController = dataController
                gameDetailsVC.isOnWishlist = true
                
                gameDetailsVC.onDelete = { [weak self] in
                    if let indexPath = self?.wishlistTableView.indexPathForSelectedRow {
                        self?.deleteGame(at: indexPath)
                    }
                }
            }
        }
    }
}

extension WishlistViewController {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        wishlistTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        wishlistTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            wishlistTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            wishlistTableView.deleteRows(at: [indexPath!], with: .fade)
        default:
            break
        }
    }
}
