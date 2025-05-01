//
//  ChatCell.swift
//  ChatBotApp
//
//  Created by Nishant Kumar on 01/05/25.
//

import Foundation
import UIKit

/// A table view cell that displays a single chat message, either from the user or the bot.
class ChatCell: UITableViewCell {

    // MARK: - UI Elements

    private let messageLabel = UILabel()
    private let bubbleView = UIView()
    private let avatarImageView = UIImageView()
    private let statusImageView = UIImageView()

    // MARK: - Auto layout constraints

    private var leadingBubbleConstraint: NSLayoutConstraint!
    private var trailingBubbleConstraint: NSLayoutConstraint!
    private var statusToBubbleLeading: NSLayoutConstraint!
    private var statusToContentLeading: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
        
    private func setupViews() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = UIImage(systemName: AVATAR_IMAGE_NAME)
        avatarImageView.tintColor = .gray
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.clipsToBounds = true

        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        bubbleView.backgroundColor = .systemGray5
        bubbleView.layer.cornerRadius = 16
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.tintColor = .red
        statusImageView.contentMode = .scaleAspectFit
        statusImageView.image = UIImage(systemName: MESSAGE_SENT_STATUS_IMAGE_NAME)

        bubbleView.addSubview(messageLabel)
        contentView.addSubview(bubbleView)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(statusImageView)
    }
    
    /// Sets up Auto Layout constraints for all subviews.
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),

            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.7),

            avatarImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 32),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            statusImageView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            statusImageView.widthAnchor.constraint(equalToConstant: 32),
            statusImageView.heightAnchor.constraint(equalToConstant: 32)
        ])

        leadingBubbleConstraint = bubbleView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8)
        trailingBubbleConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        statusToBubbleLeading = statusImageView.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -6)
        statusToContentLeading = statusImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
    }
    
    // MARK: - Configuration

    /// Configures the cell with a chat message, adjusting layout and visuals
    /// based on whether the message is from the user or the bot and whether it failed.
    ///
    /// - Parameter chat: The `ChatMessage` instance to display.
    func configure(_ chat: ChatMessage) {
        let isUser = chat.type == .user
        let isFailed = chat.isFailed
        messageLabel.text = chat.message
        leadingBubbleConstraint.isActive = false
        trailingBubbleConstraint.isActive = false
        statusToBubbleLeading.isActive = false
        statusToContentLeading.isActive = false

        if isUser {
            messageLabel.textColor = .white
            avatarImageView.isHidden = true
            trailingBubbleConstraint.isActive = true
            if isFailed {
                statusImageView.isHidden = false
                statusToBubbleLeading.isActive = true
                let lightBlue = UIColor(red: 0.45, green: 0.65, blue: 1.0, alpha: 1.0)
                bubbleView.backgroundColor = lightBlue
            } else {
                statusImageView.isHidden = true
                bubbleView.backgroundColor = .systemBlue
            }
        } else {
            bubbleView.backgroundColor = .systemGray5
            messageLabel.textColor = .black
            avatarImageView.isHidden = false
            leadingBubbleConstraint.isActive = true
            statusImageView.isHidden = true
            statusToContentLeading.isActive = true
        }
    }
}
