const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Trigger on new message in Firestore
exports.sendChatNotification = functions.firestore
  .document('student_alumni_chat/{chatId}/messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    const msg = snapshot.data();
    if (!msg) return;

    const receiverEmail = msg.receiver;

    // Get receiver's FCM token from Firestore
    const userDoc = await admin.firestore()
      .collection('alumni_data') // or 'students_data' if needed
      .doc(receiverEmail)
      .get();

    if (!userDoc.exists) return;
    const userData = userDoc.data();
if (!userData) return;
const token = userData.fcm_token;

    if (!token) return;

    // Create notification payload
    const payload = {
      notification: {
        title: msg.sender,  // sender name or email
        body: msg.text,
        click_action: "FLUTTER_NOTIFICATION_CLICK"
      }
    };

    // Send FCM notification
    try {
      await admin.messaging().sendToDevice(token, payload);
      console.log("Notification sent to:", receiverEmail);
    } catch (err) {
      console.error("Error sending notification:", err);
    }
  });
