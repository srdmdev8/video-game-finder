//
//  GameDetailsViewController.swift
//  VideoGameFinder
//
//  Created by Shawn Moran on 12/28/20.
//

import UIKit
import CoreData

class GameDetailsViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var gameDetails: VGFGamesData.VGFGame!
    
    var game: Game!
    
    var isGameSearch: Bool = false
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Game>!
    
    var isOnWishlist = false
    
    var onDelete: (() -> Void)?
    
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var navbarTitle: UINavigationItem!
    @IBOutlet weak var releasedLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var platformsLabel: UILabel!
    @IBOutlet weak var publishersLabel: UILabel!
    @IBOutlet weak var descriptionScrollView: UIScrollView!
    @IBOutlet weak var toggleWishlistButton: UIBarButtonItem!
    @IBOutlet weak var toggleOwnlistButton: UIBarButtonItem!
    
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
        
        // Get game name and display in navbar
        navbarTitle.title = isGameSearch ? gameDetails.name : game.name
        
        // Get game image and display it in gameImageView
        getGameImage()
        
        // Get game description in scroll view
        getGameDescription()
        
        // Get released date
        releasedLabel.text = isGameSearch ? gameDetails.released : game.released
        
        // Get game website
        getGameWebsite()
        
        // Get available platforms info
        platformsLabel.text = isGameSearch ? gameDetails.platforms : game.platforms
        
        // Get publisher(s) info
        publishersLabel.text = isGameSearch ? gameDetails.publishers : game.publishers
        
        // Fetch data via fetchedResultsController
        setUpFetchedResultsController()
        
        // Check if game is on wishlist
        checkSavedGames()
    }
    
    // Navigate to provided game URL
    @IBAction func websiteURLClicked(_ sender: Any) {
        if websiteButton.titleLabel?.text != "N/A" {
            if let url = URL(string: (websiteButton.titleLabel?.text)!) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    // Add or remove game from Wishlist when the specified button is clicked
    @IBAction func toggleWishList(_ sender: Any) {
        let shouldAddToWishlist = !isOnWishlist
        if shouldAddToWishlist {
            addGame()
            self.toggleWishlistButton.image = UIImage(systemName: "text.badge.checkmark")
        } else {
            if isGameSearch {
                var aGame: Game!
                var gameIndex: IndexPath!
                let games = fetchedResultsController.fetchedObjects!
                for game in games {
                    if game.name == gameDetails.name {
                        aGame = game
                    }
                }
                gameIndex = fetchedResultsController.indexPath(forObject: aGame)
                deleteGame(at: gameIndex!)
            } else {
                self.onDelete?()
            }
            self.toggleWishlistButton.image = UIImage(systemName: "list.bullet")
        }
        self.isOnWishlist = shouldAddToWishlist
    }
    
    @IBAction func onDone(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getGameImage() {
        let backgroundImage = isGameSearch ? gameDetails.backgroundImage : game.backgroundImage
        let imageURL = URL(string: backgroundImage!)
        if let data = try? Data(contentsOf: imageURL!) {
            gameImageView.image = UIImage(data: data)
        }
    }
    
    func getGameDescription() {
        let descriptionLabel = UILabel()
        descriptionLabel.text = isGameSearch ? gameDetails.detail : game.detail
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        descriptionLabel.preferredMaxLayoutWidth = screenWidth
        descriptionScrollView.addSubview(descriptionLabel)
        descriptionScrollView.contentSize = CGSize(width: screenWidth, height: 2000)
        self.view.addSubview(descriptionScrollView)
    }
    
    func getGameWebsite() {
        if isGameSearch {
            if gameDetails.website != "" {
                websiteButton.setTitle(gameDetails.website, for: .normal)
            } else {
                websiteButton.setTitle("N/A", for: .disabled)
            }
        } else {
            if game.website != "" {
                websiteButton.setTitle(game.website, for: .normal)
            } else {
                websiteButton.setTitle("N/A", for: .disabled)
            }
        }
    }
    
    func checkSavedGames() {
        // Check we have saved games
        guard let games = fetchedResultsController?.fetchedObjects else {
            return
        }
        
        // Loop through games to determine if selected game is on wishlist
        for item in games {
            if isGameSearch {
                if item.name == gameDetails.name {
                    isOnWishlist = true
                }
            } else {
                if item == game {
                    isOnWishlist = true
                }
            }
        }
        
        // If game is on wishlist update wishlist button
        if isOnWishlist {
            self.toggleWishlistButton.image = UIImage(systemName: "text.badge.checkmark")
        }
    }
    
    // Adds a new `Note` to the end of the `notebook`'s `notes` array
    func addGame() {
        let aGame = Game(context: dataController.viewContext)
        aGame.name = isGameSearch ? gameDetails.name : game.name
        aGame.detail = isGameSearch ? gameDetails.detail : game.detail
        aGame.backgroundImage = isGameSearch ? gameDetails.backgroundImage : game.backgroundImage
        aGame.released = isGameSearch ? gameDetails.released : game.released
        aGame.website = isGameSearch ? gameDetails.website : game.website
        aGame.platforms = isGameSearch ? gameDetails.platforms : game.platforms
        aGame.publishers = isGameSearch ? gameDetails.publishers : game.publishers
        try? dataController.viewContext.save()
    }

    // Deletes the `Note` at the specified index path
    func deleteGame(at indexPath: IndexPath) {
        let gameToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(gameToDelete)
        try? dataController.viewContext.save()
    }
}
