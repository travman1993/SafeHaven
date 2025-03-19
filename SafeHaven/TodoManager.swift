//
//  TodoManager.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/1/25.
//
import Foundation
import SwiftUI

class TodoManager: ObservableObject {
    @Published var items: [TodoItem] = []
    private let userDefaults = UserDefaults.standard
    private let todosKey = "dailyTodos"
    private let lastResetDateKey = "lastTodoResetDate"
    
    init() {
        loadTodos()
        resetTodosIfNeeded()
    }
    
    func loadTodos() {
        if let data = userDefaults.data(forKey: todosKey),
           let savedItems = try? JSONDecoder().decode([TodoItem].self, from: data) {
            items = savedItems
        }
    }
    
    func saveTodos() {
        if let encoded = try? JSONEncoder().encode(items) {
            userDefaults.set(encoded, forKey: todosKey)
            userDefaults.set(Date(), forKey: lastResetDateKey)
        }
    }
    
    func resetTodosIfNeeded() {
        guard let lastResetDate = userDefaults.object(forKey: lastResetDateKey) as? Date else {
            // First time setup
            return
        }
        
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastResetDate) {
            // Reset todos if it's a new day
            items = []
            saveTodos()
        }
    }
    
    func addTodo(_ title: String) {
        let newItem = TodoItem(title: title)
        items.append(newItem)
        saveTodos()
    }
    
    func removeTodo(_ item: TodoItem) {
        items.removeAll { $0.id == item.id }
        saveTodos()
    }
    
    func toggleTodo(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
            saveTodos()
        }
    }
}
