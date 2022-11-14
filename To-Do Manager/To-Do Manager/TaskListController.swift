//
//  TaskListController.swift
//  To-Do Manager
//
//  Created by Дмитрий Никольский on 09.11.2022.
//

import UIKit

class TaskListController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       // кнопка активации режима редактирование
        navigationItem.leftBarButtonItem = editButtonItem

    }
    
    // хранилище
    var tasksStorage: TaskStorageProtocol = TasksStorage()
    // словарь задач
    var tasks: [TaskPriority:[TaskProtocol]] = [:] {

        didSet {
            
            
            for (tasksGroupPriority, tasksGroup) in tasks {
                
                tasks[tasksGroupPriority] = tasksGroup.sorted { task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2position
                    
                }
            }
            var savingArray: [TaskProtocol] = []
            tasks.forEach { _, value in
                savingArray += value
            }
            tasksStorage.saveTasks(savingArray)
            
        }
    }
    // приоритет отображенияя
    var sectionsTypesPosition: [TaskPriority] = [.important, .normal]
    
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]
    
    // получение списка задач, их разбор и установка в свойство tasks
    func setTasks(_ tasksCollection: [TaskProtocol]) {
        // подготовка коллекции с задачами
        // будем использовать только те задачи, для которых определена секция
        sectionsTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        // загрузка и разбор задач из хранилища
        tasksCollection.forEach { task in
            tasks[task.type]?.append(task)
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    //количество строк в секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //определяем приоритет задач, соответствующий текущей секции
        let taskType = sectionsTypesPosition[section]
        guard let currentTasksType = tasks[taskType] else {
            return 0
        }
        return currentTasksType.count
    }
    // ячейка для строки таблицы
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getConfiguratedTaskCell_stack(for: indexPath)
    }
    // на основе кастомного класса и горизонтального стека
    private func getConfiguratedTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
        // загружаем прототип ячейки по идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        // данные о задаче, которую выводим
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        // изменяем текст в ячейке
        cell.title.text = currentTask.title
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        // изменяем цвет текста
        if currentTask.status == .planned {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        return cell
    }
    
        // возвращаем символ для соответствующего типа задачи
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var resultSymbol: String
        if status == .planned {
            resultSymbol = "\u{25CB}"
        } else if status == .completed {
            resultSymbol = "\u{25C9}"
        } else {
            resultSymbol = ""
        }
        return resultSymbol
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let tasksType = sectionsTypesPosition[section]
        if tasksType == .important {
            title = "Важные"
        } else if tasksType == .normal {
            title = "Текущие"
        }
        return title
    }
    //изменение статуса на "выполнено"
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //проверка существоания задачи
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return
        }
        //задача не является выполненной
        guard tasks[taskType]![indexPath.row].status == .planned else {
                // снимаем выделение строки
                tableView.deselectRow(at: indexPath, animated: true)
                return
        }
        // задача выполнена
        tasks[taskType]![indexPath.row].status = .completed
        // перезагружаем секцию таблицы
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    //изменение на "запланировано"
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //получаем данные о задаче, которую необходимо перевести в статус "запланирована"
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }
        //действие для изменения статуса
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "Не выполнена") { _,_,_ in
            self.tasks[taskType]![indexPath.row].status = .planned
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        // переходим к экрану редактирования
        let actionEditInstance = UIContextualAction(style: .normal, title: "Изменить") {_,_,_ in
            // загрузка сцены со сториборда
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskEditController") as! TaskEditController
            // передача значений редактируемой задачи
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            // передача обработчика для сохранения задачи
            editScreen.doAfterEdit = { [self] title, type, status in
                let editedTask = Task(title: title, status: status, type: type)
                tasks[taskType]!.remove(at: indexPath.row)
                tasks[type]?.append(editedTask)
                
                tableView.reloadData()
            }
            //переход к экрану редактирования
            self.navigationController?.pushViewController(editScreen, animated: true)
        }
            // цвет фона кнопки с действием
        actionEditInstance.backgroundColor = .darkGray
        // для свайпа 1 или 2 действия
        let actionsConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionSwipeInstance, actionEditInstance])
        } else {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionEditInstance])
    }
        
        return actionsConfiguration
    }
    
    // удаление задачи
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPosition[indexPath.section]
        // удаляем задачу
        tasks[taskType]?.remove(at: indexPath.row)
        // удаляем соответствующую строку
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // перемещение задачи в ручном режиме
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // секция, из которой перемещаем
        let taskTypeFrom = sectionsTypesPosition[sourceIndexPath.section]
        // в которую перемещаем
        let taskTypeTo = sectionsTypesPosition[destinationIndexPath.section]
        
        // извлекаем задачу
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }
        // удаляем задачу из изначального места
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        // вставляем в новую позицию
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)
        // изменяем тип задачи, если секция изменилась
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }
        // обновляем таблицу
        tableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = { [unowned self] title, type, status in
                let newTask = Task(title: title, status: status, type: type)
                print(newTask)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
        }
    }
}
