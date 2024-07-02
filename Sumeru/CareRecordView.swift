//
//  CareRecordView.swift
//  Sumeru
//
//  Created by LuoHuanyu on 2024/6/30.
//

import SwiftUI
import SwiftData

struct CareRecordView: View {
    var care: Care
    
    var body: some View {
        HStack {
            Image(systemName: care.type.sfSymbol)
                .frame(width: 24, height: 24)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading) {
                Text(care.type.description)
                    .font(.title3)
                Text(care.detailDescription)
                    .font(.subheadline)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(care.timestamp, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                ///多少时间之前，只显示分钟和小时
                Text(care.timestamp.relative)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
            }
        }
    }
}

extension Date {
    var relative: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

#Preview {
    List {
        CareRecordView(care: .feed)
        CareRecordView(care: .diaper)
        CareRecordView(care: .sleep)
    }
    .modelContainer(Care.preview)
}

extension Care {
    
    static let feed = Care(
        timestamp: Date(), type: .feeding, feed: .init(type: .breastAndFormula, method: .bottle, breastAmount: 100, formulaAmount: 80)
    )
    
    static let diaper = Care(timestamp: Date(timeIntervalSinceNow: -1244), type: .diaper, diaper: .init(type: .wet, amount: .much)
    )
    
    static let sleep = Care(timestamp: Date(timeIntervalSinceNow: -3633), type: .sleep, duration: 1200)


    @MainActor
    static var preview: ModelContainer = {
        let schema = Schema([
            Care.self,
            Feed.self,
            Diaper.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            

            container.mainContext.insert(feed)
            container.mainContext.insert(diaper)
            container.mainContext.insert(sleep)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
