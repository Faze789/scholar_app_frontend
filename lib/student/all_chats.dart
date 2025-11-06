import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class all_chats extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const all_chats({super.key, required this.studentData});
  
  @override
  State<all_chats> createState() => _all_chatsState();
}

class _all_chatsState extends State<all_chats> {
  List<Map<String, dynamic>> chatList = [];
  bool isLoading = true;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    currentUserEmail = widget.studentData['email']?.toString();
    if (currentUserEmail != null) {
      fetchAllChats();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> fetchAlumniImage(String alumniEmail) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final QuerySnapshot snapshot = await firestore
          .collection('alumni_data')
          .where('gmail', isEqualTo: alumniEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return data['image_url'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching alumni image: $e');
      return null;
    }
  }

  Future<void> fetchAllChats() async {
    try {
      if (currentUserEmail == null) return;

      final firestore = FirebaseFirestore.instance;
      final QuerySnapshot snapshot = await firestore
          .collection('student_alumni_chat')
          .get();

      List<Map<String, dynamic>> userChats = [];

      for (var doc in snapshot.docs) {
        String docId = doc.id;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
     
        if (docId.contains(currentUserEmail!)) {
       
          String otherUserEmail = docId
              .replaceAll(currentUserEmail!, '')
              .replaceAll('_', '')
              .trim();
        
          if (otherUserEmail.isEmpty) {
            List<String> participants = docId.split('_');
            for (String participant in participants) {
              if (participant != currentUserEmail && participant.isNotEmpty) {
                otherUserEmail = participant;
                break;
              }
            }
          }

        
          List<dynamic> participants = data['participants'] ?? [];
          String displayName = otherUserEmail;
          
        
          for (var participant in participants) {
            if (participant != currentUserEmail) {
              displayName = participant;
              break;
            }
          }

       
          String? alumniImageUrl = await fetchAlumniImage(otherUserEmail);

          userChats.add({
            'docId': docId,
            'otherUserEmail': otherUserEmail,
            'displayName': displayName,
            'lastMessage': data['lastMessage'] ?? 'No messages yet',
            'lastTimestamp': data['lastTimestamp'],
            'participants': participants,
            'alumniImageUrl': alumniImageUrl, 
          });
        }
      }

    
      userChats.sort((a, b) {
        if (a['lastTimestamp'] == null && b['lastTimestamp'] == null) return 0;
        if (a['lastTimestamp'] == null) return 1;
        if (b['lastTimestamp'] == null) return -1;
        
        Timestamp timestampA = a['lastTimestamp'] as Timestamp;
        Timestamp timestampB = b['lastTimestamp'] as Timestamp;
        return timestampB.compareTo(timestampA);
      });

      setState(() {
        chatList = userChats;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching chats: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    
    if (dateTime.day == now.day && 
        dateTime.month == now.month && 
        dateTime.year == now.year) {
      
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime.year == now.year) {
     
      return '${dateTime.day}/${dateTime.month}';
    } else {
  
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void openChat(String docId, String otherUserEmail, String displayName) {

    print('Opening chat with: $displayName (Document: $docId)');
    


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Chats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 8,
        shadowColor: Colors.indigo.withOpacity(0.5),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo.shade600,
                Colors.indigo.shade800,
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                print('Current User Email: $currentUserEmail');
                print('Student Data: ${widget.studentData}');
                print('Total Chats: ${chatList.length}');
              },
            ),
          ),
        ],
      ),
      body: currentUserEmail == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No email found in student data',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading chats...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : chatList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No chats found',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation with alumni to see chats here',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchAllChats,
                      color: Colors.indigo,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: chatList.length,
                        itemBuilder: (context, index) {
                          final chat = chatList[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                             leading: CircleAvatar(
  radius: 28,
  backgroundColor: Colors.indigo.shade100,
  backgroundImage: chat['alumniImageUrl'] != null && chat['alumniImageUrl'].isNotEmpty
      ? NetworkImage(chat['alumniImageUrl'])
      : null,
  child: (chat['alumniImageUrl'] == null || chat['alumniImageUrl'].isEmpty)
      ? Text(
          chat['displayName']
              .toString()
              .split('@')[0]
              .substring(0, 1)
              .toUpperCase(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade700,
          ),
        )
      : null,
),

                              title: Text(
                                chat['displayName']
                                    .toString()
                                    .split('@')[0], 
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    chat['lastMessage']?.toString() ?? 'No messages',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    chat['otherUserEmail']?.toString() ?? '',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatTimestamp(chat['lastTimestamp']),
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                              onTap: () => openChat(
                                chat['docId'],
                                chat['otherUserEmail'],
                                chat['displayName'],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}