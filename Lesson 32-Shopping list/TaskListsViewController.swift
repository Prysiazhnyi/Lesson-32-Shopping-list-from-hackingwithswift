//
//  TaskListsViewController.swift
//  Lesson 32-Shopping list
//
//  Created by Serhii Prysiazhnyi on 02.11.2024.
//
import UIKit

protocol TaskListSelectionDelegate: AnyObject {
    func didSelectTaskList(_ taskList: TaskList)
}

class TaskListsViewController: UITableViewController {
    
    var taskLists: [TaskList] = []
    weak var delegate: TaskListSelectionDelegate?
    var lastSelectedIndex: Int? {
            get {
                return UserDefaults.standard.integer(forKey: "lastSelectedIndex") // Получаем сохраненный индекс
            }
            set {
                UserDefaults.standard.set(newValue ?? -1, forKey: "lastSelectedIndex") // Сохраняем новый индекс
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Твої списки"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskListCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Створити", style: .plain, target: self, action: #selector(addNewList))
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
         tableView.addGestureRecognizer(longPressGesture)
        
        loadTaskLists()
        displayLastSelectedList() // Отображение последнего выбранного списка
        
    }
    
    func displayLastSelectedList() {
            if taskLists.isEmpty {
                // Если списков нет, создаем новый
                let defaultList = TaskList(name: "Твій список", tasks: [])
                taskLists.append(defaultList)
                saveTaskLists()
                tableView.reloadData()
            } else if let lastIndex = lastSelectedIndex, lastIndex < taskLists.count {
                // Если есть сохраненный индекс, показываем соответствующий список
                let lastSelectedList = taskLists[lastIndex]
                title = lastSelectedList.name // Устанавливаем заголовок
            }
        }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: location) {
                let taskList = taskLists[indexPath.row] // Изменено на taskLists
                // Здесь вызывайте метод для редактирования списка
                presentEditAlert(for: taskList)
            }
        }
    }
    
    func presentEditAlert(for taskList: TaskList) {
        let alert = UIAlertController(title: "Редактировать список", message: "Введите новое имя списка", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = taskList.name
        }
        alert.addAction(UIAlertAction(title: "Зберегти", style: .default, handler: { _ in
                   if let newName = alert.textFields?.first?.text {
                       // Обновите имя списка
                       if let index = self.taskLists.firstIndex(where: { $0.name == taskList.name }) {
                           self.taskLists[index].name = newName // Здесь нужно изменить значение name
                           self.saveTaskLists()
                           self.tableView.reloadData()
                       }
                   }
               }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }

    
    func loadTaskLists() {
        taskLists.removeAll()
        if let data = UserDefaults.standard.data(forKey: "taskLists"),
           let decodedLists = try? JSONDecoder().decode([TaskList].self, from: data) {
            taskLists = decodedLists
        }
    }
    
    @objc func addNewList() {
        let ac = UIAlertController(title: "Створити новий список", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Створити", style: .default) { [weak self, weak ac] _ in
            guard let listName = ac?.textFields?[0].text, !listName.isEmpty else { return }
            self?.createNewList(named: listName)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func createNewList(named name: String) {
        let newList = TaskList(name: name, tasks: [])
        taskLists.insert(newList, at: 0)
        saveTaskLists()
        tableView.reloadData()
    }
    
    func saveTaskLists() {
        if let encodedData = try? JSONEncoder().encode(taskLists) {
            UserDefaults.standard.set(encodedData, forKey: "taskLists")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        let taskList = taskLists[indexPath.row]
        cell.textLabel?.text = taskList.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let selectedList = taskLists[indexPath.row]
         lastSelectedIndex = indexPath.row // Сохраняем индекс последнего выбранного списка
         title = selectedList.name // Устанавливаем заголовок
         delegate?.didSelectTaskList(selectedList)
         navigationController?.popViewController(animated: true)
     }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             taskLists.remove(at: indexPath.row)
             saveTaskLists()
             tableView.deleteRows(at: [indexPath], with: .automatic)
         }
     }
 }
