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
    
    var taskLists: [TaskList] = [] // Масив списків завдань
    weak var delegate: TaskListSelectionDelegate? // Делегат для вибору списку завдань
    var lastSelectedIndex: Int? {
        get {
            return UserDefaults.standard.integer(forKey: "lastSelectedIndex") // Отримуємо збережений індекс
        }
        set {
            UserDefaults.standard.set(newValue ?? -1, forKey: "lastSelectedIndex") // Зберігаємо новий індекс
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Твої списки" // Заголовок екрану
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label] // Колір заголовка
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskListCell") // Реєстрація клітинки таблиці
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Створити", style: .plain, target: self, action: #selector(addNewList)) // Кнопка для створення нового списку
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))) // Жест тривалого натискання
        tableView.addGestureRecognizer(longPressGesture) // Додаємо жест до таблиці
        
        loadTaskLists() // Завантажуємо списки завдань
        displayLastSelectedList() // Відображення останнього вибраного списку
    }
    
    func displayLastSelectedList() {
        if taskLists.isEmpty {
            // Якщо списків немає, створюємо новий
            let defaultList = TaskList(name: "Мій список", tasks: []) // Новий список за замовчуванням
            taskLists.append(defaultList) // Додаємо до масиву
            saveTaskLists() // Зберігаємо списки
            tableView.reloadData() // Оновлюємо таблицю
        } else if let lastIndex = lastSelectedIndex, lastIndex < taskLists.count {
            // Якщо є збережений індекс, показуємо відповідний список
            let lastSelectedList = taskLists[lastIndex]
            title = lastSelectedList.name // Встановлюємо заголовок
        }
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: location) {
                let taskList = taskLists[indexPath.row] // Отримуємо вибраний список
                presentEditAlert(for: taskList) // Показуємо алерт для редагування
            }
        }
    }
    
    func presentEditAlert(for taskList: TaskList) {
        let alert = UIAlertController(title: "Редагувати назву", message: "Введіть нове ім'я списку", preferredStyle: .alert) // Алерт для редагування
        alert.addTextField { textField in
            textField.text = taskList.name // Встановлюємо теку зі старим ім'ям
        }
        alert.addAction(UIAlertAction(title: "Зберегти", style: .default, handler: { _ in
            if let newName = alert.textFields?.first?.text {
                // Оновлюємо ім'я списку
                if let index = self.taskLists.firstIndex(where: { $0.name == taskList.name }) {
                    self.taskLists[index].name = newName // Змінюємо ім'я
                    self.saveTaskLists() // Зберігаємо списки
                    self.tableView.reloadData() // Оновлюємо таблицю
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Скасувати", style: .cancel)) // Дія скасування
        present(alert, animated: true) // Показуємо алерт
    }
    
    func loadTaskLists() {
        taskLists.removeAll() // Очищаємо масив списків
        if let data = UserDefaults.standard.data(forKey: "taskLists"),
           let decodedLists = try? JSONDecoder().decode([TaskList].self, from: data) {
            taskLists = decodedLists // Завантажуємо збережені списки
        }
    }
    
    @objc func addNewList() {
        let ac = UIAlertController(title: "Створити новий список", message: nil, preferredStyle: .alert) // Алерт для створення нового списку
        ac.addTextField() // Додаємо текстове поле
        
        let submitAction = UIAlertAction(title: "Створити", style: .default) { [weak self, weak ac] _ in
            guard let listName = ac?.textFields?[0].text, !listName.isEmpty else { return }
            self?.createNewList(named: listName) // Створюємо новий список
        }
        ac.addAction(submitAction) // Додаємо дію
        present(ac, animated: true) // Показуємо алерт
    }
    
    func createNewList(named name: String) {
        let newList = TaskList(name: name, tasks: []) // Створюємо новий список
        taskLists.insert(newList, at: 0) // Додаємо до початку масиву
        saveTaskLists() // Зберігаємо списки
        tableView.reloadData() // Оновлюємо таблицю
    }
    
    func saveTaskLists() {
        if let encodedData = try? JSONEncoder().encode(taskLists) {
            UserDefaults.standard.set(encodedData, forKey: "taskLists") // Зберігаємо закодовані дані
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskLists.count // Повертаємо кількість рядків
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath) // Отримуємо клітинку
        let taskList = taskLists[indexPath.row] // Отримуємо список завдань
        cell.textLabel?.text = taskList.name // Встановлюємо текст клітинки
        return cell // Повертаємо клітинку
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedList = taskLists[indexPath.row] // Отримуємо вибраний список
        lastSelectedIndex = indexPath.row // Зберігаємо індекс останнього вибраного списку
        title = selectedList.name // Встановлюємо заголовок
        delegate?.didSelectTaskList(selectedList) // Повідомляємо делегату про вибір списку
        navigationController?.popViewController(animated: true) // Повертаємось назад
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            taskLists.remove(at: indexPath.row) // Видаляємо список
            saveTaskLists() // Зберігаємо зміни
            tableView.deleteRows(at: [indexPath], with: .automatic) // Оновлюємо таблицю
        }
    }
}
