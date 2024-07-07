//
//  EmptyRecordView.swift
//  Sumeru
//
//  Created by LuoHuanyu on 2024/7/7.
//

import SwiftUI

struct EmptyRecordView: View {
    var body: some View {
        VStack {
            Image(systemName: "balloon.2.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.secondary)
            Text("No records")
                .font(.title)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    EmptyRecordView()
}
