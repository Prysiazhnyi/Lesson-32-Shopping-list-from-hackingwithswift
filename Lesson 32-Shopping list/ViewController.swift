//
//  ViewController.swift
//  Lesson 32-Shopping list
//
//  Created by Serhii Prysiazhnyi on 01.11.2024.
//

import UIKit

class Task: Codable {
    var name: String // Назва завдання
    var isCompleted: Bool // Статус виконання завдання
    
    init(name: String, isCompleted: Bool) {
        self.name = name
        self.isCompleted = isCompleted
    }
}

class TaskList: Codable {
    var name: String // Назва списку завдань
    var tasks: [Task] // Масив завдань
    
    init(name: String, tasks: [Task]) {
        self.name = name
        self.tasks = tasks
    }
}

class ViewController: UITableViewController, TaskListSelectionDelegate {
    
    private let defaults = UserDefaults.standard // Стандартні налаштування
    private let taskListsKey = "taskLists" // Ключ для зберігання списків завдань
    private var taskLists: [TaskList] = [] // Масив списків завдань
    var listName: String = "" // Назва поточного списку
    let currentListKey = "currentListKey" // Ключ для зберігання поточного списку
    
    var currentList: TaskList? { // Поточний список завдань
        didSet {
            shoppingList = currentList?.tasks ?? [] // Оновлюємо список покупок
            updateTitle() // Оновлюємо заголовок
            tableView.reloadData() // Оновлюємо таблицю
        }
    }
    
    func didSelectTaskList(_ taskList: TaskList) { // Метод для вибору списку завдань
        currentList = taskList // Встановлюємо поточний список
        shoppingList = taskList.tasks // Оновлюємо список покупок
        listName = taskList.name // Оновлюємо назву списку
        print("Вибраний список: \(currentList?.name ?? "Немає назви")") // Виводимо вибраний список
        updateTitle() // Оновлюємо заголовок
        saveCurrentList() // Зберігаємо поточний список
        tableView.reloadData() // Оновлюємо таблицю
    }
    
    var shoppingList: [Task] = [] { // Список покупок
        didSet {
            updateTitle() // Оновлюємо заголовок при зміні списку
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Налаштовуємо кнопки навігаційного меню
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Додати", style: .plain, target: self, action: #selector(addNewPurchase))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Списки", style: .plain, target: self, action: #selector(showTaskLists))
        
        tableView.register(ShoppingListCell.self, forCellReuseIdentifier: "ShoppingListCell") // Реєструємо кастомну клітинку
        
        loadTaskLists() // Завантажуємо списки завдань
        loadCurrentList() // Завантажуємо поточний список
        
        // Додаємо жест тривалого натискання
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func showTaskLists() { // Метод для показу списків завдань
        let taskListsViewController = TaskListsViewController() // Створюємо контролер списків завдань
        taskListsViewController.delegate = self // Встановлюємо делегата
        navigationController?.pushViewController(taskListsViewController, animated: true) // Переходимо до контролера
    }
    
    // MARK: - Обробник жесту тривалого натискання
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: tableView) // Отримуємо координати натискання
            guard let indexPath = tableView.indexPathForRow(at: point) else { return } // Отримуємо шлях до рядка
            
            // Отримуємо завдання для редагування
            let task = shoppingList[indexPath.row]
            presentEditTaskAlert(for: task, at: indexPath) // Показуємо алерт для редагування
        }
    }
    
    // MARK: - Показати алерт для редагування завдання
    func presentEditTaskAlert(for task: Task, at indexPath: IndexPath) {
        let ac = UIAlertController(title: "Редагувати завдання", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.text = task.name // Встановлюємо текуще назву завдання в текстове поле
        }
        
        let submitAction = UIAlertAction(title: "Зберегти", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.updateTask(at: indexPath, with: answer) // Оновлюємо завдання
        }
        ac.addAction(submitAction)
        present(ac, animated: true) // Показуємо алерт
    }
    
    // MARK: - Оновити завдання
    func updateTask(at indexPath: IndexPath, with newName: String) {
        guard !newName.isEmpty else { return } // Перевіряємо, чи не порожнє нове ім'я
        
        shoppingList[indexPath.row].name = newName // Оновлюємо назву завдання
        currentList?.tasks = shoppingList // Оновлюємо завдання в поточному списку
        saveCurrentList() // Зберігаємо поточний список
        
        tableView.reloadRows(at: [indexPath], with: .none) // Оновлюємо рядок таблиці
    }
    
    // MARK: - Оновлення заголовка
    func updateTitle() {
        let totalTasks = shoppingList.count // Загальна кількість завдань
        let completedTasks = shoppingList.filter { $0.isCompleted }.count // Кількість виконаних завдань
        
        // Створюємо UILabel для listName
        let listNameLabel = UILabel()
        listNameLabel.adjustsFontSizeToFitWidth = true // Автоматичне підстроювання шрифту
        listNameLabel.minimumScaleFactor = 0.7 // Мінімальний масштаб шрифту
        listNameLabel.lineBreakMode = .byTruncatingTail // Перенос рядка
        listNameLabel.text = listName // Встановлюємо текст заголовка
        listNameLabel.font = UIFont.systemFont(ofSize: 17) // Шрифт заголовка
        
        // Створюємо UILabel для статусу завдань
        let taskStatusLabel = UILabel()
        taskStatusLabel.text = ": \(totalTasks) / \(completedTasks)" // Встановлюємо текст статусу
        taskStatusLabel.font = UIFont.systemFont(ofSize: 17) // Шрифт статусу
        
        // Контейнерний StackView для об'єднання обох UILabel
        let titleStackView = UIStackView(arrangedSubviews: [listNameLabel, taskStatusLabel])
        titleStackView.axis = .horizontal // Горизонтальна ось
        titleStackView.alignment = .center // Вирівнювання по центру
        titleStackView.spacing = 5 // Проміжок між елементами
        
        // Встановлюємо колір заголовка
        let color: UIColor = totalTasks > 0
        ? (totalTasks == completedTasks ? .systemGreen : (completedTasks == 0 ? .systemRed : .label))
        : .label
        listNameLabel.textColor = color // Встановлюємо колір тексту заголовка
        taskStatusLabel.textColor = color // Встановлюємо колір тексту статусу
        
        // Встановлюємо titleView з нашим StackView
        navigationItem.titleView = titleStackView
    }
    
    // MARK: - Збереження даних
    func saveTaskLists() {
        if let encodedData = try? JSONEncoder().encode(taskLists) {
            defaults.set(encodedData, forKey: taskListsKey) // Зберігаємо закодовані дані
        }
    }
    
    func loadTaskLists() {
        if let savedData = defaults.data(forKey: taskListsKey),
           let decodedLists = try? JSONDecoder().decode([TaskList].self, from: savedData) {
            taskLists = decodedLists // Завантажуємо списки завдань
        }
    }
    
    func saveCurrentList() {
        if let currentList = currentList,
           let index = taskLists.firstIndex(where: { $0.name == currentList.name }) {
            taskLists[index] = currentList // Оновлюємо поточний список у масиві
            saveTaskLists() // Зберігаємо списки завдань
        }
    }
    
    func loadCurrentList() {
        if let savedData = defaults.data(forKey: currentListKey),
           let decodedList = try? JSONDecoder().decode(TaskList.self, from: savedData) {
            currentList = decodedList // Завантажуємо поточний список
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Кількість секцій у таблиці
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count // Кількість рядків у секції
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListCell", for: indexPath) as! ShoppingListCell // Отримуємо клітинку
        let task = shoppingList[indexPath.row] // Отримуємо завдання
        
        cell.textLabel?.text = task.name // Встановлюємо текст клітинки
        cell.accessoryType = task.isCompleted ? .checkmark : .none // Встановлюємо тип додаткового елемента
        
        return cell // Повертаємо клітинку
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            shoppingList.remove(at: indexPath.row) // Видаляємо завдання
            currentList?.tasks = shoppingList // Оновлюємо завдання в поточному списку
            saveCurrentList() // Зберігаємо поточний список
            tableView.deleteRows(at: [indexPath], with: .fade) // Оновлюємо таблицю
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shoppingList[indexPath.row].isCompleted.toggle() // Перемикаємо статус виконання
        tableView.reloadRows(at: [indexPath], with: .none) // Оновлюємо рядок таблиці
        saveCurrentList() // Зберігаємо поточний список
    }
    
    @objc func addNewPurchase() { // Метод для додавання нового завдання
        let ac = UIAlertController(title: "Додати нове завдання", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in // Додаємо текстове поле
            textField.placeholder = "Назва завдання" // Підказка
        }
        
        let submitAction = UIAlertAction(title: "Додати", style: .default) { [weak self, weak ac] action in
            guard let taskName = ac?.textFields?[0].text else { return }
            self?.addTask(name: taskName) // Додаємо завдання
        }
        
        ac.addAction(submitAction) // Додаємо дію
        present(ac, animated: true) // Показуємо алерт
    }
    
    // MARK: - Додати завдання
    func addTask(name: String) {
        let task = Task(name: name, isCompleted: false) // Створюємо нове завдання
        shoppingList.append(task) // Додаємо до списку
        currentList?.tasks = shoppingList // Оновлюємо завдання в поточному списку
        saveCurrentList() // Зберігаємо поточний список
        tableView.reloadData() // Оновлюємо таблицю
    }
}
