import SwiftUI
import UIRouting

struct TodoListView: View {
    @Environment(.router(AppRoute.self)) private var router
    @Environment(.sheet(AppSheet.self)) private var sheetPresenter
    @Environment(.alert(AppAlert.self, context: .navigation)) private var alertPresenter
    @Environment(.customHeightSheet(AppCustomHeightSheet.self)) private var customHeightSheetPresenter
    @Environment(.fullScreenCover(AppFullScreenCover.self)) private var fullScreenCoverPresenter
    @Environment(.tab(AppTab.self)) private var tabPresenter

    @State private var todos = Todo.samples

    var body: some View {
        List {
            ForEach(todos) { todo in
                TodoRow(todo: todo) {
                    toggleTodo(todo)
                }
                .onTapGesture {
                    router.navigate(to: .todoDetail(todo: todo))
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation {
                            deleteTodo(todo)
                        }
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Todos")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        sheetPresenter.present(.addTodo)
                    } label: {
                        Label("通常の追加", systemImage: "plus")
                    }

                    Button {
                        customHeightSheetPresenter.present(.quickAdd)
                    } label: {
                        Label("クイック追加", systemImage: "bolt.fill")
                    }

                    Button {
                        fullScreenCoverPresenter.present(.photoCapture)
                    } label: {
                        Label("写真を撮影", systemImage: "camera.fill")
                    }

                    Divider()

                    Button(role: .destructive) {
                        alertPresenter.present(.deleteConfirmation(todoTitle: "すべてのTodo") {
                            withAnimation {
                                deleteAllTodos()
                            }
                        })
                    } label: {
                        Label("すべて削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    tabPresenter?.select(.settings)
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }

    private func toggleTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
        }
    }

    private func deleteTodo(_ todo: Todo) {
        todos.removeAll { $0.id == todo.id }
    }

    private func deleteAllTodos() {
        todos.removeAll()
    }
}

#Preview {
    @Previewable @State var tabPresenter = TabPresenter<AppTab>(initialTab: .todoList)
    TabRouting(tabPresenter: tabPresenter, tabs: [AppTab.todoList, AppTab.settings])
}
