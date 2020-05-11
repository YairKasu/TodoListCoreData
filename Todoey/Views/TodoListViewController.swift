//
//  ViewController.swift
//  Todoey
//
//  Created by Yair Kasuker on 11/03/2020.
//  Copyright © 2019 Yair Kasuker. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory: CategoryList? {
        didSet{
            loadItems()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(dataFilePath)
        
        loadItems()
    
    }
    
    //MARK: - TableView DataSource Methodes
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = item.title
        
        //Value = Condition ? ValueIfTrue : ValueIfFalse
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - TableView Delegate Methode
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(itemArray[indexPath.row])
        
//        context.delete(itemArray[indexPath.row]) /*Deleting the items from dataCore*/
//        itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add Button in Action.
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        alertAction()
    }
    
    func alertAction() {
        var textField = UITextField()

         let alert = UIAlertController(title: "Add a new Item", message: "", preferredStyle: .alert)
         
         let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
             textField = alert.textFields![0]
             if textField.text != nil {
                 
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.done =  false
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)
                
                self.saveItems()
            
            }
         }
         
         alert.addTextField { (textFieldAlert) in
             textFieldAlert.placeholder = "Some default text"
             textField = textFieldAlert
         }
         
         alert.addAction(action)
         
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupulation Methods
    //that is the way we can save data to the memory phone, when we have a custom propertis
    
    func saveItems() {
           
           do{
                try context.save()
            }catch{
                print("Fail Save Context, \(error)")
            }
        
        self.tableView.reloadData() //Important Line for reload the changes to the App
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), Predicate:NSPredicate? = nil){

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = Predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
        do{
           itemArray = try context.fetch(request)
        }catch{
            print("Error fetching data from request \(error)")
        }
        tableView.reloadData()
    }
}

//MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
