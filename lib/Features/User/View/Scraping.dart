import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:url_launcher/url_launcher.dart';



class ScraperPage extends StatefulWidget {
  @override
  _ScraperPageState createState() => _ScraperPageState();
}

class _ScraperPageState extends State<ScraperPage> {





  List<String> urls = [
    "https://www.amazon.com/Performance-Extreme-Comfort-Short-Stone/dp/B016Y828TC/ref=sr_1_16?crid=7UBUJP1UQ8UI&dib=eyJ2IjoiMSJ9.b6YheqInrrfUwCdm88iGO_jajEbJeLgjLnERAI4aq6jGg_TYR4wcZSuyfujGA0_BDJMRpRc39WxXVCJ_DJOnz2qjd2L3iWFYgjplOONigxaTi6X6Vtwp6KlLEsafqHvOhf7fb1x2zTEpo48Cf4rFne-mSIeNWIJMG8ckp8yuzO32xrG6rBK5pokgRFDziMgLJnMwkbq2BkpSirS3vSGPC5K7qIwj20KngvseEDheqSsovBr3u-k7noeuxnWnmqY5Juap-yQ1pnvlzlNpVOaOQk8fWyiTkBhhersukzOhLhI.54v4fIfh0WaLPWEk0q4PwNyqUG2rNrreMfDieE3gNT4&dib_tag=se&keywords=clothes&qid=1723289061&sprefix=clothe%2Caps%2C306&sr=8-16",
    "https://www.amazon.com/Pacific-Natural-Foods-Original-Beverage/dp/B0118ANYLW/ref=sr_1_3?dib=eyJ2IjoiMSJ9.Ni6iNsfLV-a1SZGhr30oI53XAwW33Df6B3we5-hTMMpPAFhm5y9O9JnnHgnAxL_-9WAXr1i4QoyojOtXqwWAD9LEd-omyc4-OWPr7Y_Y5TE9KqF8Nx62j3MHFDESzdQvup0YWfSfQyswucQqQHgl8yBgTxoG-kYY0Q1F6bJ3sxEoNZBuQ_t97OF8b5WEs3YxzuMjxpcwJTQUicMyz7_gtTxWevzdwr7nGk84neAE7KMTcjMcqBo2DaI1Jru70AaVKmBdGwsg633BUzoXSVu3wTOFQaajY6JtE2nSjvp7ceU.KTkT1si0NlHEuAwFDjMyLIHh_zMJWnjHA4PIA0d7M4c&dib_tag=se&keywords=Milk&qid=1723285878&sr=8-3",
    "https://www.amazon.com/Horizon-Organic-Milk-Vanilla-Ounce/dp/B00ICZMK6M/ref=sr_1_7?dib=eyJ2IjoiMSJ9.Ni6iNsfLV-a1SZGhr30oI53XAwW33Df6B3we5-hTMMpPAFhm5y9O9JnnHgnAxL_-9WAXr1i4QoyojOtXqwWAD9LEd-omyc4-OWPr7Y_Y5TE9KqF8Nx62j3MHFDESzdQvup0YWfSfQyswucQqQHgl8yBgTxoG-kYY0Q1F6bJ3sxEoNZBuQ_t97OF8b5WEs3YxzuMjxpcwJTQUicMyz7_gtTxWevzdwr7nGk84neAE7KMTcjMcqBo2DaI1Jru70AaVKmBdGwsg633BUzoXSVu3wTOFQaajY6JtE2nSjvp7ceU.KTkT1si0NlHEuAwFDjMyLIHh_zMJWnjHA4PIA0d7M4c&dib_tag=se&keywords=Milk&qid=1723285878&sr=8-7",
    "https://www.amazon.com/Arrowhead-Mountain-Spring-Water-Gallon/dp/B000GECERM/ref=sr_1_8?crid=18K51DPFO4HAE&dib=eyJ2IjoiMSJ9.fdIAKHyPHhxIqODYZRMsUCiLrmL2mOZSFcWpmnzblS7QzacPRLJSeeZY5BGmYPIaG_5iMsNmiPlqhKVibz85UrBT0nZYA7TGVsa7ed0M50c-gt4v_KlxiBWitDVuJGpzzGH6NGiU3hc2x3cmK8qiM-0Uh7QDMIVlY2Vhq_DM6w0YZ5eX8oq0jrNIi3CUMcXjMFiIHsk2hoZj5vPm7U-MwAgX5nL-iLBKw9GwksK1kruMYHaGsjiaTsqgtV6EjFexMy5B9ZzJE8nLnWfpS_XyW02AJpGrY5o_KbVokoJx6lE.zJkmAxu6wjiMgoWmGYtfHLkmOB8E_25014-OYLfM1Ts&dib_tag=se&keywords=water&qid=1723288987&sprefix=wate%2Caps%2C544&sr=8-8",
   "https://www.amazon.com/Oral-B-Black-Pro-1000-Rechargeable/dp/B01AKGRTUM/ref=sr_1_3?crid=SXJKZCLRNAO6&dib=eyJ2IjoiMSJ9.U6dBd5B-SBEL3cOd11dje1B8FqkMEmsuLfLtpSdu33zNnFtuPyOkDZDMGy5DGyV6OeA4baqKRoNOdyYWIy59m02QRdwAiCsQTKRnRz3c0hEOrA4HRV-qceRUodDNl44-r-IjHzi_c_OZGiyWXqGyBctAVcBye0dkzkjv_5b7boHtqnRF9pkbLlB_hzpJQx_VrXwJD0ZWkq0-i53CzjFIsZbZkkVtnI5ZkYtSMDXMSfc-K-6VWe8p5vqnlTnHNrmB1wYOK4mzKqljhYMNCdB1UIiD2N1ekjiwIGgCUiUBjAQ.2ONXw4opgzw7Ex2clvXnWVJt8HHDRdsYNv3-ogZ7MYo&dib_tag=se&keywords=electronic&qid=1723289093&sprefix=electronic%2Caps%2C480&sr=8-3",
    "https://www.amazon.com/Pure-Life-Purified-Plastic-Bottled/dp/B0C3LK9KCV/ref=sr_1_2?crid=18K51DPFO4HAE&dib=eyJ2IjoiMSJ9.fdIAKHyPHhxIqODYZRMsUCiLrmL2mOZSFcWpmnzblS7QzacPRLJSeeZY5BGmYPIaG_5iMsNmiPlqhKVibz85UrBT0nZYA7TGVsa7ed0M50c-gt4v_KlxiBWitDVuJGpzzGH6NGiU3hc2x3cmK8qiM-0Uh7QDMIVlY2Vhq_DM6w0YZ5eX8oq0jrNIi3CUMcXjMFiIHsk2hoZj5vPm7U-MwAgX5nL-iLBKw9GwksK1kruMYHaGsjiaTsqgtV6EjFexMy5B9ZzJE8nLnWfpS_XyW02AJpGrY5o_KbVokoJx6lE.zJkmAxu6wjiMgoWmGYtfHLkmOB8E_25014-OYLfM1Ts&dib_tag=se&keywords=water&qid=1723286578&sprefix=wate%2Caps%2C544&sr=8-2",
    "https://www.amazon.com/Walkers-Game-Ear-GWP-RSEMPAT-FDE-Electronic/dp/B01MR1JV4E/ref=sr_1_6?dib=eyJ2IjoiMSJ9.U6dBd5B-SBEL3cOd11dje1B8FqkMEmsuLfLtpSdu33zNnFtuPyOkDZDMGy5DGyV6OeA4baqKRoNOdyYWIy59m02QRdwAiCsQTKRnRz3c0hEOrA4HRV-qceRUodDNl44-r-IjHzi_c_OZGiyWXqGyBctAVcBye0dkzkjv_5b7boHtqnRF9pkbLlB_hzpJQx_VrXwJD0ZWkq0-i53CzjFIsZbZkkVtnI5ZkYtSMDXMSfc-K-6VWe8p5vqnlTnHNrmB1wYOK4mzKqljhYMNCdB1UIiD2N1ekjiwIGgCUiUBjAQ.2ONXw4opgzw7Ex2clvXnWVJt8HHDRdsYNv3-ogZ7MYo&dib_tag=se&keywords=electronic&qid=1723289118&sr=8-6",
  ];

  List<Map<String, String>> scrapedData = [];

  Future<void> scrapeUrls() async {
    final random = Random();
    List<String> selectedUrls = (List<String>.from(urls)..shuffle()).take(6).toList();

    List<Map<String, String>> tempData = [];

    for (String url in selectedUrls) {
      print('Scraping URL: $url');

      final response = await http.post(
        Uri.parse('https://68ff-223-123-97-182.ngrok-free.app/scrape'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        tempData.add(Map<String, String>.from(jsonDecode(response.body)));
      } else {
        tempData.add({'error': 'Failed to scrape the URL'});
      }
    }

    setState(() {
      scrapedData = tempData;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchHateSpeechUrl();
    scrapeUrls();

  }




  Future<void> _fetchHateSpeechUrl() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Servers').doc('OMxQK5AV5KbtA855DBcN').get();
      setState(() {
        _facedetectionUrl = snapshot['Scraping'];
      });
      print('Hate Speech URL: $_facedetectionUrl');
    } catch (e) {
      print('Error fetching URL: $e');
    }
  }
  String _facedetectionUrl = '';
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns in grid
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.6, // Adjust as needed
                ),
                itemCount: scrapedData.length,
                itemBuilder: (context, index) {
                  final data = scrapedData[index];
                  return GestureDetector(
                    onTap: () {
                      _launchUrl(data['url'] ?? 'https://www.example.com');
                    },
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Center(
                              child: Image.network(
                                data['image_url'] ?? 'https://via.placeholder.com/150',
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ?? 1)
                                            : null,
                                      ),
                                    );
                                  }
                                },
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  return Center(child: Text('Failed to load image'));
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              data['title'] ?? 'No Title',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  'Price: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  data['price'] ?? 'No Price',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              data['description'] ?? 'No Description',
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}