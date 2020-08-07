//
//  NotSetUpMedium.swift
//  Timetables
//
//  Created by JiaChen(: on 6/7/20.
//  Copyright © 2020 SST Inc. All rights reserved.
//

import Foundation
import WidgetKit
import SwiftUI

extension NotSetUpItem {
    struct Medium: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                VStack {
                    HStack(spacing: 8) {
                        Components.ImageView(imageName: "gearshape", isMedium: false)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Localized.SetUp.Title.m)
                                .font(
                                    .system(
                                        size: 20,
                                        weight: .bold,
                                        design: .default
                                    )
                                )
                            Text(Localized.SetUp.description)
                                .font(
                                    .system(
                                        size: 12,
                                        weight: .regular,
                                        design: .default
                                    )
                                )
                        }
                    }
                }
                .padding()
            }

        }
    }
}
