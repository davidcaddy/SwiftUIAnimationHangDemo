//
//  DetailView.swift
//  DraggableTest
//
//  Created by David Caddy on 13/6/2024.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    let item: InnerSidebarItem
    
    static var fetchDescriptor: FetchDescriptor<DetailItem> {
        var descriptor = FetchDescriptor<DetailItem>(sortBy: [SortDescriptor(\DetailItem.sortIndex)])
        descriptor.propertiesToFetch = [\.sortIndex, \.title]
        descriptor.relationshipKeyPathsForPrefetching = [\.innerDetailItems]
        return descriptor
    }
    @Query(fetchDescriptor) var detailItems: [DetailItem]
    
    init(item: InnerSidebarItem) {
        self.item = item
        
        let id = item.persistentModelID
        let predicate = #Predicate<DetailItem> { detailItem in
            detailItem.innerSidebarItem?.persistentModelID == id
        }
        _detailItems = Query(filter: predicate, sort: \.sortIndex, animation: .default)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(detailItems) { detailItem in
                    Text(detailItem.title)
                }
                
                Button("Add", systemImage: "plus") {
                    addItem()
                }
            }
        }
    }
}

extension DetailView {
    
    private func addItem() {
        let innerItem = DetailItem(title: "Detail \(item.detailsItems.count)", sortIndex: 0)
        innerItem.innerSidebarItem = item
        
        modelContext.insert(innerItem)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SidebarItem.self, configurations: config)

    let item = InnerSidebarItem(title: "Detail Item", sortIndex: 0)
    container.mainContext.insert(item)
    
    return DetailView(item: item)
}
