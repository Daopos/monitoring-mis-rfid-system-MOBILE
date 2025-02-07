import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart'; // Import the open_file package
import 'dart:io';
import 'dart:async';

class PdfPage extends StatefulWidget {
  const PdfPage({super.key});

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  bool _isLoading = false; // Track loading state

  // Function to download the PDF
  Future<void> downloadPdf() async {
    setState(() {
      _isLoading = true; // Set loading to true when starting the download
    });

    try {
      // Request storage permission for Android
      var status = await Permission.storage.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }

      // Proceed with the download logic (Dio request)
      final url = 'https://agl-heights.online/api/pdfs/download';
      Dio dio = Dio();
      Response response = await dio.get(
        url,
        options: Options(responseType: ResponseType.stream),
      );

      if (response.statusCode == 200) {
        // Get the path to the public Downloads directory
        String downloadsPath = '/storage/emulated/0/Download';
        Directory downloadFolder = Directory(downloadsPath);
        if (!await downloadFolder.exists()) {
          await downloadFolder.create(
              recursive: true); // Create the folder if it doesn't exist
        }

        // Construct the path to the PDF file in the Downloads folder
        String filePath = '$downloadsPath/downloaded_pdf.pdf';
        File file = File(filePath);

        var sink = file.openWrite();
        await response.data.stream.listen(
          (List<int> chunk) {
            sink.add(chunk);
          },
          onDone: () async {
            await sink.close();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF downloaded successfully to $filePath!'),
                action: SnackBarAction(
                  label: 'Open',
                  onPressed: () {
                    OpenFile.open(filePath); // Open the downloaded PDF file
                  },
                ),
              ),
            );
          },
          onError: (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error downloading PDF')),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download PDF')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false when done
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download PDF'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Show loading indicator
            : ElevatedButton(
                onPressed: downloadPdf,
                child: const Text('Download PDF'),
              ),
      ),
    );
  }
}
