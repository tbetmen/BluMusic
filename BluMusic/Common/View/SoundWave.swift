//
//  SoundWave.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import SwiftUI

struct SoundWave: View {

    @State private var drawingHeight = true

    var animation: Animation {
        return .linear(duration: 0.5).repeatForever()
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                bar(low: 0.4)
                    .animation(animation.speed(1.5), value: drawingHeight)
                bar(low: 0.3)
                    .animation(animation.speed(1.2), value: drawingHeight)
                bar(low: 0.5)
                    .animation(animation.speed(1.0), value: drawingHeight)
                bar(low: 0.3)
                    .animation(animation.speed(1.7), value: drawingHeight)
                bar(low: 0.5)
                    .animation(animation.speed(1.0), value: drawingHeight)
            }
            .onAppear{
                drawingHeight.toggle()
            }
        }
        .frame(width: 32)
    }

    func bar(low: CGFloat = 0.0, high: CGFloat = 1.0) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .frame(height: (drawingHeight ? high : low) * 32)
    }
}

#Preview {
    SoundWave()
}
