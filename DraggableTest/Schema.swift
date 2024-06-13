//
//  Item.swift
//  DraggableTest
//
//  Created by David Caddy on 24/3/2024.
//

import Foundation
import SwiftData

@Model
final class SidebarItem {
    var id: UUID
    var title: String
    var sortIndex: Int32
    
    @Relationship(inverse: \InnerSidebarItem.sidebarItem) var innerItems: [InnerSidebarItem]
    
    init(id: UUID = UUID(), title: String, sortIndex: Int32) {
        self.id = id
        self.title = title
        self.sortIndex = sortIndex
        self.innerItems = []
    }
}

@Model
final class InnerSidebarItem {
    var id: UUID
    var title: String
    var sortIndex: Int32
    var sidebarItem: SidebarItem?
    
    @Relationship(inverse: \DetailItem.innerSidebarItem) var detailsItems: [DetailItem]
    
    init(id: UUID = UUID(), title: String, sortIndex: Int32) {
        self.id = id
        self.title = title
        self.sortIndex = sortIndex
        self.detailsItems = []
    }
}

@Model
final class DetailItem {
    var id: UUID
    var title: String
    var sortIndex: Int32
    var innerSidebarItem: InnerSidebarItem?
    
    @Relationship(inverse: \InnerDetailItem.detailItem) var innerDetailItems: [InnerDetailItem]
    
    init(id: UUID = UUID(), title: String, sortIndex: Int32) {
        self.id = id
        self.title = title
        self.sortIndex = sortIndex
        self.innerDetailItems = []
    }
}

@Model
final class InnerDetailItem {
    var id: UUID
    var title: String
    var sortIndex: Int32
    var detailItem: DetailItem?
    
    init(id: UUID = UUID(), title: String, sortIndex: Int32) {
        self.id = id
        self.title = title
        self.sortIndex = sortIndex
    }
}
