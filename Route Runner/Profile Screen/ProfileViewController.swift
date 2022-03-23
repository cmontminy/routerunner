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
        let cell = collectionView.cellForItem(at: indexPath) as? ProfileCollectionViewCell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
