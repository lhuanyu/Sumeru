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
    case last10Days
    case last24Hours
}

struct TimeRangePicker: View {
    
    @Binding var value: TimeRange

    var body: some View {
        Picker(selection: $value.animation(.easeInOut), label: EmptyView()) {
            Text("10 Days").tag(TimeRange.last10Days)
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
    
    @State var timeRange = TimeRange.last10Days
    
    let yFormat = Decimal.FormatStyle.number
    
    
    func annotationColor(for care: Care) -> Color {
        if timeRange == .last10Days && feedingGroups[care] == nil {
            return .clear
        }
        return .secondary
    }
    
    func averageAmount() -> Int {
        if timeRange == .last10Days {
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
    
    
    var body: some View {
        List {
            Section {
                TimeRangePicker(value: $timeRange)
                HStack {
                    Text("Feeding")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("ml")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
                Chart {
                    ForEach(feedingItems, id: \.timestamp) { item in
                        let isLast10Days = timeRange == .last10Days
                        let amount = item.feed?.amount ?? 0
                        let totalAmount = totalAmount(for: item)
 
                        
                        BarMark(
                            x: .value("Time", item.timestamp, unit: isLast10Days ? .day : .hour),
                            y: .value("Volume", amount)
                        )
                        .annotation(position: .top, alignment: .center) {
                            Text("\(totalAmount, format:.number.precision(.fractionLength(0)))")
                                .font(.caption2)
                                .foregroundColor(annotationColor(for: item))
                        }
                    }
                    .foregroundStyle(showAverageLine ? .gray.opacity(0.5) : .blue)
                    
                    if showAverageLine {
                        let average = averageAmount()
                        RuleMark(
                            y: .value("Average", average)
                        )
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(
                            position: .top,
                            alignment: .leading,
                            overflowResolution: AnnotationOverflowResolution(x: .fit(to: .plot), y: .fit)) {
                                Text("Average: \(average, format: .number)")
                                    .font(.body.bold())
                                    .foregroundStyle(.blue)
                            }
                    }
                    
                    
                    
                }
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: timeRange == .last10Days ? 3600 * 24 * min(7, feedingGroups.count) : 3600 * 24 * 1)
//                .chartScrollTargetBehavior(
//                    .valueAligned(
//                        matching: .init(hour: 0),
//                        majorAlignment: .matching(.init(day: 1))))
                .chartScrollPosition(x: $scrollPosition)
                .chartXAxis {
                    switch timeRange {
                    case .last10Days:
                        AxisMarks(values: .stride(by: .day, count: 1)) {
                            AxisTick()
                            AxisGridLine()
                            AxisValueLabel(
                                format: .dateTime.month().day(),
                                collisionResolution: .greedy
                            )
                        }
                    case .last24Hours:
                        AxisMarks(values: .stride(by: .hour, count: 4)) {
                            AxisTick()
                            AxisGridLine()
                            AxisValueLabel(
                                format: .dateTime.hour(),
                                collisionResolution: .greedy
                            )
                            
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(
                        format: yFormat
                    )
                    if showAverageLine {
                        let average = averageAmount()
                        AxisMarks(position: .trailing, values: [average]) {
                            AxisValueLabel(collisionResolution: .greedy) {
                                Text("\(average)")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
                .frame(height: 240)
                
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
        if let group = feedingGroups[care], timeRange == .last10Days {
            return group.reduce(0) { partialResult, care in
                partialResult + (care.feed?.amount ?? 0)
            }
        }
        return care.feed?.amount ?? 0
    }
    
    func processData() {
        feedingItems = items.filter { $0.type == .feeding }
        diaperItems = items.filter { $0.type == .diaper }
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
        if !group.isEmpty {
            feedingGroups[group.last!] = group
        }
    }
}

#Preview {
    ChartView()
        .modelContainer(for: Care.self, inMemory: true)
}
