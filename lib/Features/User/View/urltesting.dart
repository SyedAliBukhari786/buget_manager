import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';



class OpenUrlText extends StatelessWidget {
  const OpenUrlText({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchUrl('https://www.example.com'),
      child: const Text(
        'Click here to open Example.com',
        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
      ),
    );
  }
}
