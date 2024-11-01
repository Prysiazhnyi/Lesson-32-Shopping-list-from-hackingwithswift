//
//  ViewController.swift
//  Lesson 32-Shopping list
//
//  Created by Serhii Prysiazhnyi on 01.11.2024.
//

import UIKit

class ViewController: UITableViewController {
    
    var shoppingList = [String]()
    var completedItems = Set<Int>() // Хранение индексов выполненных задач
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ваш список покупок"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Додати", style: .plain, target: self, action: #selector(addNewPurchase))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        // Регистрация пользовательской ячейки
        tableView.register(ShoppingListCell.self, forCellReuseIdentifier: "ShoppingListCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("shoppingList", shoppingList.count)
        
        return shoppingList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListCell", for: indexPath) as? ShoppingListCell else {
            return UITableViewCell()
        }
        
        cell.shoppingLabel.text = shoppingList[indexPath.row]
        cell.checkBox.isOn = completedItems.contains(indexPath.row) // Проверка, завершена ли задача
        cell.checkBox.tag = indexPath.row // Установка тега для последующего использования
        cell.checkBox.addTarget(self, action: #selector(checkBoxToggled(_:)), for: .valueChanged) // Добавление действия при изменении состояния переключателя
        
        return cell
    }
    
    @objc func checkBoxToggled(_ sender: UISwitch) {
        let index = sender.tag
        if sender.isOn {
            completedItems.insert(index) // Добавляем индекс выполненной задачи
        } else {
            completedItems.remove(index) // Убираем индекс, если задача не выполнена
        }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none) // Обновляем ячейку
        print("completedItems",  completedItems.count)
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
        let errorTitle: String
        let errorMessage: String
        
        if !answer.isEmpty {
            if isPossible(word: answer) {
                shoppingList.append(answer)
                
                let indexPath = IndexPath(row: shoppingList.count - 1, section: 0)
                tableView.insertRows(at: [indexPath], with: .automatic)
             
                print("completedItems", completedItems.startIndex)
                return
            } else {
                errorTitle = "Занадто довге!"
                errorMessage = "Для вашої зручності введіть не більше 20ти символів"
            }
            let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func isPossible(word: String) -> Bool {
        return word.count <= 30
    }
    
    @objc func shareTapped() {
        // Объединяем элементы списка в одну строку
        let list = shoppingList.joined(separator: "\n")
        
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
              completedItems.remove(indexPath.row) // Удаляем индекс выполненной задачи, если есть
              
              // Удаление строки из таблицы
              tableView.deleteRows(at: [indexPath], with: .automatic)
          }
      }
}
