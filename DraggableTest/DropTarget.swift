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
    static let innerSidebarItem = UTType(exportedAs: "com.draggable.test.innersidebaritem")
}

struct SidebarItemTransferable: Codable, Transferable {
    var modelID: PersistentIdentifier
    
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .sidebarItem)
    }
}

struct InnerSidebarItemTransferable: Codable, Transferable {
    var modelID: PersistentIdentifier
    
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .innerSidebarItem)
    }
}

enum DropTarget {
    case sidebarItem(_ item: SidebarItem)
    case innerSidebarItem(_ item: InnerSidebarItem)
}
