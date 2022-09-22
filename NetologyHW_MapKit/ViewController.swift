//
//  ViewController.swift
//  NetologyHW_MapKit
//
//  Created by Dima Gorbachev on 20.09.2022.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsScale = true
        return map
    }()
    
    lazy var locationManager: CLLocationManager = {
        let location = CLLocationManager()
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyBest
        return location
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        setupConstraints()
        checkLocationAuthStatus()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    private func checkLocationAuthStatus() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways  {
            manager.startUpdatingLocation()
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.setCenter(locations.first!.coordinate, animated: true)
    }
}

