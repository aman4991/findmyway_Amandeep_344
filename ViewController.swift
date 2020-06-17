//
//  ViewController.swift
//  FindMyWay
//
//  Created by user174568 on 6/14/20.
//  Copyright © 2020 user174568. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var destination: CLLocationCoordinate2D!
    @IBOutlet weak var map: MKMapView!
    let Places = Place.getPlaces()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        map.delegate = self
        map.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let latitude: CLLocationDegrees = 43.64
        let longitude: CLLocationDegrees = -79.38
        
        displayLocation(latitude: latitude, longitude: longitude,title: "toronto downtown" , subtitle: "beautiful city")
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(addlongPressAnnotation))
        map.addGestureRecognizer(uilpgr)
        addDoubleTap()
        addPlaces()
    }
    
    @IBAction func zoomin(_ sender: UIButton) {
       let span = MKCoordinateSpan(latitudeDelta: map.region.span.latitudeDelta*2 , longitudeDelta: map.region.span.longitudeDelta * 2)
       let region = MKCoordinateRegion(center: mapView.region.center, span: span)
       map.setRegion(region, animated: true)


    }
    @IBAction func zoomout(_ sender: UIButton) {
        let span = MKCoordinateSpan(latitudeDelta: map.region.span.latitudeDelta*2 , longitudeDelta: map.region.span.longitudeDelta * 2)
               let region = MKCoordinateRegion(center: mapView.region.center, span: span)
               map.setRegion(region, animated: true)
    }
    
    func addPlaces(){
        map.addAnnotations(Places)
        let overlays = Places.map { MKCircle(center: $0.coordinate, radius: 1000)}
        map.addOverlays(overlays)
    }
    
    func addPolyline(){
        let coordinates = Places.map {$0.coordinate}
         let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
         map.addOverlay(polyline)
    }
    
    func addPolygon(){
        let coordinates = Places.map {$0.coordinate}
        let polyline = MKPolygon(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polyline)

    }
    
    @objc func addlongPressAnnotation(gestureRecognizer: UIGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = "my destination"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let userLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        displayLocation(latitude: latitude, longitude: longitude, title: "your location", subtitle: "you are here")
    }

    func displayLocation(latitude latitude: CLLocationDegrees, longitude longitude: CLLocationDegrees, title title: String, subtitle subtitle: String){
        let latDelta : CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = "beautiful city"
        annotation.coordinate = location
        map.addAnnotation(annotation)
    }

    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)
    }
    
    
    
    @objc func dropPin(sender: UITapGestureRecognizer){
    //    removePin()
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        
        annotation.title = "my destination"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        destination = coordinate
        }
    func removePin(){
        for annotation in map.annotations{
            map.removeAnnotation(annotation)
        }
    }
    @IBAction func drawDirection(_ sender: UIButton) {
        map.removeOverlays(map.overlays)
        let sourcePlaceMark = MKPlacemark(coordinate: locationManager.location!.coordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        let directionrequest = MKDirections.Request()
        directionrequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionrequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionrequest.transportType = .walking
        let directions = MKDirections(request: directionrequest)
        directions.calculate { (response, Error) in
            guard let directionResponse = response else {return}
            let route = directionResponse.routes[0]
            self.map.addOverlay(route.polyline, level: .aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
        }
        
        
    }
}
extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
      //  let PinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        //PinAnnotation.animatesDrop = true
        let PinAnnotation = map.dequeueReusableAnnotationView(withIdentifier: "droppablePin") ?? MKPinAnnotationView()
        PinAnnotation.image = UIImage(named: "pin icon_2x")
        PinAnnotation.canShowCallout = true
        PinAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return PinAnnotation
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "your place", message: "welcome", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        if overlay is MKCircle{
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.green
            renderer.lineWidth = 2
            return renderer
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3
            return renderer
        } else if overlay is MKPolygon{
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.6)
            renderer.strokeColor = UIColor.purple
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    
    }

