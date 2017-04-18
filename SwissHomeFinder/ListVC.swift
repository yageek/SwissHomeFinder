//
//  ListVC.swift
//  SwissHomeFinder
//
//  Created by Yannick Heinrich on 18.04.17.
//  Copyright © 2017 yageek. All rights reserved.
//

import UIKit

class ListVC: UITableViewController {

    var offers: [Offer] = []
    var offerToScroll: Offer?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(mapPinSelected(_:)), name: MapSelectedNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return offers.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfferCell", for: indexPath) as! OfferCell

        let offer = offers[indexPath.row]
        cell.titleLabel.text = offer.title
        cell.addressLabel.text = offer.address
        cell.roomsLabel.text = "\(offer.rooms)"
        cell.priceLabel.text = "\(offer.price) CHF"
        cell.startLabel.text = offer.start

        return cell
    }

    private func updateUI(clearCache: Bool = false) {
        Store.sharedInstance.getOffers(clearCache: clearCache, success: { (offers) in
            self.offers = offers
            self.tableView.reloadData()
            self.updateScroll()
        }) { (error) in
            let alert = UIAlertController(title: "Error", message: "Error: \(error.localizedDescription)", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }

    }

    @IBAction func refreshTriggered(_ sender: UIRefreshControl) {
        updateUI(clearCache: true)
    }

    @objc func mapPinSelected(_ notification: Notification) {
        guard let offer = notification.object as? Offer else { return }
        self.offerToScroll = offer
        updateScroll()
    }

    private func updateScroll() {
        guard let offer = offerToScroll else { return }
        if let index = offers.index(of: offer) {
            let indexPath = IndexPath(row: index, section: 0)

            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            offerToScroll = nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Voir sur la carte", style: .default, handler: { (_) in
            NotificationCenter.default.post(name: ListSelectedNotification, object: self.offers[indexPath.row])
            
        }))
        alertController.addAction(UIAlertAction(title: "Voir l'annonce", style: .default, handler: {(_) in
            let offer = self.offers[indexPath.row]
            UIApplication.shared.open(offer.url)
        }))
        
        present(alertController, animated: true)
    }

   
}
