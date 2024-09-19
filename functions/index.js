const functions = require('firebase-functions');
const { Translate } = require('@google-cloud/translate').v2;
const translate = new Translate();
const admin = require('firebase-admin');

admin.initializeApp();

// Function to get localized message
function getLocalizedMessage(senderName) {
  return `${senderName} Sent You A New Message`;
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

    const { senderId, isRead } = newMessage;

    // Check if isRead is an object
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

        // Get the sender's name
        const senderDoc = await admin.firestore().collection('user').doc(senderId).get();
        const senderName = senderDoc.data().name || 'Unknown Sender';
        const localizedMessage = getLocalizedMessage(senderName);

        // Create the notification payload
        const payload = {
          notification: {
            title: 'GinzApp',
            body: localizedMessage, // Shows "SenderName Sent You a New Message"
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

// Firebase Function to translate text
exports.translateText = functions.https.onCall(async (data, context) => {
  const text = data.text;
  const targetLanguage = data.targetLanguage; // e.g., 'en' or 'ar'

  try {
    // Translate the text
    const [translation] = await translate.translate(text, targetLanguage);
    return { translation };
  } catch (error) {
    console.error('Error translating text:', error);
    throw new functions.https.HttpsError('internal', 'Translation failed');
  }
});
