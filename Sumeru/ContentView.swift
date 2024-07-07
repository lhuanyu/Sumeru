//
//  ContentView.swift
//  Sumeru
//
//  Created by LuoHuanyu on 2024/6/30.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Care.timestamp, order: .reverse, animation: .bouncy) private var items: [Care]
    
    @State var dates: [Date] = []
    
    @State var groupedItems: [Date: [Care]] = [:]
                
    @State private var addingItemType: CareType?

    var body: some View {
        NavigationSplitView {
            ZStack {
                if items.isEmpty {
                    EmptyRecordView()
                } else {
                    List {
                        Section(header: header(for: Calendar.current.startOfDay(for: Date()))) {
                            if let today = groupedItems[Calendar.current.startOfDay(for: Date())] {
                                ForEach(today) { item in
                                    NavigationLink {
                                        EditCareRecordView(care: item, editType: .edit)
                                    } label: {
                                        CareRecordView(care: item)
                                    }
                                }
                                .onDelete(perform: deleteItems)
                            } else {
                                Text("No records today")
                            }
                        }
                        ForEach(dates.filter { $0 != Calendar.current.startOfDay(for: Date()) }, id: \.self) { date in
                            Section(header: header(for: date)) {
                                ForEach(groupedItems[date]!) { item in
                                    NavigationLink {
                                        EditCareRecordView(care: item, editType: .edit)
                                    } label: {
                                        CareRecordView(care: item)
                                    }
                                }
                                .onDelete(perform: deleteItems)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                /// bottom floating panel for shortcuts of adding care records
                VStack {
                    Spacer()
                    VStack {
                        HStack {
                            Button {
                                addingItemType = .feeding
                            } label: {
                                Label("Feeding", systemImage: CareType.feeding.sfSymbol)
                            }
                            Spacer()
                            Button {
                                addingItemType = .diaper
                            } label: {
                                Label("Diaper", systemImage: CareType.diaper.sfSymbol)
                            }
                            Spacer()
                            Button {
                                addingItemType = .sleep
                            } label: {
                                Label("Sleep", systemImage: CareType.sleep.sfSymbol)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
                .buttonStyle(.bordered)
                .padding()
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
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
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: addItem) {
                        Label("chart", systemImage: "chart.bar")
                    }
                }
            }
            .navigationTitle("Care Records")
            .sheet(item: $addingItemType) { type in
                NavigationView {
                    EditCareRecordView(type: type)
                }
            }
        } detail: {
            Text("Select an item")
        }
        .onAppear() {
//#if DEBUG
//            if items.isEmpty {
//                let mockData = Care.mockData
//                for care in mockData {
//                    modelContext.insert(care)
//                }
//            }
//#endif
        }
        .onChange(of: items) { oldValue, newValue in
            ///put items into groups with dates
            groupedItems = Dictionary(grouping: items) { item in
                Calendar.current.startOfDay(for: item.timestamp)
            }
            dates = groupedItems.keys.sorted(by: >)
        }
    }
    
    @ViewBuilder
    func header(for date: Date) -> some View {
        let cares = groupedItems[date] ?? []
        HStack {
            if Calendar.current.isDateInToday(date) {
                Text("Today")
            } else if Calendar.current.isDateInYesterday(date) {
                Text("Yesterday")
            } else {
                Text(date, style: .date)
            }
            Spacer()
            Image(systemName: CareType.feeding.sfSymbol)
            Text(cares.reduce(0) { $0 + ($1.feed?.amount ?? 0) }.description + " ml")
            Image(systemName: CareType.diaper.sfSymbol)
            Text(cares.filter { $0.type == .diaper }.count.description)
        }
    }

    private func addItem() {
        withAnimation {
            addingItemType = .feeding
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Care.self, inMemory: true)
}
