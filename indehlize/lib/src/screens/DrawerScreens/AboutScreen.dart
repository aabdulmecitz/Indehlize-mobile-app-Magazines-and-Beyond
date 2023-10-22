import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../google_adds/google_adds.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {

  final GoogleAdds _googleBannerAdd  = GoogleAdds();
  final GoogleAdds _googleInterstrialAdd  = GoogleAdds();

  final Uri instagramUrl = Uri.parse('https://www.instagram.com/_aabdulmecit_/');
  Uri githubUrl = Uri.parse('https://github.com/aabdulmecitz');
  Uri facebookUrl = Uri.parse('https://www.facebook.com/aabdulmecit/');
  Uri xUrl = Uri.parse('https://twitter.com/AbdulmecitAhmet');
  Uri youtubeUrl = Uri.parse('https://www.youtube.com/@aabdulmecitozkaya');
  Uri linkedinUrl = Uri.parse('https://www.linkedin.com/in/ahmetabdulmecitozkaya');
  Uri behanceUrl = Uri.parse('https://www.behance.net/aabdulmecitozkaya');


  @override
  void initState() {
    super.initState();
    // Load ads.

    _googleBannerAdd.loadBannerAd(adLoaded: () {
      setState(() {

      });
    });
    _googleInterstrialAdd.loadInterstialAd();
  }

  @override
  Widget build(BuildContext context) {

    var displayInfo = MediaQuery.of(context);
    final double displayHeight = displayInfo.size.height;
    final double displayWidth = displayInfo.size.width;

    return Scaffold(
      body: Column(
        children: <Widget> [
          appbar(),
          Spacer(),
          bodyBuilder(
              height: displayHeight * 0.6,
              width: displayWidth * 0.9
          ),
          Spacer(),
        ],
      ),
      bottomNavigationBar: _googleBannerAdd.bannerAd == null
          ? Container()
          : screenBannerAdd(),
    );
  }

  Widget appbar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                child: const Icon(Icons.arrow_back_ios),
                onTap: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              const Text(
                'Add Magazine',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    decoration: TextDecoration.none
                ),
              ),
              const SizedBox(),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget bodyBuilder({required double height, required double width}) {
    return Center(
      child: Container(
        height: height,
        width: width,
        child: Column(
          children: [
            Text(
              'Hello Dear Friend,\n\n'
                  "I'm Ahmet Abdülmecit Özkaya, \n\n"
                  "I've designed this magazine app for you. "
                  "Our app aims to provide free access to high-quality content for magazine enthusiasts. "
                  "This platform allows users to upload their own magazines and share this valuable content "
                  "while also providing the option to store them in a personal library.\n\n "
                  "Have a fun...\n\n\n\n\n\n"
                  "You can find me on social media",
              style: TextStyle(
                fontSize: 14, // Text size
                color: Colors.black, // Text color
                fontWeight: FontWeight.bold, // Bold text
                fontStyle: FontStyle.italic, // Italic text
                letterSpacing: 1.2, // Letter spacing
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                socialButton(url: instagramUrl, icon: const FaIcon(FontAwesomeIcons.instagram)),
                socialButton(url: xUrl, icon: const FaIcon(FontAwesomeIcons.twitter)),
                socialButton(url: linkedinUrl, icon: const FaIcon(FontAwesomeIcons.linkedin)),
                socialButton(url: githubUrl, icon: const FaIcon(FontAwesomeIcons.github)),
                socialButton(url: facebookUrl, icon: const FaIcon(FontAwesomeIcons.behance)),
                socialButton(url: youtubeUrl, icon: const FaIcon(FontAwesomeIcons.youtube)),
                socialButton(url: facebookUrl, icon: const FaIcon(FontAwesomeIcons.facebook)),
              ],
            )
          ],
        )
      ),
    ) ;
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

  Widget socialButton({required Uri url, required FaIcon icon}){
    return InkWell(
      onTap: (){
        _launchUrl(url: url);
      },
      child: icon,
    );
  }

  Future<void> _launchUrl({required Uri url}) async {
    !await launchUrl(url);
  }

}
