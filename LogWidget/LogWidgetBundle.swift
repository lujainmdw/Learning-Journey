//
//  LogWidgetBundle.swift
//  LogWidget
//
//  Created by Lujainah on 07/06/1448 AH.
//

import WidgetKit
import SwiftUI

@main
struct LogWidgetBundle: WidgetBundle {
    var body: some Widget {
        LogWidget()
        LogWidgetControl()
        LogWidgetLiveActivity()
    }
}
