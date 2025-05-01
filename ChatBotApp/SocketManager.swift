//
//  SocketManager.swift
//  ChatBotApp
//
//  Created by Nishant Kumar on 01/05/25.
//

import Foundation

protocol SocketManagerDelegate: AnyObject {
    func didReceiveMessage(_ message: String)
    func didReceiveSocketError(_ error: String)
}

class SocketManager {
    static let shared = SocketManager()
    weak var delegate: SocketManagerDelegate?

    private var webSocketTask: URLSessionWebSocketTask?
    var isConnected: Bool {
        return webSocketTask?.state == .running
    }

    public func connect() {
        guard let url = URL(string: PIE_SOCKET_URL) else { return }
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        listen()
    }

    private func listen() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(.string(let message)):
                print("Socket success of type string: \(message)")
                DispatchQueue.main.async {
                    self?.delegate?.didReceiveMessage(message)
                }
                self?.listen()
            case .success(.data(let data)):
                print("Socket success of type data: \(data)")
            case .success(let data):
                print("Socket success: \(data)")
            case .failure(let error):
                print("Socket error: \(error)")
                DispatchQueue.main.async {
                    self?.delegate?.didReceiveSocketError("Socket error: \(error.localizedDescription)")
                }
            }
        }
    }

    func send(message: String) {
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print("Send error: \(error)")
                DispatchQueue.main.async {
                    self.delegate?.didReceiveSocketError("Send error: \(error.localizedDescription)")
                }
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}

