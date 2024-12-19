//
//  StatusView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/28/24.
//

import SwiftUI

struct StatusView: View {
    let status: OrderStatus
    var body: some View {
        switch status {
        case .waiting:
            Text("Waiting")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color.orange) // Simplified for demonstration; replace with actual color conversion
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(Color.orange.opacity(0.12))
                )
                .shadow(color: Color.orange.opacity(0.5), radius: 3, x: 0, y: 1)
        case .accepted:
            Text("Accepted")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color.green) // Simplified for demonstration; replace with actual color conversion
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(Color.green.opacity(0.12))
                )
                .shadow(color: Color.green.opacity(0.5), radius: 3, x: 0, y: 1) // Replace with actual content
        case .canceled:
            Text("Canceled")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color.red) // Simplified for demonstration; replace with actual color conversion
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(Color.red.opacity(0.12))
                )
                
        case .done:
            Text("Done")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color.green) // Simplified for demonstration; replace with actual color conversion
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(Color.green.opacity(0.12))
                )
                .shadow(color: Color.green.opacity(0.5), radius: 3, x: 0, y: 1)
        }
    }
}

#Preview {
    StatusView(status: .done)
}
