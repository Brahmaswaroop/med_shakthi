import 'package:flutter/material.dart';

// Models
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final String messageType; // 'text', 'image', 'video', 'audio', 'document'
  final String? filePath;
  final String? fileUrl;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.messageType,
    this.filePath,
    this.fileUrl,
  });
}

class SupplierProfile {
  final String id;
  final String name;
  final String profileImage;
  final String phone;
  final String email;
  final bool isOnline;

  SupplierProfile({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.phone,
    required this.email,
    required this.isOnline,
  });
}

class ChatScreen extends StatefulWidget {
  final SupplierProfile supplier;

  const ChatScreen({
    super.key,
    required this.supplier,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late AnimationController _messageAnimationController;

  // Dummy data - messages list
  List<ChatMessage> messages = [
    ChatMessage(
      id: '1',
      senderId: 'supplier_001',
      senderName: 'Med Store',
      message: 'Hello! How can I help you today?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      messageType: 'text',
    ),
    ChatMessage(
      id: '2',
      senderId: 'user_123',
      senderName: 'You',
      message: 'Hi! I want to ask about the Aspirin dosage',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
      messageType: 'text',
    ),
    ChatMessage(
      id: '3',
      senderId: 'supplier_001',
      senderName: 'Med Store',
      message:
          'Sure! Aspirin 500mg is typically recommended for adults. You can take 1-2 tablets every 4-6 hours as needed.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      messageType: 'text',
    ),
    ChatMessage(
      id: '4',
      senderId: 'user_123',
      senderName: 'You',
      message: 'Thanks for the information!',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      messageType: 'text',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _messageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _messageAnimationController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    _messageAnimationController.forward(from: 0.0);

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'user_123',
      senderName: 'You',
      message: _messageController.text,
      timestamp: DateTime.now(),
      messageType: 'text',
    );

    setState(() {
      messages.add(newMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate supplier response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final response = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'supplier_001',
          senderName: widget.supplier.name,
          message: 'Thanks for your message! We\'ll get back to you shortly.',
          timestamp: DateTime.now(),
          messageType: 'text',
        );
        setState(() {
          messages.add(response);
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                messages.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFileOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share File',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFileOption(
                  icon: Icons.image,
                  label: 'Image',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _shareFile('image');
                  },
                ),
                _buildFileOption(
                  icon: Icons.videocam,
                  label: 'Video',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _shareFile('video');
                  },
                ),
                _buildFileOption(
                  icon: Icons.audio_file,
                  label: 'Audio',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _shareFile('audio');
                  },
                ),
                _buildFileOption(
                  icon: Icons.description,
                  label: 'Document',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _shareFile('document');
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildFileOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _shareFile(String fileType) {
    final fileName = fileType == 'image'
        ? 'prescription.jpg'
        : fileType == 'video'
            ? 'demo_video.mp4'
            : fileType == 'audio'
                ? 'voice_message.m4a'
                : 'medical_report.pdf';

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'user_123',
      senderName: 'You',
      message: fileName,
      timestamp: DateTime.now(),
      messageType: fileType,
      fileUrl: 'https://example.com/$fileName',
    );

    setState(() {
      messages.add(newMessage);
    });

    _scrollToBottom();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$fileType file sent'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _initiateCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4C8077).withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.phone_in_talk,
                size: 50,
                color: Color(0xFF4C8077),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Calling ${widget.supplier.name}...',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.supplier.phone,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4C8077).withValues(alpha: 0.2),
              ),
              child: widget.supplier.profileImage.isEmpty
                  ? const Icon(
                      Icons.person,
                      color: Color(0xFF4C8077),
                      size: 20,
                    )
                  : ClipOval(
                      child: Image.network(
                        widget.supplier.profileImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, color: Color(0xFF4C8077)),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.supplier.name,
                    style: TextStyle(
                      color: Theme.of(context).appBarTheme.foregroundColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.supplier.isOnline
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.supplier.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.call, color: Color(0xFF4C8077), size: 20),
                    SizedBox(width: 10),
                    Text('Call'),
                  ],
                ),
                onTap: () {
                  _initiateCall();
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFF4C8077), size: 20),
                    SizedBox(width: 10),
                    Text('Info'),
                  ],
                ),
                onTap: () {
                  _showSupplierInfo();
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.receipt, color: Color(0xFF4C8077), size: 20),
                    SizedBox(width: 10),
                    Text('Invoice'),
                  ],
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invoice feature coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text('Clear Chat'),
                  ],
                ),
                onTap: () {
                  _clearChat();
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                const Color(0xFF4C8077).withValues(alpha: 0.1),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            size: 50,
                            color: Color(0xFF4C8077),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a conversation with ${widget.supplier.name}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUser = message.senderId == 'user_123';

                      return ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _messageAnimationController,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? const Color(0xFF4C8077)
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: message.messageType == 'text'
                                    ? Text(
                                        message.message,
                                        style: TextStyle(
                                          color: isUser
                                              ? Colors.white
                                              : Theme.of(context).textTheme.bodyLarge?.color,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    : _buildFileMessage(
                                        message,
                                        isUser,
                                      ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Input field
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // File attachment button
                ScaleTransition(
                  scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _fabAnimationController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF4C8077),
                      size: 28,
                    ),
                    onPressed: _showFileOptions,
                  ),
                ),

                // Message input field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[900] 
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),

                // Send button
                ScaleTransition(
                  scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _fabAnimationController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Color(0xFF4C8077),
                      size: 24,
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileMessage(ChatMessage message, bool isUser) {
    final fileTypeIcon = {
          'image': Icons.image,
          'video': Icons.videocam,
          'audio': Icons.audio_file,
          'document': Icons.description,
        }[message.messageType] ??
        Icons.attachment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
          fileTypeIcon,
          color: isUser 
              ? Colors.white 
              : Theme.of(context).textTheme.bodyLarge?.color,
          size: 28,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        message.message,
        style: TextStyle(
          color: isUser 
              ? Colors.white 
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      ],
    );
  }

  void _showSupplierInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supplier Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${widget.supplier.name}'),
            const SizedBox(height: 10),
            Text('Phone: ${widget.supplier.phone}'),
            const SizedBox(height: 10),
            Text('Email: ${widget.supplier.email}'),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Status: '),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.supplier.isOnline
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.supplier.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: widget.supplier.isOnline
                          ? Colors.green
                          : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
