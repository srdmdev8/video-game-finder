//
//  WishlistViewController.swift
//  VideoGameFinder
//
//  Created by Shawn Moran on 12/28/20.
//

import UIKit
import CoreData

class WishlistViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Game>!
    
    @IBOutlet weak var wishlistTableView: UITableView!
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Game> = Game.fetchRequest()
        let predicate = NSPredicate(format: "category == %@", "wish")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "wished game")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataController = GameSearchViewController.sharedInstance().dataController
        // Fetch data via fetchedResultsController
        setUpFetchedResultsController()
        
        if let indexPath = wishlistTableView.indexPathForSelectedRow {
            wishlistTableView.deselectRow(at: indexPath, animated: false)
            wishlistTableView.reloadRows(at: [indexPath], with: .fade)
        }
        
        // Get games in wishlist
        getSavedGames()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // Gather saved wishlist games and display them in the view
    func getSavedGames() {
        
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
        let cell = wishlistTableView.dequeueReusableCell(withIdentifier: GameCell.defaultReuseIdentifier, for: indexPath) as! GameCell

        // Configure cell
        cell.textLabel?.text = aGame.name
        
        let imageURL = URL(string: aGame.backgroundImage!)
        if let data = try? Data(contentsOf: imageURL!) {
            cell.gameImageView?.image = UIImage(data: data)
        }

        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a NoteDetailsViewController, we'll configure its `Note`
        // and its delete action
        if let vc = segue.destination as? GameDetailsViewController {
            if let indexPath = wishlistTableView.indexPathForSelectedRow {
                vc.game = fetchedResultsController.object(at: indexPath)
                vc.dataController = dataController
                vc.isOnWishlist = true
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
