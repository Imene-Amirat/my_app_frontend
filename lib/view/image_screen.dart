import 'dart:io';
import 'package:flutter/material.dart';

//display an image in full screen
class FullScreenImageScreen extends StatelessWidget {
  final String imagePath;
  final int imageIndex;
  final Function onDelete;

  const FullScreenImageScreen({
    Key? key,
    required this.imagePath,
    required this.imageIndex,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Screen Image'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            /*onPressed: () {
              onDelete(imageIndex);
              Navigator.pop(context);
            },*/
            onPressed: () => _showDeleteConfirmationDialog(context),
          ),
        ],
      ),
      body: Center(
        //child: Image.file(File(imagePath), fit: BoxFit.contain),
        //Zoom out image
        //wrap the Image widget with "InteractiveViewer" for zooming capability
        //zoom functionality using InteractiveViewer
        //user-friendly
        //enhancing the overall user experience
        child: InteractiveViewer(
          panEnabled:
              true, //allow the user to pan around the image when it's zoomed +
          boundaryMargin: EdgeInsets.all(
              2), //define the margin around the image when it's zoomed -
          minScale: 0.5,
          maxScale:
              4, //how much image can be zoomed + 4 times the original size
          child: Image.file(File(imagePath), fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Do you want to delete this image?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pop(), // Close the dialog without deleting
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call the onDelete function passed from the parent widget
                onDelete(imageIndex);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Pop the full screen image view
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
