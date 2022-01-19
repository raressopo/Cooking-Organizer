//
//  HomeCollectionViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 11/01/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import Foundation

enum HomeItems: Int, CaseIterable {
    case Recipes
    case Pantry
    case ShoppingLists
    case Account
    
    var asString: String {
        switch self {
        case .Recipes:
            return "Rețete"
        case .Pantry:
            return "Cămară"
        case .ShoppingLists:
            return "Liste"
        case .Account:
            return "Cont"
        }
    }
}

class HomeCollectionViewController: UICollectionViewController {
    
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    let cellsPerRow = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInsetAdjustmentBehavior = .always
        collectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "homeCell")
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as? HomeCollectionViewCell else {
            fatalError("Wrong cell!")
        }
        
        cell.configure(withHomeItem: HomeItems.allCases[indexPath.row])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case HomeItems.Recipes.rawValue:
            performSegue(withIdentifier: "recipesSegue", sender: self)
        case HomeItems.Pantry.rawValue:
            performSegue(withIdentifier: "pantrySegue", sender: self)
        case HomeItems.ShoppingLists.rawValue:
            performSegue(withIdentifier: "listsSegue", sender: self)
        case HomeItems.Account.rawValue:
            performSegue(withIdentifier: "settingsSegue", sender: self)
        default:
            fatalError("All Home Items need to have a destination screen")
        }
    }
    
}

extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout {
    // for arranging nicer see https://stackoverflow.com/questions/14674986/uicollectionview-set-number-of-columns
    
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
        let itemWidthAndHeight = (view.frame.width - widthMarginsAndInsets) / CGFloat(cellsPerRow)
        return CGSize(width: itemWidthAndHeight, height: itemWidthAndHeight)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
}
