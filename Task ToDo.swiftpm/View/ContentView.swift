import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Task.complete, ascending: true),
            NSSortDescriptor(keyPath: \Task.priorityNum, ascending: false)
        ],
        animation: .default
    )
    private var tasks: FetchedResults<Task>
    
    @State private var showNewTask: Bool = false
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(tasks.filter { searchText.isEmpty ? true : $0.name.contains(searchText)}) { task in 
                        TaskListRow(task: task)
                    } //: ForEach
                    .onDelete(perform: deleteTask)
                } //: List
                
                if tasks.count == 0 {
                    Image(systemName: "smiley.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                }
                
                if self.showNewTask {
                    BlankView()
                        .onTapGesture { self.showNewTask = false }
                    
                    NewTaskView(isShow: self.$showNewTask)
                        .transition(.move(edge: .bottom))
                        .animation(.default, value: self.showNewTask)
                }
                    
            } //: ZStack
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.showNewTask = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    } //: Button
                } //: Toolbar
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .foregroundColor(.blue)
                        .opacity(self.tasks.count == 0 ? 0.5 : 1)
                        .disabled(self.tasks.count == 0)
                } //: ToolbarItem
            }
        } //: NavigationView
        .searchable(text: self.$searchText)
    }
    
    // delete function
    private func deleteTask(index: IndexSet) -> Void {
        withAnimation {
            index.map { tasks[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError.localizedDescription), \(nsError.userInfo)")
            }
        }
    }
}
