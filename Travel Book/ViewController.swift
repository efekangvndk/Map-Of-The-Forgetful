//
//  ViewController.swift
//  Travel Book
//
//  Created by Efekan Güvendik on 7.07.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
//Map için gerekli libraryler

class ViewController: UIViewController ,MKMapViewDelegate, CLLocationManagerDelegate{ //Gerekli class lar
    //----Vars & Plus button----
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    var choosenLatitude = Double()
    var choosenLongitude = Double()
    var locactionManeger = CLLocationManager()
    
    var nameChoosenArray = [String]()
    var commentChoosenArray = [String]()
    var idArray = [UUID]()
    
    var choosenName = ""
    var choosenComment = ""
    var choosenId = UUID()
    
    ///------------------------------------------------- Super View Did Load-----------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //----Gif & BackGround
        let worldGif = UIImage.gifImageWithName("world")
        imageView.image = worldGif
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backGround")!)
        
        //----Map Settings
        mapView.delegate = self
        locactionManeger.delegate = self
        locactionManeger.desiredAccuracy = kCLLocationAccuracyBest //Map deki sapma payımız.
        locactionManeger.requestWhenInUseAuthorization()
        locactionManeger.startUpdatingLocation()
        
        let gestureRegognizer = UILongPressGestureRecognizer(target: self, action: #selector(choosLocation(gestureRegognizer:)))
        //kullanıcıya pin işareti için uzun basma ikonu
        gestureRegognizer.minimumPressDuration = 2 // kaç saniye basılı tutulacak.
        mapView.addGestureRecognizer(gestureRegognizer)
        
    }
    
    @objc func choosLocation(gestureRegognizer : UILongPressGestureRecognizer){
        if gestureRegognizer.state == .began{ // adam tıkladı veya uzun bastı gibi.
            //kendi attiribute larına ulaşmak için bu func içinde yazarız ve duruma göre .began gibi etkenleri kullanabiliriz.
            let touchedPoint = gestureRegognizer.location(in: self.mapView) //nerdeki noktayı alalım mapView'dan al
            let touchedCordinate = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView) //dokunulan noktaları kordinatlara touchPoint'den mapView için.
            choosenLatitude = touchedCordinate.latitude
            choosenLongitude = touchedCordinate.longitude
            
            let annotation = MKPointAnnotation() //pin oluşturduk.
            annotation.coordinate = touchedCordinate //kordinatları annatationa veriyoruz.
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
            
        }
        
    }
    
    //Kullanıcıdan aldığımız veriyi ne yapmamız gerektiğini belirlemek için bu kod satırını kullanırız.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) //enlem ve boylam açan bir kod bloğu
        let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
        @IBAction func saveButton(_ sender: Any) {
            
        //burda biz bu context'e ulaşmak için appDelagat'ı bir değişken olarak tanımlarız.Yani bir temsilci
        //bunun için yani bu veriye uşalmak için altdaki kodu yazarız.
        ///UIApplication -> aplikasyonun kendisi
        ///shared -> uygulamyı döndürür
            ///
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Core dataya ulaşmak için NSentity discription'a ulaşmamız lazız. Burda Places adlı entity'yi gösterdik.
        let newplaces = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        //hangi veriyi istiyorsak o veri için bir key yazıyoruz.
            if nameText.text == "" {
                let alert = UIAlertController(title: "Hoop !", message: "Neyi Kaydediyoruz Dostum !", preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "PEKİİ つ ◕_◕ ༽つ ", style: UIAlertAction.Style.default)
                alert.addAction(okButton)
                self.present(alert , animated: true)
            } else if mapView.annotations.isEmpty {
                   let alert = UIAlertController(title: "Heyoo !", message: "( •_•)> Nereyi Kayıt Ediyoruz Başkaaan!", preferredStyle: .alert)
                   let okAction = UIAlertAction(title: "LÜTFEN", style: .default, handler: nil)
                   alert.addAction(okAction)
                   present(alert, animated: true, completion: nil)
               
        }else{
            newplaces.setValue(nameText.text, forKey: "title")
            newplaces.setValue(commentText.text, forKey: "subtitle")
            newplaces.setValue(choosenLatitude, forKey: "latitude")
            newplaces.setValue(choosenLongitude, forKey: "longitude")
            newplaces.setValue(UUID(), forKey: "id")
            
        }
            //----Annotations boş ise alert.
            
        do {
            try context.save()
            print("succes")
        } catch {
            print("error")
        }
        // bu kadar yaptık ancak save aldıklan sonra çık gir yapmadan tab view'a yeni places gelmiyor bunun için ((Notifications)) kullanıcaz
            NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
            //bu işlem tüm App'e mesaj yolluyor ve bak bir obzerver var o gelince ne olucak onu yap demek oluyor idi :D
            navigationController?.popViewController(animated: true)//---> bir önceki controllere geri götür 
    }
    
}


