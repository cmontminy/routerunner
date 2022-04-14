//
//  ProfileViewController.swift
//  Route Runner
//
//  Created by Paige Gibson on 3/22/22.
//

import UIKit

public let dummyData = ["sample0", "sample1", "sample2", "sample3", "sample4", "sample5"]

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var numRuns: UILabel!
    @IBOutlet weak var numMiles: UILabel!
    @IBOutlet weak var numSPs: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        profilePicture.image = UIImage(named: "profilepictureRR")
        startObserving(&UserInterfaceStyleManager.shared)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! ProfileCollectionViewCell
        let row = indexPath.row
        cell.runImage?.image = UIImage(named: dummyData[row])
        cell.runImage?.layer.cornerRadius = 8.0
        cell.runImage?.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dummyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // add the code here to perform action on the cell
        //when run is clicked on, run detials will be shown, similar to past run in history
//        let cell = collectionView.cellForItem(at: indexPath) as? ProfileCollectionViewCell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        let containerWidth = collectionView.bounds.width
        let cellSize = (containerWidth - 45) / 3
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
        
    }
}
