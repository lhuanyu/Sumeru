//
//  FeedChartView.swift
//  Sumeru
//
//  Created by LuoHuanyu on 2024/8/30.
//

import SwiftUI
import Charts

struct FeedChartView: View {
    
    @Binding var feedingItems: [Care]
    
    @Binding var feedingGroups: [Care: [Care]]
    
    @Binding var timeRange: TimeRange

    @Binding var showAverageLine: Bool
    
    @Binding var scrollPosition: Date
    
    private func totalAmount(for care: Care) -> Int {
        if let group = feedingGroups[care], timeRange == .last7Days {
            return group.reduce(0) { partialResult, care in
                partialResult + (care.feed?.amount ?? 0)
            }
        }
        return care.feed?.amount ?? 0
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
    
    func annotationColor(for care: Care) -> Color {
        if timeRange == .last7Days && feedingGroups[care] == nil {
            return .clear
        }
        return .secondary
    }
    
    var body: some View {
        Chart {
            ForEach(feedingItems, id: \.timestamp) { item in
                let islast7Days = timeRange == .last7Days
                let amount = item.feed?.amount ?? 0
                let totalAmount = totalAmount(for: item)
                
                
                BarMark(
                    x: .value("Time", item.timestamp, unit: islast7Days ? .day : .hour),
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
        .chartXVisibleDomain(length: timeRange == .last7Days ? 3600 * 24 * 7 : 3600 * 24 * 1)
        .chartScrollTargetBehavior(.valueAligned(unit: 1))
        .chartScrollPosition(x: $scrollPosition)
        .chartXAxis {
            switch timeRange {
            case .last7Days:
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
                format: Decimal.FormatStyle.number
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
    }
}

#Preview {
    FeedChartView(feedingItems: .constant([]), feedingGroups: .constant([:]), timeRange: .constant(.last7Days), showAverageLine: .constant(true), scrollPosition: .constant(Date()))
}
