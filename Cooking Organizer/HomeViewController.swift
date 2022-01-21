//
//  HomeViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 20/01/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import UIKit

enum HomeItems: Int, CaseIterable {
    case Recipes
    case Pantry
    case ShoppingLists
    case CookingCalendar
    
    var asString: String {
        switch self {
        case .Recipes:
            return "Rețete"
        case .Pantry:
            return "Cămară"
        case .ShoppingLists:
            return "Liste"
        case .CookingCalendar:
            return "Calendar Rețete"
        }
    }
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    let cellsPerRow = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "homeCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func accountPressed(_ sender: Any) {
        performSegue(withIdentifier: "settingsSegue", sender: self)
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HomeItems.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as? HomeCollectionViewCell else {
            fatalError("Wrong cell!")
        }
        
        cell.configure(withHomeItem: HomeItems.allCases[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case HomeItems.Recipes.rawValue:
            performSegue(withIdentifier: "recipesSegue", sender: self)
        case HomeItems.Pantry.rawValue:
            performSegue(withIdentifier: "pantrySegue", sender: self)
        case HomeItems.ShoppingLists.rawValue:
            performSegue(withIdentifier: "listsSegue", sender: self)
        case HomeItems.CookingCalendar.rawValue:
            performSegue(withIdentifier: "cookingCalendarSegue", sender: self)
        default:
            fatalError("All Home Items need to have a destination screen")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let widthMarginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing
        let itemWidthAndHeight = (view.frame.width - widthMarginsAndInsets) / CGFloat(cellsPerRow)
        let rows = HomeItems.allCases.count / cellsPerRow
        let rowsHeight = (itemWidthAndHeight + minimumLineSpacing + 2 * inset) * CGFloat(rows)
        let topInset = max((view.frame.height - rowsHeight) / 2, inset)
        return UIEdgeInsets(top: topInset, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthMarginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing
        let itemWidthAndHeight = (collectionView.frame.width - widthMarginsAndInsets) / CGFloat(cellsPerRow)
        
        return CGSize(width: itemWidthAndHeight, height: itemWidthAndHeight)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
}
