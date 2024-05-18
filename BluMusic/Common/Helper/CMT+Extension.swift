//
//  CMT+Extension.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import Foundation
import AVKit

extension CMTime {
    func convertToString() -> String {
        guard !CMTimeGetSeconds(self).isNaN
        else { return "" }

        let totalSeconds = Int(CMTimeGetSeconds(self))
        return String(
            format: "%02d:%02d",
            totalSeconds / 60,
            totalSeconds % 60
        )
    }
}
