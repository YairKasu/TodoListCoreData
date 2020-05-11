//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Yair Kasuker on 11/03/2020.
//  Copyright © 2020 Yair Kasuker. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [CategoryList]()
    
    let dataFilePatch = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)// making a new file for contain the new and old data into it.
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //code line that shared the data we need from app delegate for making the coreData at the other files like this one to be save and load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        
    }
    
    //MARK: - TableView DataSource Methodes
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray.count
        // the numbers of the row dependent on the value size of the array.
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let category = categoryArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = category.name
        //In this line of code we build the reusable cell with our identifier to allow us creat the cells repeatedly.
        
        //Value = Condition ? ValueIfTrue : ValueIfFalse
        //        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - Data Manipulation Methodes
    
    func saveItems() {
           
           do{
                try context.save()
            }catch{
                print("Fail Save Context, \(error)")
            }
        
        self.tableView.reloadData() //Important Line for reload the changes directly into the App.
    }
    
    func loadItems(with request: NSFetchRequest<CategoryList> = CategoryList.fetchRequest()){
    
        do{
           categoryArray = try context.fetch(request)
        }catch{
            print("Error fetching data from request \(error)")
        }
        
        tableView.reloadData()
        
        // this loadItems function with a paramter of type NSFetchRequest that have a default value that bring us the data form the file of the core data that we created during our code.
    }

    
    //MARK: - Add New Categories With UIAlert
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            textField = alert.textFields![0]
            if textField.text != nil {
                
                let newItem = CategoryList(context: self.context)
                newItem.name = textField.text!
                self.categoryArray.append(newItem)
                
              self.saveItems()
                
            }
        }
        
        alert.addTextField { (textFieldAlert) in
            textFieldAlert.placeholder = "Type Here"
            textField = textFieldAlert
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView Delegate Methodes
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    
    
}
