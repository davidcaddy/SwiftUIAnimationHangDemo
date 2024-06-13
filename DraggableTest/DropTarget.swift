//
//  DropTarget.swift
//  DraggableTest
//
//  Created by David Caddy on 13/6/2024.
//

import Foundation
import UniformTypeIdentifiers
import CoreTransferable
import SwiftData

extension UTType {
    static let sidebarItem = UTType(exportedAs: "com.draggable.test.sidebaritem")
}

struct SidebarItemTransferable: Codable, Transferable {
    var modelID: PersistentIdentifier
    
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .sidebarItem)
    }
}

enum DropTarget {
    case sidebarItem(_ item: SidebarItem)
    case innerSidebarItem(_ item: InnerSidebarItem)
}
