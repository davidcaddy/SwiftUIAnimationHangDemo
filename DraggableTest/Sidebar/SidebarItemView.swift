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
        return selectedItem == item ? Color.yellow : Color.white
    }
    
    var body: some View {
        HStack {
            Text(item.title)
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
                    .foregroundStyle(.white)
                    .font(.title)
                Spacer(minLength: 0.0)
            }
            ForEach(item.innerItems.sorted(by: { $0.sortIndex < $1.sortIndex })) { innerItem in
                InnerItemView(item: innerItem, selectedItem: $selectedItem, targetedItem: $targetedItem)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 8.0)
                .fill(.cyan)
                .padding(1.0)
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
