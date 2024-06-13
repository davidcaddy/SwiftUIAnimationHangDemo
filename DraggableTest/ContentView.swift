//
//  ContentView.swift
//  DraggableTest
//
//  Created by David Caddy on 24/3/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State var selectedItem: InnerSidebarItem?
    @State var targetedItem: DropTarget?

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedItem: $selectedItem, targetedItem: $targetedItem)
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
        } detail: {
            if let selectedItem {
                DetailView(item: selectedItem)
            }
            else {
                Text("Select an item")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SidebarItem.self, inMemory: true)
}
