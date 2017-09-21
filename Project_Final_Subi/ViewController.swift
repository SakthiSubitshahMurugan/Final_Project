//
//  ViewController.swift
//  Project_Final_Subi
//
//  Created by Sakhti Subitshah Murugan on 9/18/17.
//  Copyright © 2017 Sakhti Subitshah Murugan. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController,GMUClusterManagerDelegate,GMSMapViewDelegate{
    
    @IBOutlet weak var SearchBar: UISearchBar!
    //  @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var label1: UILabel!
    var mapView : GMSMapView!
    var clusterManager : GMUClusterManager!
    let isClustering : Bool = true
    let isCustom : Bool = true

    override func viewDidLoad() {
        let todoEndpoint: String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?////location=-33.8670522,151.1957362&radius=500&type=restaurant&keyword=cruise&key=AIzaSyDrHvUN5cGtpUpkm5Go9RffVQs_THWnR-s"
        /*"https://maps.googleapis.com/maps/api/place/nearbysearch/json?////location=-33.8670522,151.1957362&radius=500&type=restaurant&keyword=cruise&key=AIzaSyCUFxTeGzMo-S1tbvH7Oz-phy4f-C-VsQ0"*/
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        let config = URLSessionConfiguration.default
        let session = URLSession.shared
        //let session = URLSession(configuration: config)
        
        
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
         // do stuff with response, data & error here
         // print(error!)
            print("*************************")
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    print("error trying to convert data to JSON")
                    return
                }
                // now we have the todo, let's just print it to prove we can access it
                print("The todo is: " + todo.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let todoTitle = todo["title"] as? String else {
                    print("Could not get todo title from JSON")
                    return
                }
                print("The title is: " + todoTitle)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            print("*************************")
        })
        task.resume()
       
        super.viewDidLoad()
        mapView = GMSMapView(frame: view.frame)
        mapView.camera = GMSCameraPosition.camera(withLatitude: 36.2136881, longitude: -100.7024773, zoom: 3.0)
        mapView.mapType = .normal
        mapView.delegate = self
        view.addSubview(mapView)
        view.addSubview(SearchBar)
        
        
        
        
        if isClustering{
            var iconGenerator : GMUDefaultClusterIconGenerator!
            if isCustom{
                var images : [UIImage] = []
                for imageID in 1...5{
                    //print(imageID)
                    images.append(UIImage(named:"\(imageID).jpeg")!)
                }
                iconGenerator = GMUDefaultClusterIconGenerator(buckets: [1,2,5,7,13], backgroundImages: images)
            }else {
                iconGenerator = GMUDefaultClusterIconGenerator()
            }
            let algorithm1 = GMUNonHierarchicalDistanceBasedAlgorithm()
            let renderer1 = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
            
            clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm1, renderer: renderer1)
            clusterManager.cluster()
            clusterManager.setDelegate(self, mapDelegate: self)
        }else{
            
        }
        
        
    }
    class POIItem : NSObject,GMUClusterItem{
        var position: CLLocationCoordinate2D
        var name : String!
        
        init(position : CLLocationCoordinate2D , name :String){
            self.position = position
            self.name = name
        }
    }
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom+1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return true
    }
   /* private func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster)  {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom+1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
    }*/
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let item = POIItem(position:coordinate , name :"New")
        clusterManager.add(item)
        clusterManager.cluster()
    }
    
}

