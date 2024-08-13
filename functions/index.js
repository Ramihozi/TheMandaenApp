const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Function to get localized message
function getLocalizedMessage(userLang, senderName) {
  const messages = {
    en: `${senderName} sent you a message`,
    es: `${senderName} te envió un mensaje`, // Spanish
    fr: `${senderName} vous a envoyé un message`, // French
    // Add more languages here
  };
  return messages[userLang] || messages['en']; // Default to English if language not found
}

// Firebase Function to send notifications on new message creation
exports.sendNewMessageNotification = functions.firestore
  .document('messages/{messageId}/chats/{chatId}')
  .onCreate(async (snap, context) => {
    const newMessage = snap.data();

    if (!newMessage) {
      console.error('No data found in the new message');
      return null;
    }

    const { senderId, message: latestMessage, isRead } = newMessage;

    // Check if isRead is a map
    if (typeof isRead !== 'object' || isRead === null) {
      console.error('isRead field is missing or not an object:', isRead);
      return null;
    }

    // Get recipient IDs who haven't read the message
    const recipientIds = Object.keys(isRead).filter(userId => userId !== senderId && !isRead[userId]);

    if (recipientIds.length === 0) {
      console.log('No recipients need notifications');
      return null;
    }

    try {
      for (const recipientId of recipientIds) {
        // Retrieve recipient's user document
        const userDoc = await admin.firestore().collection('user').doc(recipientId).get();
        const recipientData = userDoc.data();

        if (!recipientData) {
          console.log(`No data found for recipient ${recipientId}`);
          continue; // Skip to next recipient
        }

        const fcmToken = recipientData.fcmToken; // Get FCM token from the 'fcmToken' field
        if (!fcmToken) {
          console.log(`No FCM token for recipient ${recipientId}`);
          continue; // Skip to next recipient
        }

        // Get the recipient's language preference or default to English
        const userLanguage = recipientData.language || 'en';
        const senderDoc = await admin.firestore().collection('user').doc(senderId).get();
        const senderName = senderDoc.data().name || 'Unknown Sender';
        const localizedMessage = getLocalizedMessage(userLanguage, senderName);

        // Create the notification payload
        const payload = {
          notification: {
            title: 'GinzApp',
            body: `${senderName}: 'Sent You A New Message'`,
            // Note: Remove the `sound` field if not supported
          },
          token: fcmToken, // Use the correct field for FCM token
        };

        // Send the notification
        try {
          await admin.messaging().send(payload);
          console.log(`Successfully sent message to ${recipientId}`);
        } catch (notificationError) {
          console.error(`Error sending notification to ${recipientId}:`, notificationError);
        }
      }
      return null; // Ensure function returns null when done
    } catch (error) {
      console.error('Error processing notifications:', error);
      return null; // Ensure function handles errors properly
    }
  });
