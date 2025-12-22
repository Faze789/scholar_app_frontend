import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlumniChatsScreen extends StatefulWidget {
  final Map<String, dynamic> alumniData;

  const AlumniChatsScreen({super.key, required this.alumniData});

  @override
  State<AlumniChatsScreen> createState() => _AlumniChatsScreenState();
}

class _AlumniChatsScreenState extends State<AlumniChatsScreen> {
  List<Map<String, dynamic>> userChats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChatsInvolvingUser();
  }

  Future<void> fetchChatsInvolvingUser() async {
    final currentEmail = widget.alumniData['email'].toString().toLowerCase();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('student_alumni_chat')
          .get();

      final List<Map<String, dynamic>> chats = [];

      for (final doc in snapshot.docs) {
        final docId = doc.id;
        
        if (docId.contains(currentEmail)) {
          final parts = docId.split('_');
          String studentEmail = '';
          
          for (int i = 0; i < parts.length; i++) {
            if (parts[i] == currentEmail) {
              studentEmail = parts.sublist(0, i).join('_') + 
                           parts.sublist(i + 1).join('_');
              break;
            }
          }
          
          if (studentEmail.isEmpty) {
            studentEmail = docId.replaceAll('${currentEmail}_', '').replaceAll('_$currentEmail', '');
          }
          
          final data = doc.data();
          
          chats.add({
            'chatId': doc.id,
            'studentEmail': studentEmail,
            'lastMessage': data['lastMessage'] ?? 'No message',
            'lastTimestamp': data['lastTimestamp'],
          });
        }
      }
      
      chats.sort((a, b) {
        final timestampA = a['lastTimestamp'] as Timestamp?;
        final timestampB = b['lastTimestamp'] as Timestamp?;
        if (timestampA == null || timestampB == null) return 0;
        return timestampB.compareTo(timestampA);
      });

      setState(() {
        userChats = chats;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error fetching user chats: $e');
      setState(() => isLoading = false);
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[dt.weekday - 1];
    } else {
      return '${dt.month}/${dt.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'WeChat',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: fetchChatsInvolvingUser,
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            onPressed: () {
              context.go('/alumni_home_screen', extra: widget.alumniData);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF07C160)))
          : userChats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: userChats.length,
                  itemBuilder: (context, index) {
                    final chat = userChats[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFF07C160),
                          child: Text(
                            chat['studentEmail'].isNotEmpty ? chat['studentEmail'][0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            chat['studentEmail'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        subtitle: Text(
                          chat['lastMessage'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatTimestamp(chat['lastTimestamp']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          context.pushNamed(
                            'messageChat',
                            extra: {
                              'alumniData': widget.alumniData,
                              'chatId': chat['chatId'],
                              'otherEmail': chat['studentEmail'],
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}