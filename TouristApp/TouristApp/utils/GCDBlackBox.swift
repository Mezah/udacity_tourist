//
//  GCDBlackBox.swift
//  TouristApp
//
//  Created by Hazem on 5/9/19.
//  Copyright © 2019 Hazem. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
