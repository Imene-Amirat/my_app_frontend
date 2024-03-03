import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_app_frontend/databases/DBimage.dart';
import 'package:my_app_frontend/databases/DBrecord.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/full_image_screen.dart';

class RecordDetailScreen extends StatefulWidget {
  final Map record;

  const RecordDetailScreen({Key? key, required this.record}) : super(key: key);

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  late Future<List<String>> imagePaths;

  @override
  void initState() {
    super.initState();
    // Fetch images for the current record
    imagePaths = DBImage.getImagePathsForRecord(widget.record['id']);
    print(widget.record['id']);
  }

  void showCustomDisabledFeatureMessage(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);

    scaffold.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.black.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(12),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Record successfully deleted",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAssociatedImages(int recordId) async {
    try {
      //fetch the paths of all images associated with the record
      List<String> imagePaths = await DBImage.getImagePathsForRecord(recordId);

      //loop through each path and delete the file
      for (String imagePath in imagePaths) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      print("Error deleting images: $e");
    }
  }

  void _deleteRecord() async {
    //first delete the associated image files
    await _deleteAssociatedImages(widget.record['id']);

    //then delete the database entries for these images
    await DBImage.deleteImagesForRecord(widget.record['id']);
    bool success = await DBRecord.deleteRecord(widget.record['id']);
    if (success) {
      showCustomDisabledFeatureMessage(context);

      // Pop back to the previous screen
      Navigator.of(context)
          .pop(true); // Passing 'true' to indicate a successful deletion
    } else {
      // Handle failure (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete the record'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = TextStyle(
      color: Colors.grey[600],
      fontWeight: FontWeight.bold,
    );
    TextStyle contentStyle = TextStyle(fontSize: 16);
    // Use widget.record to access the passed record data
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            LineAwesomeIcons.angle_left,
            size: 30,
          ),
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Text(
          widget.record['recordTypeName'] ?? 'Record Detail',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: _deleteRecord, // Define this method to handle deletion
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Information Details :",
                style: TextStyle(
                    color: GlobalColors.mainColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            SizedBox(height: 10),
            Card(
              elevation: 4.0,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Title :",
                      style: labelStyle,
                    ),
                    SizedBox(height: 4),
                    Text("${widget.record['title']}", style: contentStyle),
                    Divider(),
                    Text("Record Type :", style: labelStyle),
                    SizedBox(height: 4),
                    Text("${widget.record['recordTypeName']}",
                        style: contentStyle),
                    Divider(),
                    Text("Doctor :", style: labelStyle),
                    SizedBox(height: 4),
                    Text("${widget.record['doctorName']}", style: contentStyle),
                    Divider(),
                    Text("Date :", style: labelStyle),
                    SizedBox(height: 4),
                    Text("${widget.record['date']}", style: contentStyle),
                    Divider(),
                    Text("Description :", style: labelStyle),
                    SizedBox(height: 4),
                    Text("${widget.record['description']}",
                        style: contentStyle),
                  ],
                ),
              ),
            ),
            /*Text("Title: ${widget.record['title']}"),
            Text("Record Type: ${widget.record['recordTypeName']}"),
            Text("Doctor: ${widget.record['doctorName']}"),
            Text("Date: ${widget.record['date']}"),
            Text("Description: ${widget.record['description']}"),*/
            SizedBox(height: 20),
            Text("Images :",
                style: TextStyle(
                    color: GlobalColors.mainColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            SizedBox(height: 10),
            FutureBuilder<List<String>>(
              future: imagePaths,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error fetching images");
                } else {
                  return snapshot.data!.isEmpty
                      ? Text("No images available", style: contentStyle)
                      : Container(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              String imagePath = snapshot.data![index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => FullScreenImageViewer(
                                              imagePath: imagePath))),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.file(File(imagePath),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                  /*GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      String imagePath = snapshot.data![index];
                      return Image.file(File(imagePath), fit: BoxFit.cover);
                    },
                  );*/
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
