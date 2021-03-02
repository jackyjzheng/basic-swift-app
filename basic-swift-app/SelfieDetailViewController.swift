//
//  DetailViewController.swift
//  basic-swift-app
//
//  Created by Jacky Zheng on 2/22/21.
//

import UIKit
import MapKit

class SelfieDetailViewController: UIViewController {
    
    @IBOutlet weak var selfieNameField: UITextField!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var selfieImageField: UIImageView!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet var expandMap: UITapGestureRecognizer!
    
    var selfie: Selfie? {
        didSet {
            configureView()
        }
    }
    
    let dateFormatter = { () -> DateFormatter in
        let d = DateFormatter()
        d.dateStyle = .short
        d.timeStyle = .short
        return d
    }()
    
    func configureView()
    {
        guard let selfie = selfie else
        {
            return
        }
        
        // View hiearchy race condition with prepare function on segue?
        _ = self.view
        guard let selfieNameField = selfieNameField,
              let selfieImageField = selfieImageField,
              let dateCreatedLabel = dateCreatedLabel
        else
        {
            return
        }
        
        if let position = selfie.position
        {
            self.mapview.setCenter(position.location.coordinate, animated: false)
            mapview.isHidden = false
        }
        
        selfieNameField.text = selfie.title
        selfieImageField.image = selfie.image
        dateCreatedLabel.text = dateFormatter.string(from: selfie.created)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.selfieNameField.resignFirstResponder()
        guard let selfie = selfie else
        {
            return
        }
        guard let text = selfieNameField?.text else
        {
            return
        }
        selfie.title = text
        try? SelfieStore.shared.save(selfie: selfie)
    }
    
    @IBAction func expandMap(_ sender: Any)
    {
        if let coordinate = self.selfie?.position?.location
        {
            print("test1")
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate.coordinate), MKLaunchOptionsMapTypeKey: NSNumber(value: MKMapType.mutedStandard.rawValue)]
            let placemark = MKPlacemark(coordinate: coordinate.coordinate, addressDictionary: nil)
            let item = MKMapItem(placemark: placemark)
            item.name = selfie?.title
            item.openInMaps(launchOptions: options)
        }
        print("here?")
    }
}

