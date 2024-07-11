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
    
    @State private var filterCareType: CareType?

    var body: some View {
        NavigationSplitView {
            ZStack {
                if items.isEmpty {
                    EmptyRecordView()
                } else {
                    List {
                        Section(header: header(for: Calendar.current.startOfDay(for: Date()))) {
                            let today = careRecord(for: Calendar.current.startOfDay(for: Date()))
                            if today.isEmpty {
                                Text("No records today")
                            } else {
                                ForEach(today) { item in
                                    NavigationLink {
                                        EditCareRecordView(care: item, editType: .edit)
                                    } label: {
                                        CareRecordView(care: item)
                                    }
                                }
                                .onDelete(perform: deleteItems)
                            }
                        }
                        ForEach(dates.filter { $0 != Calendar.current.startOfDay(for: Date()) }, id: \.self) { date in
                            Section(header: header(for: date)) {
                                ForEach(careRecord(for: date)) { item in
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
                        .foregroundColor(.accentColor)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .padding()
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Filter", selection: $filterCareType) {
                            HStack {
                                Image(systemName: "line.horizontal.3.decrease.circle")
                                Text("All")
                            }.tag(nil as CareType?)
                            ForEach(CareType.allCases, id: \.self) { type in
                                HStack {
                                    Image(systemName: type.sfSymbol)
                                    Text(type.description)
                                }.tag(type as CareType?)
                            }
                        }
                        .labelsHidden()
                    } label: {
                        Label("Filter", systemImage: filterCareType?.sfSymbol ?? "line.horizontal.3.decrease.circle")
                    }
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
            .navigationTitle(filterCareType?.description ?? NSLocalizedString("Care Records", comment: ""))
            .sheet(item: $addingItemType) { type in
                NavigationView {
                    EditCareRecordView(type: type)
                }
            }
        } detail: {
            Text("Select an item")
        }
        .onAppear() {
#if DEBUG
            if items.isEmpty {
                let mockData = Care.mockData
                for care in mockData {
                    modelContext.insert(care)
                }
            }
#endif
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
        let cares = careRecord(for: date)
        HStack {
            if Calendar.current.isDateInToday(date) {
                Text("Today")
            } else if Calendar.current.isDateInYesterday(date) {
                Text("Yesterday")
            } else {
                Text(date, style: .date)
            }
            Spacer()
            if filterCareType == .feeding || filterCareType == nil {
                Image(systemName: CareType.feeding.sfSymbol)
                Text(cares.reduce(0) { $0 + ($1.feed?.amount ?? 0) }.description + " ml")
            }
            if filterCareType == .diaper || filterCareType == nil {
                Image(systemName: CareType.diaper.sfSymbol)
                Text(cares.filter { $0.type == .diaper }.count.description)
            }
            if filterCareType == .sleep || filterCareType == nil {
                Image(systemName: CareType.sleep.sfSymbol)
                let seconds = cares.reduce(0) { $0 + $1.duration }
                ///持续时间seconds为秒，转换为标准格式，最多显示小时
                Text(Duration(secondsComponent: Int64(seconds), attosecondsComponent: 0).formatted())
            }
        }
    }
    
    func careRecord(for date: Date) -> [Care] {
        return groupedItems[date]?.filter({ 
            filterCareType == nil || $0.type == filterCareType
        }) ?? []
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
