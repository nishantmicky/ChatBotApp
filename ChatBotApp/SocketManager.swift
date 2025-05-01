//
//  SocketManager.swift
//  ChatBotApp
//
//  Created by Nishant Kumar on 01/05/25.
//

import Foundation

protocol SocketManagerDelegate: AnyObject {
    func didReceiveMessage(_ message: String)
}

class SocketManager {
    static let shared = SocketManager()
    weak var delegate: SocketManagerDelegate?

    private var webSocketTask: URLSessionWebSocketTask?

    func connect() {
        guard let url = URL(string: "wss://s14572.blr1.piesocket.com/v3/1?api_key=ddi6BaZ68o30yx2W6alIsJKFiPIk2iz3jl8amNwa") else { return }
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        listen()
    }

    private func listen() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(.string(let message)):
                    DispatchQueue.main.async {
                        self?.delegate?.didReceiveMessage(message)
                    }
                self?.listen()
            case .success(.data(_)):
                // no-op
            case .success(_):
                // no-op
            case .failure(let error):
                print("Socket error: \(error)")
            }
        }
    }

    func send(message: String) {
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print("Send error: \(error)")
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}

