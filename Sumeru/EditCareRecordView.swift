//
//  NewCareRecordView.swift
//  Sumeru
//
//  Created by LuoHuanyu on 2024/6/30.
//

import SwiftUI

struct EditCareRecordView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Environment(\.dismiss) private var dismiss
    
    enum EditType: String {
        case new
        case edit
    }
    
    @State var type: CareType = .feeding
        
    @State var care = Care(timestamp: Date(), type: .feeding)
    
    @State var feed = Feed(type: .breast, method: .breast, breastAmount: 0, formulaAmount: 0)
    
    @State var diaper = Diaper(type: .wet, amount: .normal)
    
    @State var enededAt: Date = Date()
    
    var editType: EditType = .new
    
    var body: some View {
        Form {
            Picker("Type", selection: $type) {
                ForEach(CareType.allCases) {
                    Text($0.description).tag($0)
                }
            }
            Section(header: Text("Time")) {
                DatePicker("Start Time", selection: $care.timestamp)
                DatePicker("End Time", selection: $enededAt)
                    .onChange(of: enededAt) { oldValue, newValue in
                        care.duration = enededAt.timeIntervalSince(care.timestamp)
                    }

            }
            switch type {
            case .feeding:
                Picker("Feed Method", selection: $feed.method) {
                    Text("Breast").tag(FeedMethod.breast)
                    Text("Bottle").tag(FeedMethod.bottle)
                }
                .pickerStyle(.inline)
                if feed.method == .breast {
                    Section(header: Text("Breast Feed")) {
                        HStack {
                            Text("Breast Amount")
                            Spacer()
                            TextField("Estimated Amount", value: $feed.breastAmount, formatter: numberFormatter)
                                .multilineTextAlignment(.trailing)
                            Text("ml")
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Section(header: Text("Bottle Feed")) {
                        HStack {
                            Text("Formula Amount")
                            Spacer()
                            TextField("Formula Amount", value: $feed.formulaAmount, formatter: numberFormatter)
                                .multilineTextAlignment(.trailing)
                            Text("ml")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Breast Amount")
                            Spacer()
                            TextField("Breast Amount", value: $feed.breastAmount, formatter: numberFormatter)
                                .multilineTextAlignment(.trailing)
                            Text("ml")
                                .foregroundColor(.secondary)
                        }

                    }
                }
            case .diaper:
                Picker("Diaper Type", selection: $diaper.type) {
                    ForEach(DiaperType.allCases, id: \.self) {
                        Text($0.description).tag($0)
                    }
                }
                if diaper.type == .wet || diaper.type == .mixed {
                    Picker("Volume", selection: $diaper.amount) {
                        ForEach(DiaperAmount.allCases, id: \.self) {
                            Text($0.description).tag($0)
                        }
                    }
                }
                if diaper.type == .dirty || diaper.type == .mixed {
                    Picker("Boop Color", selection: $diaper.color) {
                        ForEach(DiaperColor.allCases, id: \.self) {
                            Text($0.description).tag($0)
                        }
                    }
                    Picker("Boop Texture", selection: $diaper.color) {
                        ForEach(DiaperTexture.allCases, id: \.self) {
                            Text($0.description).tag($0)
                        }
                    }
                }
            default:
                EmptyView()
            }
            Section(header: Text("note")) {
                TextField("Write something", text: $care.note.toUnwrapped(defaultValue: ""),  axis: .vertical)
                    .lineLimit(5...10)
            }
            Section {
                Button("Save") {
                    save()
                    dismiss()
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if editType == .new {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                    dismiss()
                }
            }
        }
        .onAppear() {
            if editType == .edit {
                self.type = care.type
                switch type {
                case .feeding:
                    feed = care.feed ?? Feed(type: .breast, method: .breast, breastAmount: 0, formulaAmount: 0)
                case .diaper:
                    diaper = care.diaper ?? Diaper(type: .wet, amount: .normal)
                case .sleep:
                    break
                case .bath:
                    break
                case .other:
                    break
                }
            }
        }
    }
    
    ///localized title
    var title: String {
        switch editType {
        case .new:
            return NSLocalizedString("New Care Record", comment: "")
        case .edit:
            return NSLocalizedString("Edit Care Record", comment: "")
        }
    }
    
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
    
    func save() {
        care.type = type
        care.duration = enededAt.timeIntervalSince(care.timestamp)
        switch type {
        case .feeding:
            care.feed = feed
        case .diaper:
            care.diaper = diaper
        case .sleep:
            break
        case .bath:
            break
        case .other:
            break
        }
        modelContext.insert(care)
    }
}

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

#Preview {
    EditCareRecordView()
}
