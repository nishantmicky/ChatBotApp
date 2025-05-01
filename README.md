# ChatBot App
A single-screen mobile chat application that supports real-time communication and
offline functionality.

## Features
- Chat home screen is loaded when app is launched with no chats available.
- User can send message and receive message in real-time.
- Messages history are displayed in conversation with latest at bottom.
- Messages received/sent are displayed immediately without refreshing.
- Messages are queued and displayed when device is offline, and is automatically sent when device is back online.
- Alerts are shown for API errors or network failure, and No internet text is displayed when device is offline.
- Chatbot conversations are cleared when app is closed.

## Approach Taken
- Used  `Pie host` for socket based communication for real-time syncing.
- Used `NWPathMonitor` for handling offline functionality.
- Used `Swift` language for creating application and `UIKit programmatically` for creating UI.

## Future Scope
- Create multiple chatbots where user can switch between different chats.
