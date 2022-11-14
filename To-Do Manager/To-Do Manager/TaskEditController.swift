//
//  TaskEditController.swift
//  To-Do Manager
//
//  Created by Дмитрий Никольский on 11.11.2022.
//

import UIKit

class TaskEditController: UITableViewController {

    var taskText:String = ""
    var taskType: TaskPriority = .normal
    var taskStatus: TaskStatus = .planned
    var doAfterEdit: ((String, TaskPriority, TaskStatus) -> Void)?
    private var taskTitles : [TaskPriority:String] = [
        .normal: "Текущая",
        .important: "Важная"
    ]
    
    @IBOutlet var taskTitle: UITextField!
    @IBOutlet var taskTypeLabel: UILabel!
    @IBOutlet var taskStatusSwitch: UISwitch!
    
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        // получаем актуальные значения
        let title = taskTitle?.text ?? ""
        let type = taskType
        let status: TaskStatus = taskStatusSwitch.isOn ? .completed : .planned
        // вызываем обработчик
        doAfterEdit?(title, type, status)
        // возвращаем предыдущий экран
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // обновление текстового поля с названием задачи
        taskTitle!.text = taskText
        // обновление текстовой метки
        taskTypeLabel?.text = taskTitles[taskType]
        if taskStatus == .completed {
            taskStatusSwitch.isOn = true
        }
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
        return 3
    }
    // передача данныъ эдит -> тайп
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskTypeScreen" {
            // ссылка на контроллер назначения
            let destination = segue.destination as! TaskTypeController
            // передача выбранного типа
            destination.selectedType = taskType
            // передача обработчика типа
            destination.doAfterTypeSelected = { [unowned self] selectedType in
                taskType = selectedType
                // обновление метки
                taskTypeLabel?.text = taskTitles[taskType]
            }
        }
    }
}
