//
//  MapViewController.swift
//  SwissHomeFinder
//
//  Created by Yannick Heinrich on 17.04.17.
//  Copyright © 2017 yageek. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    var offerToZoom: Offer?
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    private static let LausanneCenter: CLLocationCoordinate2D = {
        let lat = CLLocationDegrees(46.521)
        let lng = CLLocationDegrees(6.631)
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }()

    @IBOutlet var mapView: MKMapView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector: #selector(listSelected(_:)), name: ListSelectedNotification, object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMap()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupMap() {
        // Center on Lausanne
        let span = CLLocationDistance(10000)
        let zone = MKCoordinateRegionMakeWithDistance(MapViewController.LausanneCenter, span, span)
        mapView.setRegion(zone, animated: false)
        updateUI()
        updateZoom()
    }
    
    @IBAction func refreshTriggered(_ sender: UIBarButtonItem) {
        refreshButton.isEnabled = false
        updateUI(clearCache: true)
    }

    private func updateUI(clearCache: Bool = false) {
        Store.sharedInstance.getOffers(clearCache: clearCache, success: { (offers) in
            self.mapView.addAnnotations(offers)
            self.refreshButton.isEnabled = true

        }) { (error) in
            let alert = UIAlertController(title: "Error", message: "Error: \(error.localizedDescription)", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            self.refreshButton.isEnabled = true
        }

    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "OfferAnnotation"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if view == nil {

            let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pin.canShowCallout = true

            let button = UIButton(type: .detailDisclosure)
            pin.rightCalloutAccessoryView = button
            view = pin
        }

        view?.annotation = annotation
        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        if let offer = view.annotation as? Offer {
            NotificationCenter.default.post(name: MapSelectedNotification, object: offer)
        }
    }

    @objc func listSelected(_ notification: Notification) {
        guard let offer = notification.object as? Offer else { return }
        self.offerToZoom = offer
        updateZoom()
    }

    private func updateZoom() {
        guard let offer = offerToZoom else { return }

        let span = CLLocationDistance(500)
        let zone = MKCoordinateRegionMakeWithDistance(offer.coordinate, span, span)
        mapView.setRegion(zone, animated: false)
        mapView.selectAnnotation(offer, animated: true)

    }
}
