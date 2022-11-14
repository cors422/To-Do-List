//
//  TaskTypeController.swift
//  To-Do Manager
//
//  Created by Дмитрий Никольский on 11.11.2022.
//

import UIKit

class TaskTypeController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // получение UINib значения, соответствующего xib файлу
        let cellTypeNib = UINib(nibName: "TaskTypeCell", bundle: nil)
        // регистрация кастомной ячейки
        tableView.register(cellTypeNib, forCellReuseIdentifier: "TaskTypeCell")
       
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tableView.reloadData()
//    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskTypesInformation.count
    }
    // описание задачи
    typealias TypeCellDescription = (type: TaskPriority, title: String, description: String)
    
    // описание типов задач
    private var taskTypesInformation: [TypeCellDescription] = [
        (type: .important, title: "Важная", description: "Задача имеет наивысший приоритет, отображается вверху списка"),
        (type: .normal, title: "Текущая", description: "Обычный приоритет")
    ]
    var selectedType: TaskPriority = .normal
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // получение кастомной ячейки по идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTypeCell", for: indexPath) as! TaskTypeCell
        // получаем текщий элемент
        let typeDescription = taskTypesInformation[indexPath.row]
        // заполняем ячейку
        cell.typeTitle.text = typeDescription.title
        cell.typeDescription.text = typeDescription.description
        // отмечаем галочкой
        if selectedType == typeDescription.type {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    // передача данных тайп -> эдит
    var doAfterTypeSelected: ((TaskPriority) -> Void)?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //выбранный тип
        let selectedType = taskTypesInformation[indexPath.row].type
        // вызов обработчика
        doAfterTypeSelected?(selectedType)
        // переход к предыдущему экрану
        navigationController?.popViewController(animated: true)
    }
}
