//
//  SidebarView.swift
//  DraggableTest
//
//  Created by David Caddy on 13/6/2024.
//

import SwiftUI
import SwiftData

struct SidebarView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    static var fetchDescriptor: FetchDescriptor<SidebarItem> {
        var descriptor = FetchDescriptor<SidebarItem>(sortBy: [SortDescriptor(\SidebarItem.sortIndex)])
        descriptor.propertiesToFetch = [\.sortIndex, \.title]
        descriptor.relationshipKeyPathsForPrefetching = [\.innerItems]
        return descriptor
    }
    @Query(fetchDescriptor, animation: .default) private var items: [SidebarItem]
    
    @Binding var selectedItem: InnerSidebarItem?
    @Binding var targetedItem: DropTarget?
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(items) { item in
                    SidebarItemView(item: item, selectedItem: $selectedItem, targetedItem: $targetedItem)
                        .draggable(SidebarItemTransferable(modelID: item.id))
                        .dropDestination(for: SidebarItemTransferable.self) { items, location in
                            if let id = items.last?.modelID {
                                updateSortIndex(forItemWithID: id, target: item)
                            }
                            return true
                        } isTargeted: { isTargeted in
                            targetedItem = isTargeted ? .sidebarItem(item) : nil
                        }
                }
                .onDelete(perform: deleteItems)
            }
            .padding()
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
    }
}

extension SidebarView {
    
    private func addItem() {
        withAnimation {
            let newItem = SidebarItem(title: "Item \(items.count)", sortIndex: Int32(items.count))
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func updateSortIndex(forItemWithID id: PersistentIdentifier, target: SidebarItem) {
        if let droppedItem = modelContext.model(for: id) as? SidebarItem {
            guard let destination = items.firstIndex(of: target) else {
                return
            }
            
            var newIndex: Int32 = 10000
            var reIndexRequired = false
            if items.count > 0 {
                if destination == 0 {
                    let firstItem = items[0]
                    newIndex = Int32(firstItem.sortIndex) / 2
                    reIndexRequired = newIndex == firstItem.sortIndex
                }
                else if destination >= items.count {
                    if let lastItem = items.last {
                        if (Int32.max - lastItem.sortIndex) > 500 {
                            newIndex = Int32(lastItem.sortIndex) + 500
                        }
                        else {
                            newIndex = Int32.max
                            reIndexRequired = true
                        }
                    }
                }
                else {
                    let leadingSortIndex = items[destination - 1].sortIndex
                    let trailingSortIndex = items[destination].sortIndex
                    
                    newIndex = Int32(leadingSortIndex + trailingSortIndex) / 2
                    reIndexRequired = (newIndex == leadingSortIndex) || (newIndex == trailingSortIndex)
                }
            }
            
            if reIndexRequired {
                var index: Int32 = 10000
                for item in items {
                    item.sortIndex = Int32(index)
                    index += 1000
                }
            }
            else {
                droppedItem.sortIndex = newIndex
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SidebarItem.self, configurations: config)

    let item = SidebarItem(title: "Hello", sortIndex: 0)
    container.mainContext.insert(item)
    
    return SidebarView(selectedItem: .constant(nil), targetedItem: .constant(nil))
}
