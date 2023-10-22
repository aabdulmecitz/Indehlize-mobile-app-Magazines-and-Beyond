import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../google_adds/google_adds.dart';

class PDFViewScreen extends StatefulWidget {
  const PDFViewScreen({super.key, required this.path});

  final String? path;

  @override
  State<PDFViewScreen> createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  final GoogleAdds _googleBannerAdd  = GoogleAdds();
  final GoogleAdds _googleInterstrialAdd  = GoogleAdds();

  late String filePath;

  @override
  void initState() {
    super.initState();
    filePath = widget.path!;
    // Load ads.
    _googleBannerAdd.loadBannerAd(adLoaded: () {
      setState(() {

      });
    });
    _googleInterstrialAdd.loadInterstialAd();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PDFView(
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageFling: false,
        filePath: filePath,
      ),
      appBar: AppBar(
        title: Text('Magazine'),
        backgroundColor: Colors.blueGrey,
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            _googleInterstrialAdd.showIntersitialAd();
            Navigator.pop(context);
          },
        ),
      ),
      bottomNavigationBar: _googleBannerAdd.bannerAd == null
          ? Container()
          : screenBannerAdd(),
    );
  }


  Widget pdfBodyBuilder() {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      child: Column(
        children: [
          PDFView(
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: false,
            filePath: filePath,
          ),
          _googleBannerAdd.bannerAd == null
              ? Container()
              : screenBannerAdd(),
        ],
      ),
    );
  }

  Widget screenBannerAdd(){
    return Container(
      child: _googleBannerAdd.bannerAd != null
          ? SizedBox(
        width: _googleBannerAdd.bannerAd!.size.width.toDouble(),
        height: _googleBannerAdd.bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _googleBannerAdd.bannerAd!),
      )
          : Container(
        height: 50,
        width: double.maxFinite,
        color: Colors.blue,
      ),
    );
  }

}
