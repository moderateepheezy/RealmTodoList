//
//  ViewController.swift
//  RealmTodoList
//
//  Created by SimpuMind on 9/4/17.
//  Copyright © 2017 SimpuMind. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    var searchBar: UISearchBar!
    
    var searchActive : Bool = false
    
    let tableView : UITableView = {
       let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let realm = try! Realm()
    var todos: Results<Todo>!
    
    var openTasks : Results<Todo>!
    var completedTasks : Results<Todo>!
    
    var currentCreateAction:UIAlertAction!
    
    var isEditable = false
    
    var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let scArray = ["A-Z", "Z-A", "By Recent", "By Past"]
        segmentedControl = UISegmentedControl(items: scArray)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.frame = CGRect(x: 0, y: 64, width: view.frame.width, height: 30)
        navigationItem.title = "Todo List"
        segmentedControl.addTarget(self, action: #selector(handleSortType(sender:)), for: .valueChanged)
        view.addSubview(tableView)
        view.addSubview(segmentedControl)
        addSubViewConstrian()
        
        searchBar = UISearchBar(frame: CGRect(x: 40, y: 0, width: 360, height: 40))
        searchBar.placeholder = "Search for a Task"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
        let addTodoBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddTodo))
        
        let editTodobarButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(handlEditTodo(sender:)))
        
        self.navigationItem.rightBarButtonItem = addTodoBarButton
        self.navigationItem.leftBarButtonItem  = editTodobarButton
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        //readTasksAndUpateUI()
        updateUIView()
    }
    
    func addSubViewConstrian(){
        
        _ = tableView.anchor(segmentedControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    func handleAddTodo(updatedTask: Todo){
        
        showAlertView(todo: nil)
    }
    
    func showAlertView(todo: Todo!){
        
        let title = (todo != nil) ? "Update Todo" : "Add a new todo"
        let actionTitle = (todo != nil) ? "Update Task" : "Add Task"
        
        let alertController = UIAlertController(title: title, message: "What task are you doing buddy", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            
        }
        let addAction = UIAlertAction(title: actionTitle, style: .default) { (action) in
            guard let firstTextField = alertController.textFields?.first else {return}
            let _textField = firstTextField as UITextField
            guard let text = _textField.text else {return}
            let taskName = text
            
            if todo != nil{
                try! self.realm.write{
                    todo.task = taskName
                    self.readTasksAndUpateUI()
                }
            }
            else{
                
                self.addTodo(text: taskName)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateUIView(){
        
        todos = realm.objects(Todo.self).sorted(byKeyPath: "task", ascending: true)
        self.tableView.setEditing(false, animated: true)
        completedTasks = self.todos.filter("isCompleted = true")
        openTasks = self.todos.filter("isCompleted = false")
        self.tableView.reloadData()
    }
    
    func handleSortType(sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0{
            self.openTasks = self.openTasks.sorted(byKeyPath: "task", ascending: true)
            self.completedTasks = self.completedTasks.sorted(byKeyPath: "task", ascending: true)
        }else if sender.selectedSegmentIndex == 1{
            self.openTasks = self.openTasks.sorted(byKeyPath: "task", ascending: false)
            self.completedTasks = self.completedTasks.sorted(byKeyPath: "task", ascending: false)
        }else if sender.selectedSegmentIndex == 2{
            self.completedTasks = self.completedTasks.sorted(byKeyPath: "createdAt", ascending: true)
            self.openTasks = self.openTasks.sorted(byKeyPath: "createdAt", ascending: true)
        }else if sender.selectedSegmentIndex == 3{
            self.completedTasks = self.completedTasks.sorted(byKeyPath: "createdAt", ascending: false)
            self.openTasks = self.openTasks.sorted(byKeyPath: "createdAt", ascending: false)
        }
        tableView.reloadData()
    }
    
    func addTodo(text: String){
        let todo = Todo()
        todo.task = text
        todo.isCompleted = false
        todo.createdAt = Date()
        
        try! self.realm.write({
            self.realm.add(todo)
            self.tableView.insertRows(at: [IndexPath.init(row: self.todos.count-1, section: 0)], with: .automatic)
            self.readTasksAndUpateUI()
        })
    }
    
    func handlEditTodo(sender: UIBarButtonItem){
        isEditable = !isEditable
        self.tableView.setEditing(isEditable, animated: true)
    }
    
    func readTasksAndUpateUI(){
        //updateUIView()
        completedTasks = self.todos.filter("isCompleted = true")
        openTasks = self.todos.filter("isCompleted = false")
        
        self.tableView.reloadData()
    }

}


extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return openTasks.count
        }
        return completedTasks.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0{
            return "OPEN TASK"
        }
        return "COMPLETED TASK"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        var todo: Todo!
        if indexPath.section == 0{
            todo = openTasks[indexPath.row]
        }
        else{
            todo = completedTasks[indexPath.row]
        }
        
        cell.textLabel?.text = todo.task
        cell.detailTextLabel?.text = todo.createdAt.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete){
            let todo = todos[indexPath.row]
            try! self.realm.write({
                self.realm.delete(todo)
            })
            
            tableView.deleteRows(at:[indexPath], with: .automatic)
            
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            var taskToBeDeleted: Todo!
            if indexPath.section == 0{
                taskToBeDeleted = self.openTasks[indexPath.row]
            }
            else{
                taskToBeDeleted = self.completedTasks[indexPath.row]
            }
            
            try! self.realm.write{
                self.realm.delete(taskToBeDeleted)
                self.readTasksAndUpateUI()
            }
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            
            var taskToBeUpdated: Todo!
            if indexPath.section == 0{
                taskToBeUpdated = self.openTasks[indexPath.row]
            }
            else{
                taskToBeUpdated = self.completedTasks[indexPath.row]
            }
            
            self.showAlertView(todo: taskToBeUpdated)
            
        }
        
        let doneAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Done") { (doneAction, indexPath) -> Void in
            
            var taskToBeUpdated: Todo!
            if indexPath.section == 0{
                taskToBeUpdated = self.openTasks[indexPath.row]
            }
            else{
                taskToBeUpdated = self.completedTasks[indexPath.row]
            }
            try! self.realm.write{
                taskToBeUpdated.isCompleted = true
                self.readTasksAndUpateUI()
            }
            
        }
        return [deleteAction, editAction, doneAction]
    }
    
}

extension ViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        completedTasks = self.todos.filter("isCompleted = true")
        openTasks = self.todos.filter("isCompleted = false")
        tableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if searchText.characters.count > 0 {
                let predicate = NSPredicate(format: "task CONTAINS [c] %@", searchText)
                self.completedTasks = self.completedTasks.filter(predicate)
                self.openTasks = self.openTasks.filter(predicate)
                self.tableView.reloadData()
            }
        }
        
    }
    
}

