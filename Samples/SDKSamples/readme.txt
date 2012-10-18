Samples App Readme
==================

The samples app is provided as a demonstration of how to use the SDK and should not be used in a production scenario.

Known Issues
------------

- Error handling is very basic and only shows a generic error message meaning it can sometimes be difficult to determine
  the actual cause of an error.
- The samples app does not provide any handling for expired access tokens when running against the Cloud, if you experience
  persistent error message navigate back to the Server Type page and re-authenticate.
- Searches, the loading of activties and tags against Alfresco in the Cloud occasionally timeout and display a generic error message.
- Uploading a photo without a file extension prevents the samples app from previewing the image.
- The samples app does not provide a way to enter new tags when uploading a photo.
- Photos uploaded with tags applied will cause two versions to be created.
- Thumbnails will not be shown for uploaded photos until they have been viewed in Share.
- For some activity types the avatar of the user who posted the activity is shown rather than the user mentioned in the activity.

