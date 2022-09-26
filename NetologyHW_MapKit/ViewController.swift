//
//  ViewController.swift
//  NetologyHW_MapKit
//
//  Created by Dima Gorbachev on 20.09.2022.
//

import UIKit
import MapKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsScale = true
        map.showsUserLocation = true
        map.delegate = self
        map.region.span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        return map
    }()
    
    private lazy var locationManager: CLLocationManager = {
        let location = CLLocationManager()
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyBest
        return location
    }()
    
    private lazy var gestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(
            target: self, action:#selector(handleTap))
        recognizer.delegate = self
        return recognizer
    }()
    
    private lazy var makeRouteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Построить маршрут", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(makeRouteButtonTaped), for: .touchUpInside)
        return button
    }()
    
    private let annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        view.addSubview(makeRouteButton)
        setupConstraints()
        checkLocationAuthStatus()
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            
            makeRouteButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor,constant: -50),
            makeRouteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: +100),
            makeRouteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -100)
        ])
    }
    
    @objc private func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        removeAnnotations()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    @objc private func makeRouteButtonTaped() {
        createDirectionRequest(startCordinate: locationManager.location!.coordinate, destinationCordinate: annotation.coordinate)
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
    
    private func removeAnnotations() {
        mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                mapView.removeAnnotation($0)
            }
        }
    }
    
    private func createDirectionRequest(startCordinate: CLLocationCoordinate2D, destinationCordinate: CLLocationCoordinate2D) {
        let startLocation = MKPlacemark(coordinate: startCordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            guard let response = response else {
                print("error")
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
}

extension ViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways  {
            manager.startUpdatingLocation()
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.setCenter(locations.first!.coordinate, animated: true)
    }
    
    internal func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let lineView = MKPolylineRenderer(overlay: overlay)
        lineView.strokeColor = .red
        return lineView
    }
}

