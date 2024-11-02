//
//  ViewController.swift
//  Lesson 32-Shopping list
//
//  Created by Serhii Prysiazhnyi on 01.11.2024.
//

import UIKit

struct Task: Codable  {
    var name: String
    var isCompleted: Bool
}

class ViewController: UITableViewController {
    
    var shoppingList = [Task]() {
        didSet {
            updateTitle() // Обновляем title при изменении списка
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Додати", style: .plain, target: self, action: #selector(addNewPurchase))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        // Регистрация пользовательской ячейки
        tableView.register(ShoppingListCell.self, forCellReuseIdentifier: "ShoppingListCell")
        
        loadShoppingList() // Загрузка данных при запуске
        updateTitle()
    }
    //MARK: - Робота с Title
    
    // Функция для обновления заголовка
    func updateTitle() {
        let totalTasks = shoppingList.count
        let completedTasks = shoppingList.filter { $0.isCompleted }.count
        let titleText = "Ваш список задач: \(totalTasks) / \(completedTasks)"
        
        if totalTasks > 0 && totalTasks == completedTasks {
            // Если все задачи выполнены, устанавливаем зеленый цвет
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemGreen]
            navigationController?.navigationBar.titleTextAttributes = attributes
        } else if  totalTasks > 0 && completedTasks == 0 {
            // Если все задачи выполнены, устанавливаем зеленый цвет
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemRed]
            navigationController?.navigationBar.titleTextAttributes = attributes
        }else {
            // Если не все задачи выполнены, устанавливаем стандартный цвет
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label] // Цвет по умолчанию
            
            navigationController?.navigationBar.titleTextAttributes = attributes
        }
        
        title = titleText
    }
    
    // MARK: - Сохранение и загрузка данных
    
    func saveShoppingList() {
        if let encodedData = try? JSONEncoder().encode(shoppingList) {
            UserDefaults.standard.set(encodedData, forKey: "shoppingList")
        }
    }
    
    func loadShoppingList() {
        if let savedData = UserDefaults.standard.data(forKey: "shoppingList"),
           let decodedList = try? JSONDecoder().decode([Task].self, from: savedData) {
            shoppingList = decodedList
            tableView.reloadData()
        }
    }
    
    // MARK: - Методы для работы с таблицей
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListCell", for: indexPath) as? ShoppingListCell else {
            return UITableViewCell()
        }
        
        let task = shoppingList[indexPath.row]
        cell.shoppingLabel.text = task.name
        cell.checkBox.isOn = task.isCompleted // Устанавливаем состояние чекбокса в зависимости от флага `isCompleted`
        cell.checkBox.tag = indexPath.row
        cell.checkBox.addTarget(self, action: #selector(checkBoxToggled(_:)), for: .valueChanged)
        
        return cell
    }
    
    @objc func checkBoxToggled(_ sender: UISwitch) {
        let index = sender.tag
        shoppingList[index].isCompleted = sender.isOn // Обновляем флаг выполнения задачи в самой модели
        saveShoppingList()
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        updateTitle() // Обновляем заголовок после изменения состояния задачи
        printCompletedItems()
    }
    
    @objc func addNewPurchase() {
        let ac = UIAlertController(title: "Введіть бажаний товар", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Зберегти", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        
        if !answer.isEmpty {
            if isPossible(word: answer) {
                let newTask = Task(name: answer, isCompleted: false) // Создаем новую задачу с флагом `isCompleted = false`
                shoppingList.insert(newTask, at: 0)
                
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.insertRows(at: [indexPath], with: .automatic)
                tableView.reloadData()
                
                saveShoppingList()  // Сохранение списка после добавления новой задачи
                printCompletedItems()
                
                return
            } else {
                let ac = UIAlertController(title: "Занадто довге!", message: "Для вашої зручності введіть не більше 20ти символів", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        }
    }
    
    func isPossible(word: String) -> Bool {
        return word.count <= 30
    }
    
    @objc func shareTapped() {
        // Объединяем элементы списка в одну строку
        let list = shoppingList.map { $0.name }.joined(separator: "\n")
        
        // Проверяем, есть ли что-то для отправки
        if list.isEmpty {
            let ac = UIAlertController(title: "Список пустий", message: "Немає нічого для відправленя", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        // Создаем активити контроллер для шаринга
        let activityVC = UIActivityViewController(activityItems: [list], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    // MARK: - Удаление задачи
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Удаление из массива данных
            shoppingList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            // Перезагрузка таблицы вместо удаления строки
            tableView.reloadData()
            
            saveShoppingList() // Сохранение списка после удаления задачи
            updateTitle() // Обновляем заголовок после изменения состояния задачи
        }
    }
    
    @objc func printCompletedItems() {
        print("Количесво задач:", shoppingList.count)
        print("Состояние задач:")
        for (index, task) in shoppingList.enumerated() {
            print("Task \(index): \(task.name), Выполнено: \(task.isCompleted)")
        }
    }
}
