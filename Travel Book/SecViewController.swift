//
//  SecViewController.swift
//  Travel Book
//
//  Created by Efekan Güvendik on 14.07.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class SecViewController: UIViewController ,MKMapViewDelegate, CLLocationManagerDelegate{
    //----Labels----
    @IBOutlet weak var mapView2: MKMapView!
    @IBOutlet weak var nameInfoLabel: UILabel!
    @IBOutlet weak var commentInfoLabel: UILabel!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    //----Time----
    private var timer: Timer?

    //----Vars----
    var nameSecInfo = ""
    var commentSecInfo = ""
    var selectedTitle = ""
    var selectedTitleId : UUID?
    
    var annotationsLatitude = Double()
    var annotationsLongitude = Double()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTimer()

        //----------------------------- Seçilen Datya aktarma ve yapılacak işlemler.
        if selectedTitle != ""{
            ///Şimdi burada detay giriyoruz yani eğer image yok ise veya zaten save alınmış bir işlem var ise
            ///Save button ya olmıyacak yada gözükmeyecek
            
            ///core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            ///burada aşşağıdaki işlem satırı bize daha doğrusu predicate olan kısım şu demek oluyor
            ///bir işlem bloğu yazıcaz ve bize sadece o işlme bloğu içindeki öğeleri döndürecek
            ///yani tanımlanana sınırlar içinde mantıksal tanımlar demek yani
            ///seçilen öğeler arasında bir artis bir yıl ve bir isi gibi
            let idString = selectedTitleId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)// bu id si şurdaki yazan argumana eşit olanı  bul demek
            //ve bunu name den de yaparız ancak ya aynı ismli 2 veya fazla şey olursa ondan id den yaparz hepsi farklı olsun.
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    ///bu işlemden sora mecburan for loop a sokucaz çünki NSMonject dizisi içinde verilecek
                    ///yani her türlü bize bir dizi vericek.
                    for restult in results as! [NSManagedObject]{
                        
                        //----------Name İnfo Places-------------
                        if let name = restult.value(forKey: "title") as? String{
                            nameInfoLabel.text = name
                            if let comment = restult.value(forKey: "subtitle") as? String{
                                commentInfoLabel.text = comment
                                
                                //----------Lonitude & Latitude-------------
                                if let latitude = restult.value(forKey: "latitude") as? Double {
                                    annotationsLatitude = latitude
                                    if let longitude = restult.value(forKey: "longitude") as? Double{
                                        annotationsLongitude = longitude
                                        
                                        //kontrol etmek ve işlemek
                                        let annotations = MKPointAnnotation()
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationsLatitude, longitude: annotationsLongitude)
                                        annotations.coordinate = coordinate
                                        //bu noktaları map'de göstermek için map'e eklemek lazım
                                        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView2.setRegion(region, animated: true)
                                        mapView2?.addAnnotation(annotations)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                
            }catch{
                print("Error")
                
            }
            
            
            //---- name aktarma----
            nameSecInfo = nameInfoLabel.text!
            
            //--background & İmage---
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "firstbackground")!)
            
            
            
            
            if selectedTitle != "" {
                let stringUUID = selectedTitleId!.uuidString
                print(stringUUID )
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
      }
//-------------------------Time & Date--------------------------
    // Zamanlayıcıyı başlatan fonksiyon.
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        // Timer'ı anında başlatın.
        timer?.fire()
    }

    // Zamanlayıcıyı durduran fonksiyon.
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Zamanlayıcı tarafından çağrılacak fonksiyon.
    @objc private func updateClock() {
        // Güncel tarih ve saat bilgisini alın.
        let currentDate = Date()

        // SAAT İÇİN: Tarih ve saat bilgisini göstermek için uygun biçimde biçimlendirin.
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss" // Örneğin, "15:30:45" gibi bir saat formatı belirledik.
        let formattedTime = timeFormatter.string(from: currentDate)

        // Saat etiketini güncelleyin.
        clockLabel.text = formattedTime

        // TARİH İÇİN: Tarih bilgisini göstermek için uygun biçimde biçimlendirin.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy" // Örneğin, "25 Temmuz 2023" gibi bir tarih formatı belirledik.
        let formattedDate = dateFormatter.string(from: currentDate)

        // Tarih etiketini güncelleyin.
        dateLabel.text = formattedDate
    }
    //----------------------Navigations controller ekleme----------------------
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation{//burda kullanıcının yerini göstermesin diye yaptık.
            return nil
        }
        
        let resueId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: resueId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: resueId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.green
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure) //---> detay göstereceğim bir yeşil popup button
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
}
