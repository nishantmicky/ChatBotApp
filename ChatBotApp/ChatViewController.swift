//
//  ChatViewController.swift
//  ChatBotApp
//
//  Created by Nishant Kumar on 01/05/25.
//

import Foundation
import UIKit

import UIKit

class ChatViewController: UIViewController {

    private let tableView = UITableView()
    private let messageInputContainer = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    private var messages: [ChatMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "ChatBot"
        
        setupTableView()
        setupInputComponents()
        
        SocketManager.shared.delegate = self
        SocketManager.shared.connect()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ChatCell.self, forCellReuseIdentifier: "MessageCell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
    }

    private func setupInputComponents() {
        view.addSubview(messageInputContainer)
        messageInputContainer.translatesAutoresizingMaskIntoConstraints = false
        messageInputContainer.backgroundColor = .secondarySystemBackground

        messageInputContainer.addSubview(messageTextField)
        messageInputContainer.addSubview(sendButton)

        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.placeholder = "Type a message..."
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            messageInputContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            messageInputContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            messageInputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputContainer.heightAnchor.constraint(equalToConstant: 60),

            messageTextField.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            messageTextField.leftAnchor.constraint(equalTo: messageInputContainer.leftAnchor, constant: 12),
            messageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -8),

            sendButton.rightAnchor.constraint(equalTo: messageInputContainer.rightAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
        ])
    }

    @objc private func sendTapped() {
        guard let text = messageTextField.text, !text.isEmpty else { return }

        let messagePayload = ["message": text]
        if let data = try? JSONSerialization.data(withJSONObject: messagePayload),
           let jsonString = String(data: data, encoding: .utf8) {
            SocketManager.shared.send(message: jsonString)
        }

        let newMessage = ChatMessage(type: .user, message: text)
        messages.append(newMessage)
        tableView.reloadData()
        scrollToBottom()
        messageTextField.text = ""
    }

    private func scrollToBottom() {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        if messages.indices.contains(indexPath.row) {
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! ChatCell
        cell.configure(chat)
        return cell
    }
}

extension ChatViewController: SocketManagerDelegate {
    func didReceiveMessage(_ message: String) {
        let newMessage = ChatMessage(type: .bot, message: message)
        messages.append(newMessage)
        tableView.reloadData()
        scrollToBottom()
    }
}
