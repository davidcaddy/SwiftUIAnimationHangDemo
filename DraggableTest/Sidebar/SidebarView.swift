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
    
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    static var fetchDescriptor: FetchDescriptor<SidebarItem> {
        var descriptor = FetchDescriptor<SidebarItem>(sortBy: [SortDescriptor(\SidebarItem.sortIndex)])
        descriptor.propertiesToFetch = [\.sortIndex, \.title]
        descriptor.relationshipKeyPathsForPrefetching = [\.innerItems]
        return descriptor
    }
    @Query(fetchDescriptor, animation: .default) private var items: [SidebarItem]
    
    @Binding var selectedItem: InnerSidebarItem?
    @Binding var targetedItem: DropTarget?
    
    @State var enableRandomReorder = false
    
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
            }
            .padding()
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    enableRandomReorder.toggle()
                    print("Test \(enableRandomReorder ? "started." : "stopped.")")
                }, label: {
                    Label("Run test", systemImage: enableRandomReorder ? "ladybug.fill" : "ladybug")
                })
            }
        }
        .onReceive(timer) { time in
            if enableRandomReorder {
                randomReorder()
            }
        }
        .onAppear {
            if items.isEmpty {
                populateData()
            }
        }
    }
}

extension SidebarView {
    
    private func makeRandomSelection() {
        guard items.count > 0 else {
            return
        }
        let randomIndex = Int.random(in: 0..<items.count)
        let item = items[randomIndex]
        
        selectedItem = item.innerItems.first
    }
    
    // Randomly reorder list every second
    private func randomReorder() {
        guard items.count > 1 else {
            return
        }
        if selectedItem == nil {
            makeRandomSelection()
            return
        }
        
        let randomIndex1 = Int.random(in: 0..<min(3, items.count))
        let randomIndex2 = Int.random(in: 0..<items.count)
        guard randomIndex1 != randomIndex2 else {
            return
        }
        
        let moveItem = items[randomIndex1]
        let targetItem = items[randomIndex2]
        
        print("Moving sidebar item at index \(randomIndex1) to index \(randomIndex2)")
        updateSortIndex(forItemWithID: moveItem.persistentModelID, target: targetItem)
    }
    
    private func populateData() {
        for i in 0..<25 {
            let sidebarItem = SidebarItem(title: "Sidebar Item \(i)", sortIndex: Int32(10000 + (i * 500)))
            modelContext.insert(sidebarItem)
            
            let randCount = Int.random(in: 1..<5)
            for j in 0..<randCount {
                let innerSidebarItem = InnerSidebarItem(title: "Inner Sidebar Item \(j)", sortIndex: Int32(10000 + (j * 500)))
                modelContext.insert(innerSidebarItem)
                innerSidebarItem.sidebarItem = sidebarItem
                
                for k in 0..<10 {
                    let detailItem = DetailItem(title: "Detail Item \(k)", sortIndex: Int32(10000 + (k * 500)))
                    modelContext.insert(detailItem)
                    detailItem.innerSidebarItem = innerSidebarItem
                    
                    let innerDetailItem = InnerDetailItem(title: "Inner Detail Item", sortIndex: 10000)
                    modelContext.insert(innerDetailItem)
                    innerDetailItem.detailItem = detailItem
                }
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

    let item = SidebarItem(title: "Sidebar Item", sortIndex: 0)
    container.mainContext.insert(item)
    
    return SidebarView(selectedItem: .constant(nil), targetedItem: .constant(nil))
}
