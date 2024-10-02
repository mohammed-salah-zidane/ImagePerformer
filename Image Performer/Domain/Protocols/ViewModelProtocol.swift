//
//  ViewModelProtocol.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import Combine

protocol ViewModelProtocol: ObservableObject {
    var state: LoadingState { get }
    func start()
}
