//
//  ChartView.swift
//  Sumeru
//
//  Created by LuoHuanyu on 2024/8/17.
//

import SwiftUI
import Charts
import SwiftData

enum TimeRange {
    case last7Days
    case last24Hours
}

struct TimeRangePicker: View {
    
    @Binding var value: TimeRange

    var body: some View {
        Picker(selection: $value.animation(.easeInOut), label: EmptyView()) {
            Text("7 Days").tag(TimeRange.last7Days)
            Text("24 Hours").tag(TimeRange.last24Hours)
        }
        .pickerStyle(.segmented)
    }
}


struct ChartView: View {
    @Environment(\.modelContext) private var modelContext
    
    var items: [Care] = []
    
    @State var feedingItems: [Care] = []
    
    @State var diaperItems: [Care] = []
    
    @State var scrollPosition: Date = Date()
    
    @State var showAverageLine = false
    
    @State var timeRange = TimeRange.last7Days
    
    var scrollPositionEnd: Date {
        if timeRange == .last7Days {
            return scrollPosition.addingTimeInterval(3600 * 24 * 7)
        } else {
            return scrollPosition.addingTimeInterval(3600 * 24)
        }
    }
    
    var scrollPositionString: String {
        scrollPosition.formatted(.dateTime.month().day())
    }
    
    var scrollPositionEndString: String {
        scrollPositionEnd.formatted(.dateTime.month().day())
    }
    
    func averageAmount() -> Int {
        if timeRange == .last7Days {
            return feedingGroups.reduce(0) { partialResult, group in
                partialResult + group.value.reduce(0) { partialResult, care in
                    partialResult + (care.feed?.amount ?? 0)
                }
            } / feedingGroups.count
        } else {
            let total = feedingItems.reduce(0) { partialResult, care in
                partialResult + (care.feed?.amount ?? 0)
            }
            return total / feedingItems.count
        }
    }
    
    var displayTimeRange: ClosedRange<Date> {
        switch timeRange {
        case .last7Days:
            return scrollPosition.startOfDay...scrollPositionEnd.endOfDay
        case .last24Hours:
            return scrollPosition...scrollPositionEnd
        }
    }
    
    var body: some View {
        List {
            Section {
                TimeRangePicker(value: $timeRange)
                VStack(alignment: .leading) {
                    Text("Feeding")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("\(feedingAmountInPeriod(in: displayTimeRange), format: .number) ml")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text("\(scrollPositionString) – \(scrollPositionEndString)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    
                    FeedChartView(
                        feedingItems: $feedingItems,
                        feedingGroups: $feedingGroups,
                        timeRange: $timeRange,
                        showAverageLine: $showAverageLine,
                        scrollPosition: $scrollPosition
                    )
                    .frame(height: 240)
                }
            }
            .listRowSeparator(.hidden)
            
            Section("Options") {
                Toggle("Show Daily Average", isOn: $showAverageLine)
            }
            
        }
        .listStyle(.plain)
        .onAppear() {
            processData()
        }
        
    }
    
    @State private var feedingGroups: [Care: [Care]] = [:]
    
    private func totalAmount(for care: Care) -> Int {
        if let group = feedingGroups[care], timeRange == .last7Days {
            return group.reduce(0) { partialResult, care in
                partialResult + (care.feed?.amount ?? 0)
            }
        }
        return care.feed?.amount ?? 0
    }
    
    func processData() {
        let feedingItems = items.filter { $0.type == .feeding }
        let diaperItems = items.filter { $0.type == .diaper }
        var group: [Care] = []
        for item in feedingItems {
            if let _ = item.feed  {
                if let lastItem = group.last {
                    if !Calendar.current.isDate(lastItem.timestamp, inSameDayAs: item.timestamp) {
                        feedingGroups[lastItem] = group
                        group = []
                    }
                }
            }
            group.append(item)
        }

    
        self.feedingItems = feedingItems
        self.diaperItems = diaperItems
        if !group.isEmpty {
            feedingGroups[group.last!] = group
        }
        
        if let lastDate = feedingItems.first?.timestamp {
            // get the end time of lastDate
            let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: lastDate)!
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: endOfDay)!
            scrollPosition = weekAgo
        }
        
        print(scrollPosition)
    }
    
    func feedingAmountInPeriod(in range: ClosedRange<Date>) -> Int {
        if timeRange == .last24Hours {
            return feedingItems.filter { range.contains($0.timestamp) }.reduce(0) { $0 + ( $1.feed?.amount ?? 0) }
        } else {
            return feedingGroups.keys.filter { range.contains($0.timestamp) }.reduce(0) { $0 + totalAmount(for:$1) }
        }
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
}

#Preview {
    ChartView()
        .modelContainer(for: Care.self, inMemory: true)
}
