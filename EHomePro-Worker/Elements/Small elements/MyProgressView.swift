//
//  MyProgressView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import SwiftUI

struct GaugeProgressStyle: ProgressViewStyle {
    var strokeColor: Color
    var strokeWidth: CGFloat
    var rotation: Double  // This is the rotation angle

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0

        return ZStack {
            Circle()
                .trim(from: 0, to: fractionCompleted)
                .stroke(strokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(rotation - 90))  // Adjust rotation effect here
        }
    }
}
struct MyProgressView: View {
    @State private var progress = 0.2
    @State private var rotation = 0.0  // State for rotation

    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()  // Timer to update rotation

    var body: some View {
        ProgressView(value: progress, total: 1.0)
            
            .progressViewStyle(GaugeProgressStyle(strokeColor: .blue, strokeWidth: 5, rotation: rotation))
            .frame(width: 250, height: 250)
            .contentShape(Rectangle())
            .onReceive(timer) { _ in
                withAnimation {
                    rotation += 3  // Increase rotation
                    if rotation > 360 {
                        rotation = 0  // Reset rotation to avoid overflow
                    }
                }
            }
            .onTapGesture {
                if progress < 1.0 {
                    withAnimation {
                        progress += 0.2
                    }
                }else{
                    progress = 0.2
                }
            }
    }
}



