//
//  Task.swift
//  To-Do Manager
//
//  Created by Дмитрий Никольский on 09.11.2022.
//

import UIKit

//приоритет задачи
enum TaskPriority {
    case normal
    case important
}
//состояние задачи
enum TaskStatus: Int {
    case planned
    case completed
}

// протокол, описывающий задачу
protocol TaskProtocol {
    var title: String {get set}
    var status: TaskStatus {get set}
    var type: TaskPriority {get set}
}

struct Task: TaskProtocol {
    var title: String
    var status: TaskStatus
    var type: TaskPriority
}

