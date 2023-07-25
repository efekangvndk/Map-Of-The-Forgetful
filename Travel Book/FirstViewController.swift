
import UIKit
import CoreData

class FirstViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{

    var choosenTitle = ""
    var choosenTitleId : UUID?
    
    var titleArray = [String]()
    var idArray = [UUID]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ///--------------------------Bar Button Color & Size-------------------------------
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtoncliked))
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            // Geri düğmesinin metin rengini siyah olarak ayarlayın
        navigationController?.navigationBar.tintColor = UIColor.red
            // Geri düğmesinin metnini kalınlaştırmak için fontu değiştirin (örneğin, Helvetica-Bold)
            let font = UIFont.boldSystemFont(ofSize: 20)
            backButton.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
            // Geri düğmesini navigation item'a ayarlayın
            navigationItem.backBarButtonItem = backButton
        ///------------------------------------------------
        
        tableView.dataSource = self
        tableView.delegate = self
        
        getData()
    }
    //---------------View WillAppear-------- : viewDidLoad bir kez viewWillAppear sürekli çağırılır
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    
   @objc func getData (){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "Places")
        request.returnsObjectsAsFaults = false
        
        do {
            let results =  try context.fetch(request)
            
            if results.count > 0 {
                
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject]{
                    if let title =  result.value(forKey: "title") as? String{
                        self.titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    tableView.reloadData()
                }
            }
            
            print("Succes!!")
        }catch{
            print("Error!")
        }
    }

    
    @objc func addButtoncliked () {
        choosenTitle = ""
        performSegue(withIdentifier: "toRealViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {//hangi sıraylar.
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = titleArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenTitle = titleArray[indexPath.row]
        choosenTitleId = idArray[indexPath.row]
        performSegue(withIdentifier: "toFirstViewController", sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFirstViewController" {
            let destinationsVc = segue.destination as! SecViewController
            destinationsVc.selectedTitle = choosenTitle
            destinationsVc.selectedTitleId = choosenTitleId

        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let idString = idArray[indexPath.row].uuidString
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            //yanlızca bir veri bulup silmek istiyoruz onun için predicate den o veriyi istyicez
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)

                if results.count > 0 {
                    for result in results as![NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                                context.delete(result)
                                titleArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    print("Error")
                                }
                                break
                            }
                        }
                    }
                }
            }catch{
                print("Error")
            }
             
        }
    }
}
