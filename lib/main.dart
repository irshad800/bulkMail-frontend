import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class EmailSenderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email Sender',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: EmailSenderScreen(),
    );
  }
}

class EmailSenderScreen extends StatefulWidget {
  @override
  _EmailSenderScreenState createState() => _EmailSenderScreenState();
}

class _EmailSenderScreenState extends State<EmailSenderScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController recipientsController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  File? selectedFile;

  // Pick a file
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedFile = File(result.files.single.path!);
        });
        print('File selected: ${selectedFile?.path}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No file selected")),
        );
      }
    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking file: $e")),
      );
    }
  }

  // Send email
  Future<void> sendEmail() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a PDF file to attach.")),
      );
      return;
    }

    final uri = Uri.parse("https://bulkmail-16qu.onrender.com/send-email");
    final request = http.MultipartRequest('POST', uri);

    request.fields['your_email'] = emailController.text;
    request.fields['your_password'] = passwordController.text;
    request.fields['recipients'] = recipientsController.text;
    request.fields['subject'] = subjectController.text;
    request.fields['body'] = bodyController.text;

    try {
      // Ensure proper MIME type for PDF
      request.files.add(
        await http.MultipartFile.fromPath(
          'cv',
          selectedFile!.path,
          contentType: MediaType('application', 'pdf'),
        ),
      );
      print('File added to request: ${selectedFile?.path}');
    } catch (e) {
      print("Error attaching file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error attaching file: $e")),
      );
      return;
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print("Email sent successfully");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Email sent successfully!"),
          backgroundColor: Colors.green,
        ));
      } else {
        print("Failed to send email: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to send email: ${response.statusCode}"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print("Error sending email: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Send Email')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sender Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Your Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Your App Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    TextField(
                      controller: recipientsController,
                      decoration: InputDecoration(
                        labelText: 'Recipients (comma-separated)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: bodyController,
                      decoration: InputDecoration(
                        labelText: 'Body',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: Icon(
                Icons.attach_file,
                color: Colors.white,
              ),
              label: Text(
                selectedFile == null ? 'Pick PDF File' : 'File Selected',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: Colors.teal,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: sendEmail,
              icon: Icon(
                Icons.send,
                color: Colors.white,
              ),
              label: Text(
                'Send Email',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: Colors.teal[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(
      EmailSenderApp(),
    );
