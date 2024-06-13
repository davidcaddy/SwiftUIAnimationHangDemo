//
//  ItemView.swift
//  DraggableTest
//
//  Created by David Caddy on 12/6/2024.
//

import SwiftUI
import SwiftData

struct InnerItemView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var item: InnerSidebarItem
    @Binding var selectedItem: InnerSidebarItem?
    @Binding var targetedItem: DropTarget?
    
    private var fillColor: Color {
        return selectedItem == item ? Color.orange : Color.indigo
    }
    
    var body: some View {
        HStack {
            Text(item.title)
                .foregroundStyle(.white)
            Spacer(minLength: 0.0)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 8.0)
                .fill(fillColor)
                .padding(1.0)
        }
        .onTapGesture {
            selectedItem = item
        }
    }
}

struct SidebarItemView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var item: SidebarItem
    @Binding var selectedItem: InnerSidebarItem?
    @Binding var targetedItem: DropTarget?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(item.title)
                Spacer()
                Button("", systemImage: "plus") {
                    addItem()
                }
            }
            ForEach(item.innerItems.sorted(by: { $0.sortIndex < $1.sortIndex })) { innerItem in
                InnerItemView(item: innerItem, selectedItem: $selectedItem, targetedItem: $targetedItem)
                    .draggable(InnerSidebarItemTransferable(modelID: innerItem.id))
                    .dropDestination(for: InnerSidebarItemTransferable.self) { items, location in
                        if let id = items.last?.modelID {
                            updateSortIndex(forItemWithID: id, target: innerItem)
                        }
                        return true
                    } isTargeted: { isTargeted in
                        targetedItem = isTargeted ? .sidebarItem(item) : nil
                    }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 8.0)
                .fill(Color.yellow)
                .padding(1.0)
        }
    }
}

extension SidebarItemView {
    
    private func addItem() {
        let innerItem = InnerSidebarItem(title: "Inner \(item.innerItems.count)", sortIndex: 0)
        innerItem.sidebarItem = item
        
        modelContext.insert(innerItem)
    }
    
    private func updateSortIndex(forItemWithID id: PersistentIdentifier, target: InnerSidebarItem) {
        if let droppedItem = modelContext.model(for: id) as? SidebarItem {
            
            let innerItems = item.innerItems
            
            guard let destination = innerItems.firstIndex(of: target) else {
                return
            }
            
            var newIndex: Int32 = 10000
            var reIndexRequired = false
            if innerItems.count > 0 {
                if destination == 0 {
                    let firstItem = innerItems[0]
                    newIndex = Int32(firstItem.sortIndex) / 2
                    reIndexRequired = newIndex == firstItem.sortIndex
                }
                else if destination >= innerItems.count {
                    if let lastItem = innerItems.last {
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
                    let leadingSortIndex = innerItems[destination - 1].sortIndex
                    let trailingSortIndex = innerItems[destination].sortIndex
                    
                    newIndex = Int32(leadingSortIndex + trailingSortIndex) / 2
                    reIndexRequired = (newIndex == leadingSortIndex) || (newIndex == trailingSortIndex)
                }
            }
            
            if reIndexRequired {
                var index: Int32 = 10000
                for item in innerItems {
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

    let item = SidebarItem(title: "Sidebar Item", sortIndex: 0)
    container.mainContext.insert(item)
    let innerItem1 = InnerSidebarItem(title: "Test", sortIndex: 0)
    innerItem1.sidebarItem = item
    container.mainContext.insert(innerItem1)
    let innerItem2 = InnerSidebarItem(title: "Test 2", sortIndex: 1)
    innerItem2.sidebarItem = item
    container.mainContext.insert(innerItem2)
    
    return SidebarItemView(item: item, selectedItem: .constant(nil), targetedItem: .constant(nil))
        .modelContainer(container)
}
