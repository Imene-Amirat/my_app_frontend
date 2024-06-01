import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_app_frontend/databases/DBimage.dart';
import 'package:my_app_frontend/databases/DBrecord.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/full_image_screen.dart';
import 'package:my_app_frontend/view/shared_data_screen.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('user_id'); // Returns the user ID, or null if not set
  }

  void showCustomDisabledFeatureMessage(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);

    scaffold.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(
          "Record successfully deleted",
          style: TextStyle(color: Colors.white),
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

  void _deleteRecord(BuildContext context) async {
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

  Future<String?> postAddInfoRecord(String userId) async {
    Dio dio = Dio();
    String api_endpoint_post_add_info_record =
        "https://flask-app-medical.vercel.app/recordinfo.set";
    try {
      var response = await dio.post('$api_endpoint_post_add_info_record',
          data: FormData.fromMap({
            'title': widget.record['title'],
            'recordType': widget.record['recordTypeName'],
            'doctor': widget.record['doctorName'],
            'sp': widget.record['doctorSp'],
            'date': widget.record['date'],
            'des': widget.record['description'],
            'userId': userId,
          }));
      // Directly use response.data since Dio automatically decodes JSON responses
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        Map<String, dynamic> retData = response.data;
        print(retData); // Correctly print the decoded JSON object
        String? recordId =
            retData['record_id']?.toString(); // Safely access the record_id
        if (recordId != null) {
          print('Data is added successfully.');
          return recordId;
        } else {
          print('Record ID not found in response.');
        }
      } else {
        print('Error with request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error making request: $e');
      if (e is DioError) {
        print('Error response: ${e.response?.data}');
        print('Error statusCode: ${e.response?.statusCode}');
        print('Error headers: ${e.response?.headers}');
      }
    }
    return null;
    /*Map ret_data = json.decode(response.toString());
      print(ret_data);
      if (ret_data['status'] == 200) {
        print("tttt");
        String? recordId = ret_data['record_id'];
        print('data is added successfully.');
        return recordId;
      } else {
        print('Error >>>> $ret_data');
      }
    } catch (e, stack) {
      print('Error >>>>>>>> $e \n $stack');
      if (e is DioError) {
        print('Error response: ${e.response?.data}');
        print('Error statusCode: ${e.response?.statusCode}');
        print('Error headers: ${e.response?.headers}');
      }
    }
    return 'Error somewhere....';*/
  }

  Future<Map> postAddImage(List<String> img_url) async {
    Dio dio = Dio();
    String api_endpoint_post_add_image = "http://127.0.0.1:5000/UploadImage";
    try {
      // Within postAddImage function
      FormData formData = FormData();

// Adjusting the key used to add files to match the Flask expectation
      for (String path in img_url) {
        formData.files.add(MapEntry(
          "files[]", // Adjusted to match the Flask side expectation
          await MultipartFile.fromFile(path, filename: path.split("/").last),
        ));
      }
      var response =
          await dio.post('$api_endpoint_post_add_image', data: formData);
      Map ret_data = json.decode(response.toString());
      if (ret_data['status'] == 200) {
        return {'status': 1, 'message': 'data is added successfully.'};
      } else {
        print('Error >>>> $ret_data');
      }
    } catch (e, stack) {
      print('Error >>>>>>>> $e \n $stack');
    }
    return {'status': 0, 'message': 'Error somewhere....'};
  }

  Future<void> _uploadImagesToSupabase(
      List<String> imgPaths, String userId) async {
    final client = Supabase.instance.client;
    List<String> uploadedImageUrls = [];

    for (var path in imgPaths) {
      final file = File(path);
      final imageExtension = path.split('.').last.toLowerCase();
      final imageBytes = await file.readAsBytes();
      // Construct a unique path for each image
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final imagePath = '/$userId/image/${timestamp}_${basename(file.path)}';

      var storageResponse = await client.storage.from('photos').uploadBinary(
          imagePath, imageBytes,
          fileOptions: FileOptions(contentType: 'image/$imageExtension'));
      final fileUrl = client.storage.from('photos').getPublicUrl(imagePath);
      print(fileUrl);
      uploadedImageUrls.add(fileUrl);
    }
  }

  Future<Map> postImagesToServer(
      List<String> imgPaths, String userId, String recordId) async {
    Dio dio = Dio();
    String apiUrl = "https://flask-app-medical.vercel.app/upload_images";

    try {
      FormData formData = FormData();
      // Add user ID to the request
      formData.fields.add(MapEntry('userId', userId));

      // Add record ID to the request
      formData.fields.add(MapEntry('record_id', recordId));

      // Add each image file to the FormData
      for (String path in imgPaths) {
        String fileName = basename(path);
        formData.files.add(MapEntry(
          "file", // Make sure this matches the Flask endpoint expectation
          await MultipartFile.fromFile(path, filename: fileName),
        ));
      }

      var response = await dio.post(apiUrl, data: formData);
      if (response.statusCode == 200) {
        return {
          "status": 1,
          "message": "Images sent successfully.",
          "data": response.data
        };
      } else {
        return {"status": 0, "message": "Failed to send images."};
      }
    } catch (e) {
      print(e);
      return {"status": 0, "message": "Error occurred while sending images."};
    }
  }

  void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must not close the dialog manually
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 24),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop(); // Pop the loading dialog off the stack
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
              Icons.send,
              color: Colors.white,
            ),
            onPressed: () async {
              String? user_Id = await getUserId();
              if (user_Id != null) {
                print(user_Id);
                List<String> paths = await imagePaths;
                showLoadingDialog(
                    context, "Adding record and uploading images...");
                String? recordId = await postAddInfoRecord(user_Id);
                print(recordId);

                if (recordId != null) {
                  if (paths.isNotEmpty) {
                    var response =
                        await postImagesToServer(paths, user_Id, recordId);
                    hideLoadingDialog(context);
                    if (response['status'] == 1) {
                      print("Images successfully sent to server.");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SharedScreen(recordId: recordId)),
                      );
                    } else {
                      print(
                          "Failed to send images to server: ${response['message']}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SharedScreen(recordId: recordId)),
                      );
                    }
                  } else {
                    print("No images to upload for this record.");
                    hideLoadingDialog(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SharedScreen(recordId: recordId)),
                    );
                  }
                } else {
                  print("Failed to add info record or obtain record ID.");
                }

                /*if (paths.isNotEmpty) {
                  //await _uploadImagesToSupabase(paths, user_Id);
                } else {
                  print("No images to upload for this record.");
                }*/
              }
            }, // Define this method to handle deletion
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () =>
                _deleteRecord(context), // Define this method to handle deletion
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
                    Text("Specialty :", style: labelStyle),
                    SizedBox(height: 4),
                    Text("${widget.record['doctorSp']}", style: contentStyle),
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
            Text("Clinical Documents :",
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
