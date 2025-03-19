//
//  TodoView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/1/25.
//
import SwiftUI

struct TodoView: View {
    @StateObject private var todoManager = TodoManager()
    @State private var newTodoTitle = ""
    @State private var isExpanded = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                HStack(spacing: ResponsiveLayout.padding(12)) {
                    Image(systemName: "checklist")
                        .font(.system(
                            size: ResponsiveLayout.fontSize(22),
                            weight: .medium
                        ))
                        .foregroundColor(Color(hex: "6A89CC"))
                    
                    Text("Daily Tasks")
                        .font(.system(
                            size: ResponsiveLayout.fontSize(20),
                            weight: .semibold,
                            design: .rounded
                        ))
                        .foregroundColor(Color(hex: "333333"))
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: ResponsiveLayout.fontSize(22)))
                        .foregroundColor(Color(hex: "6A89CC"))
                        .contentTransition(.symbolEffect(.automatic))
                }
            }
            .padding(.horizontal, ResponsiveLayout.padding(20))
            .padding(.vertical, ResponsiveLayout.padding(16))
            .background(Color(hex: "F8F9FA"))
            
            if isExpanded {
                Divider()
                    .padding(.horizontal, ResponsiveLayout.padding(20))
                
                // Todo Input
                HStack(spacing: ResponsiveLayout.padding(12)) {
                    TextField("Add a new task...", text: $newTodoTitle)
                        .font(.system(
                            size: ResponsiveLayout.fontSize(16),
                            design: .rounded
                        ))
                        .padding(.horizontal, ResponsiveLayout.padding(16))
                        .padding(.vertical, ResponsiveLayout.padding(12))
                        .background(Color(hex: "F2F3F5"))
                        .cornerRadius(10)
                        .focused($isInputFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            addTodo()
                        }
                    
                    Button(action: addTodo) {
                        Image(systemName: "plus")
                            .font(.system(
                                size: ResponsiveLayout.fontSize(15),
                                weight: .semibold
                            ))
                            .foregroundColor(.white)
                            .frame(
                                width: ResponsiveLayout.isIPad ? 44 : 36,
                                height: ResponsiveLayout.isIPad ? 44 : 36
                            )
                            .background(
                                newTodoTitle.isEmpty ?
                                Color(hex: "6A89CC").opacity(0.5) :
                                Color(hex: "6A89CC")
                            )
                            .clipShape(Circle())
                    }
                    .disabled(newTodoTitle.isEmpty)
                }
                .padding(.horizontal, ResponsiveLayout.padding(20))
                .padding(.top, ResponsiveLayout.padding(16))
                .padding(.bottom, ResponsiveLayout.padding(12))
                
                // Empty state or Todo List
                if todoManager.items.isEmpty {
                    VStack(spacing: ResponsiveLayout.padding(8)) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: ResponsiveLayout.fontSize(36)))
                            .foregroundColor(Color(hex: "CCCCCC"))
                            .padding(.top, ResponsiveLayout.padding(16))
                        
                        Text("No tasks yet")
                            .font(.system(
                                size: ResponsiveLayout.fontSize(16),
                                weight: .medium,
                                design: .rounded
                            ))
                            .foregroundColor(Color(hex: "999999"))
                        
                        Text("Add a task to get started")
                            .font(.system(
                                size: ResponsiveLayout.fontSize(14),
                                design: .rounded
                            ))
                            .foregroundColor(Color(hex: "AAAAAA"))
                            .padding(.bottom, ResponsiveLayout.padding(16))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ResponsiveLayout.padding(20))
                    .transition(.opacity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: ResponsiveLayout.padding(8)) {
                            ForEach(todoManager.items) { item in
                                HStack(spacing: ResponsiveLayout.padding(16)) {
                                    Button(action: {
                                        withAnimation {
                                            todoManager.toggleTodo(item)
                                        }
                                    }) {
                                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: ResponsiveLayout.fontSize(22)))
                                            .foregroundColor(item.isCompleted ? Color(hex: "41B3A3") : Color(hex: "CCCCCC"))
                                            .contentTransition(.symbolEffect(.automatic))
                                    }
                                    
                                    Text(item.title)
                                        .font(.system(
                                            size: ResponsiveLayout.fontSize(16),
                                            design: .rounded
                                        ))
                                        .foregroundColor(item.isCompleted ? Color(hex: "AAAAAA") : Color(hex: "333333"))
                                        .strikethrough(item.isCompleted)
                                        .animation(.easeOut, value: item.isCompleted)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation {
                                            todoManager.removeTodo(item)
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: ResponsiveLayout.fontSize(14)))
                                            .foregroundColor(Color(hex: "E8505B").opacity(0.7))
                                            .frame(width: ResponsiveLayout.isIPad ? 40 : 30, height: ResponsiveLayout.isIPad ? 40 : 30)
                                            .contentShape(Rectangle())
                                    }
                                }
                                .padding(.horizontal, ResponsiveLayout.padding(20))
                                .padding(.vertical, ResponsiveLayout.padding(10))
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                                )
                                .padding(.horizontal, ResponsiveLayout.padding(20))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(.vertical, ResponsiveLayout.padding(12))
                    }
                    .frame(maxHeight: ResponsiveLayout.isIPad ? 350 : 250)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: ResponsiveLayout.isIPad ? 20 : 16)
                .stroke(Color(hex: "EEEEEE"), lineWidth: 1)
        )
    }
    
    private func addTodo() {
        if !newTodoTitle.isEmpty {
            withAnimation {
                todoManager.addTodo(newTodoTitle)
                newTodoTitle = ""
            }
            isInputFocused = false
        }
    }
}
