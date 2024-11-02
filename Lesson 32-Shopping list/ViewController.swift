//
//  ViewController.swift
//  Lesson 32-Shopping list
//
//  Created by Serhii Prysiazhnyi on 01.11.2024.
//

import UIKit

class Task: Codable {
    var name: String
    var isCompleted: Bool
    
    init(name: String, isCompleted: Bool) {
        self.name = name
        self.isCompleted = isCompleted
    }
}

class TaskList: Codable {
    var name: String
    var tasks: [Task]
    
    init(name: String, tasks: [Task]) {
        self.name = name
        self.tasks = tasks
    }
}

class ViewController: UITableViewController, TaskListSelectionDelegate {
    
    private let defaults = UserDefaults.standard
    private let taskListsKey = "taskLists"
    private var taskLists: [TaskList] = []
    var listName: String = ""

    
    var currentList: TaskList? {
        didSet {
            shoppingList = currentList?.tasks ?? []
            updateTitle()
            tableView.reloadData()
        }
    }
    
    func didSelectTaskList(_ taskList: TaskList) {
        currentList = taskList
        shoppingList = taskList.tasks
        listName = taskList.name
        print("Выбранный список: \(currentList?.name ?? "Нет названия")")
        updateTitle()
        saveCurrentList()
        tableView.reloadData()
    }

    
    var shoppingList: [Task] = [] {
        didSet {
            updateTitle() // Обновляем title при изменении списка
        }
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Додати", style: .plain, target: self, action: #selector(addNewPurchase))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Списки", style: .plain, target: self, action: #selector(showTaskLists))
        
        tableView.register(ShoppingListCell.self, forCellReuseIdentifier: "ShoppingListCell")
        
        loadTaskLists()
        loadCurrentList()
    }
    
    @objc func showTaskLists() {
        let taskListsViewController = TaskListsViewController()
        taskListsViewController.delegate = self
        navigationController?.pushViewController(taskListsViewController, animated: true)
    }
    
    // MARK: - Title Updates
    
    func updateTitle() {
        let totalTasks = shoppingList.count
        let completedTasks = shoppingList.filter { $0.isCompleted }.count
        
        let titleText = "\(listName): \(totalTasks) / \(completedTasks)"
        title = titleText
        
        let color: UIColor = totalTasks > 0
            ? (totalTasks == completedTasks ? .systemGreen : (completedTasks == 0 ? .systemRed : .label))
            : .label
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: color]
    }
    
    // MARK: - Data Persistence
    
    func saveTaskLists() {
        if let encodedData = try? JSONEncoder().encode(taskLists) {
            defaults.set(encodedData, forKey: taskListsKey)
        }
    }
    
    func loadTaskLists() {
        if let savedData = defaults.data(forKey: taskListsKey),
           let decodedLists = try? JSONDecoder().decode([TaskList].self, from: savedData) {
            taskLists = decodedLists
        }
    }
    
    func saveCurrentList() {
        if let currentList = currentList,
           let index = taskLists.firstIndex(where: { $0.name == currentList.name }) {
            taskLists[index] = currentList
            saveTaskLists()
        }
    }
    
    func loadCurrentList() {
        if let savedData = defaults.data(forKey: "currentList"),
           let decodedList = try? JSONDecoder().decode(TaskList.self, from: savedData) {
            currentList = decodedList
        }
    }
    
    // MARK: - Table View Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListCell", for: indexPath) as? ShoppingListCell else {
            return UITableViewCell()
        }
        
        let task = shoppingList[indexPath.row]
        cell.shoppingLabel.text = task.name
        cell.checkBox.isOn = task.isCompleted
        cell.checkBox.tag = indexPath.row
        cell.checkBox.addTarget(self, action: #selector(checkBoxToggled(_:)), for: .valueChanged)
        
        return cell
    }
    
    @objc func checkBoxToggled(_ sender: UISwitch) {
        let index = sender.tag
        shoppingList[index].isCompleted = sender.isOn
        currentList?.tasks = shoppingList
        saveCurrentList()
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
    
    @objc func addNewPurchase() {
        guard currentList != nil else { return }
        let ac = UIAlertController(title: "Введіть свої нотатки", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Зберегти", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        guard !answer.isEmpty, isPossible(word: answer) else { return }
        
        let newTask = Task(name: answer, isCompleted: false)
        shoppingList.insert(newTask, at: 0)
        currentList?.tasks = shoppingList
        saveCurrentList()
        
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    func isPossible(word: String) -> Bool {
        return word.count <= 30
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            shoppingList.remove(at: indexPath.row)
            currentList?.tasks = shoppingList
            saveCurrentList()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
