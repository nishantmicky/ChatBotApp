//
//  ChatViewController.swift
//  ChatBotApp
//
//  Created by Nishant Kumar on 01/05/25.
//

import Foundation
import UIKit

class ChatViewController: UIViewController {

    // MARK: - UI Elements

    private let tableView = UITableView()
    private let messageInputContainer = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let noChatsLabel = UILabel()
    private let noInternetLabel = UILabel()
    
    private var messages: [ChatMessage] = []
    private var unsentMessages: [ChatMessage] = []
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = CHAT_SCREEN_HEADING_TEXT
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 24),
        ]
        
        NetworkMonitor.shared.startMonitoring()
        SocketManager.shared.delegate = self
        SocketManager.shared.connect()

        setupNoChatsView()
        setupTableView()
        setupInputComponents()
        setUpNoInternetView()
        setUpConstraints()
        addNotificationObservers()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideInput))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NetworkMonitor.shared.stopMonitoring()
        SocketManager.shared.disconnect()
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged),
            name: NETWORK_STATUS_CHANGED,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    // MARK: - Layout

    private func setupNoChatsView() {
        view.addSubview(noChatsLabel)
        noChatsLabel.text = NO_CHATS_AVAILABLE_TEXT
        noChatsLabel.textAlignment = .center
        noChatsLabel.textColor = .gray
        noChatsLabel.font = UIFont.systemFont(ofSize: 24)
        noChatsLabel.isHidden = false
        noChatsLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isHidden = true
        tableView.register(ChatCell.self, forCellReuseIdentifier: MESSAGE_CELL_IDENTIFIER)

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
        messageTextField.placeholder = MESSAGE_TEXTFIELD_PLACEHOLDER_TEXT
        sendButton.setTitle(SEND_BUTTON_TEXT, for: .normal)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }
    
    private func setUpNoInternetView() {
        view.addSubview(noInternetLabel)
        noInternetLabel.text = NO_INTERNET_AVAILABLE_TEXT
        noInternetLabel.textColor = .white
        noInternetLabel.backgroundColor = .systemRed
        noInternetLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        noInternetLabel.textAlignment = .center
        noInternetLabel.isHidden = true
        noInternetLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            noChatsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noChatsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageInputContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            messageInputContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            messageInputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputContainer.heightAnchor.constraint(equalToConstant: 60),
            
            noInternetLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            noInternetLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            noInternetLabel.bottomAnchor.constraint(equalTo: messageInputContainer.topAnchor),
            noInternetLabel.heightAnchor.constraint(equalToConstant: 30),

            messageTextField.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            messageTextField.leftAnchor.constraint(equalTo: messageInputContainer.leftAnchor, constant: 12),
            messageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -8),

            sendButton.rightAnchor.constraint(equalTo: messageInputContainer.rightAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
        ])
    }
    
    // MARK: - Action helper

    @objc private func sendTapped() {
        guard let text = messageTextField.text, !text.isEmpty else { return }

        view.endEditing(true)
        let isOnline = NetworkMonitor.shared.isConnected
        let messagePayload = ["message": text]
        let newMessage = ChatMessage(type: .user, message: text, isFailed: !isOnline)
        messages.append(newMessage)
        messageTextField.text = ""
        updateViews()
        
        if isOnline {
            sendMessageToSocket(messagePayload)
        } else {
            unsentMessages.append(newMessage)
        }
    }
    
    @objc private func networkStatusChanged() {
        if NetworkMonitor.shared.isConnected {
            noInternetLabel.isHidden = true
            resendUnsentMessages()
        } else {
            noInternetLabel.isHidden = false
        }
    }
    
    // MARK: - Private methods
    
    private func sendMessageToSocket(_ payload: [String: String]) {
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let jsonString = String(data: data, encoding: .utf8) else { return }
        print("Sending: \(payload)")
        SocketManager.shared.send(message: jsonString)
    }
    
    private func resendUnsentMessages() {
        if unsentMessages.count == 0 {
            return
        }
        
        for message in unsentMessages {
            let payload = ["message": message.message]
            sendMessageToSocket(payload)
        }
        unsentMessages.removeAll()
        for i in 0..<messages.count {
            if messages[i].isFailed {
                messages[i].isFailed = false
            }
        }
        updateViews()
    }
    
    private func updateViews() {
        noChatsLabel.isHidden = true
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    private func scrollToBottom() {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        if messages.indices.contains(indexPath.row) {
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25

        UIView.animate(withDuration: duration) {
            let translationY = -keyboardHeight
            self.messageInputContainer.transform = CGAffineTransform(translationX: 0, y: translationY)
            self.noInternetLabel.transform = CGAffineTransform(translationX: 0, y: translationY)
            self.tableView.contentInset.bottom = keyboardHeight + self.messageInputContainer.frame.height
            self.scrollToBottom()
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25

        UIView.animate(withDuration: duration) {
            self.messageInputContainer.transform = .identity
            self.noInternetLabel.transform = .identity
            self.tableView.contentInset.bottom = self.messageInputContainer.frame.height
        }
    }
    
    @objc private func handleTapOutsideInput(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !messageInputContainer.frame.contains(location) {
            view.endEditing(true)
        }
    }
}

// MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MESSAGE_CELL_IDENTIFIER, for: indexPath) as! ChatCell
        cell.configure(chat)
        return cell
    }
}

// MARK: - SocketManagerDelegate

extension ChatViewController: SocketManagerDelegate {
    func didReceiveMessage(_ message: String) {
        let newMessage = ChatMessage(type: .bot, message: message)
        messages.append(newMessage)
        updateViews()
    }
    
    func didReceiveSocketError(_ error: String) {
        let alertController = UIAlertController(title: "Socket Error", message: error, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
