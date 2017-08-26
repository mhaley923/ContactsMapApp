//
//  ViewController.swift
//  ContactsApp
//
//  Created by Michael Haley on 7/14/17.
//  Copyright © 2017 Michael Haley. All rights reserved.
//
/*  https://www.youtube.com/watch?v=pt_hbo85OkI  */
/*  https://www.youtube.com/watch?v=5M6wuhckiqY */


import UIKit
import Contacts
import ContactsUI
import CoreLocation
import MapKit
import CoreData

class ViewController: UIViewController, CNContactPickerDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {
    
    var contacts: [NSManagedObject] = [];
    
    var sampleSize = 5;
    var index = 0;
    
    
    var selectedContact = ""; //hold recent picker selection
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func btnFunction2(_ sender: AnyObject) {
        
        print("print button 2 click \n \n");
        
        //self.coreDataSave(name: "Sally Smith", location: "New York University")
        
        //self.coreDataFetch()
        
        let contacts: [CNContact] = {
            let contactStore = CNContactStore()
            let keysToFetch = [
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                CNContactEmailAddressesKey,
                CNContactPhoneNumbersKey,
                CNContactImageDataAvailableKey,
                CNContactThumbnailImageDataKey] as [Any]
            
            // Get all the containers
            var allContainers: [CNContainer] = []
            do {
                allContainers = try contactStore.containers(matching: nil)
            } catch {
                print("Error fetching containers")
            }
            
            var results: [CNContact] = []
            
            // Iterate all containers and append their contacts to our results array
            for container in allContainers {
                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
                
                do {
                    let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                    results.append(contentsOf: containerResults)
                } catch {
                    print("Error fetching results for container")
                }
            }
            
            return results
        }()
        
        print("print contacts ", contacts)
    }
    
    @IBAction func btnFunction(_ sender: AnyObject) {
        
        print("print button click \n \n");
        let entityType = CNEntityType.contacts;
        
        let authStatus = CNContactStore.authorizationStatus(for: entityType);
        
        if authStatus == CNAuthorizationStatus.notDetermined{
            
            let contactStore = CNContactStore.init();
            contactStore.requestAccess(for: entityType, completionHandler: { (success, nil) in
                
                if success{
                    print("print Success \n \n");
                    self.OpenContacts();
                }
                else{
                    print("print Not authorized \n \n");
                    
                }
                
            })
            
        }
        else if authStatus == CNAuthorizationStatus.authorized{
            self.OpenContacts();
        }

    }
    @IBOutlet weak var myLabel: UILabel!

    override func viewDidLoad() {
        
        addObserver() //detect contact changes
        
        /* initialize location manager */
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(createPin(sender:)))
        longPressGesture.minimumPressDuration = 0.5
        
        mapView.addGestureRecognizer(longPressGesture)
        
        /* set up long hold */
    
        super.viewDidLoad()
        
    }
    
    
    //add observer
    func addObserver(){
        
        let contactStoreObs = CNContactStore()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(contactStoreDidChange), name: .CNContactStoreDidChange, object: nil)
        
        
    }
    
    //notification handler.....
    @objc func contactStoreDidChange(notification: NSNotification) {
        
        print("print DETECTED A CONTACT CHANGE EVENT")
        
    }
    
    func OpenContacts(){
        
        let contactPicker = CNContactPickerViewController.init();
        contactPicker.delegate = self;
        self.present(contactPicker, animated: true, completion: nil)
    
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        
        print("print CANCELED CONTACT SELECTION \n \n ");
        
        picker.dismiss(animated: true) {
        
        }
        
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        print("print " + contact.givenName);
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("print GETTING LOCATION \(locations[0].coordinate.longitude) \n")
        
        index+=1
        
        if index == sampleSize{
            
            index = 0
            locationManager.stopUpdatingLocation()
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            
            let region = MKCoordinateRegion(center: locations[0].coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
            
        }
        
    }
    
    
    func createPin(sender: UILongPressGestureRecognizer){
        
        let dropLoc = sender.location(in: self.mapView)
        
        let mapLoc = mapView.convert(dropLoc, toCoordinateFrom: mapView)
        
        //self.dropPin(location: dropLoc as AnyObject)
        
        //print("print long** ", mapLoc.longitude)
        //print("\n print lat** ", mapLoc.latitude)
        
        let pin = MKPointAnnotation()
        
        pin.coordinate = mapLoc
        pin.title = "Test Pin"
        pin.subtitle = "in current loc"
        
        self.mapView.addAnnotation(pin)

    }

    
    func coreDataSave(name: String, location: String){
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        //1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let entity =
            NSEntityDescription.entity(forEntityName: "Contact",
                                       in: managedContext)!
        
        let newContact = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        //3
        newContact.setValue(name, forKeyPath: "name")
        newContact.setValue(location, forKeyPath: "location")
        
        //4
        do {
            try managedContext.save()
            contacts.append(newContact)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        
    }
    
    
    func coreDataFetch(){
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let moc = appDelegate.persistentContainer.viewContext

        var aray = [Contact]()
        
        let entityName = String(describing: Contact.self)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        
        do {
            let fetchResult = try moc.fetch(fetchRequest)
            
            for contact in fetchResult {
                //let img = imageItem(name: contact.name!)
                //aray.append(img)
                print(contact)
                print(" \n \n")
            }
        }catch {
            print(error.localizedDescription)
        }
        
    }

}





