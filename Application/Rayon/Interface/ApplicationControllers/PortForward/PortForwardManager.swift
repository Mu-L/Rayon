//
//  PortForwardView.swift
//  Rayon (macOS)
//
//  Created by Lakr Aream on 2022/3/10.
//

import RayonModule
import SwiftUI

struct PortForwardManager: View {
    @EnvironmentObject var store: RayonStore
    
    var tableItems: [RDPortForward] {
        store
            .portForwardGroup
            .forwards
            .filter {
                if searchText.count == 0 {
                    return true
                }
                if $0.name.lowercased().contains(searchText) {
                    return true
                }
                if $0.targetHost.lowercased().contains(searchText) {
                    return true
                }
                if String($0.targetPort).contains(searchText) {
                    return true
                }
                if String($0.bindPort).contains(searchText) {
                    return true
                }
                return false
            }
            .sorted(using: sortOrder)
    }

    @State var searchText: String = ""
    @State var openCreateSheet: Bool = false
    @State var selection: Set<RDPortForward.ID> = []
    @State var sortOrder: [KeyPathComparator<RDPortForward>] = [
        .init(\.name, order: SortOrder.forward),
    ]
    @State var editSelection: RDPortForward.ID? = nil
    var body: some View {
        Group {
            if tableItems.count > 0 {
                table
            } else {
                Text("No Port Forward Available")
                    .expended()
            }
        }
        .requiresFrame()
        .toolbar {
            ToolbarItem {
                Button {
                    removeButtonTapped()
                } label: {
                    Label("Remove", systemImage: "minus")
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(selection.count == 0)
            }
            ToolbarItem {
                Button {
                    editSelection = selection.first
                    openCreateSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .disabled(selection.count == 0)
            }
            ToolbarItem {
                Button {
                    duplicateButtonTapped()
                } label: {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
                .disabled(selection.count == 0)
            }
            ToolbarItem {
                Button {
                    openCreateSheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .keyboardShortcut(KeyboardShortcut(
                    .init(unicodeScalarLiteral: "n"),
                    modifiers: .command
                ))
            }
        }
        .background(sheetEnter.hidden())
        .searchable(text: $searchText)
        .navigationTitle("Port Forward - \(store.portForwardGroup.count) available")
    }
    
    var table: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name) { data in
                TextField("", text: $store.portForwardGroup[data.id].name)
            }
//            TableColumn("Auto", value: \.authenticAutomatically, comparator: BoolComparator()) { data in
//                Toggle("Auto", isOn: $store.identityGroup[data.id].authenticAutomatically)
//                    .labelsHidden()
//            }
//            .width(50)
//            TableColumn("Use Keys") { data in
//                Text(data.getKeyType())
//            }
//            TableColumn("Last Used", value: \.lastRecentUsed) { data in
//                if data.lastRecentUsed.timeIntervalSince1970 == 0 {
//                    Text("Never")
//                } else {
//                    Text(
//                        data
//                            .lastRecentUsed
//                            .formatted()
//                    )
//                }
//            }
//            TableColumn("Group", value: \.group) { data in
//                TextField("Default", text: $store.identityGroup[data.id].group)
//            }
//            TableColumn("Comment", value: \.comment) { data in
//                TextField("", text: $store.identityGroup[data.id].comment)
//            }
        } rows: {
            ForEach(tableItems) { item in
                TableRow(item)
            }
        }
    }
    
    var sheetEnter: some View {
        Group {}
    }
    
    func removeButtonTapped() { }
    
    func duplicateButtonTapped() { }
}
