import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:indehlize/src/screens/pdf_view_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

import '../../google_adds/google_adds.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;

  final GoogleAdds _googleBannerAdd  = GoogleAdds();
  final GoogleAdds _googleInterstrialAdd  = GoogleAdds();

  bool isSearchOpen = false;
  bool isDrawerOpen = false;

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
    return Column(
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        appBar(),
        Spacer(flex: 1),
        bodyBuilder2(),
        Spacer(flex: 2),
        _googleBannerAdd.bannerAd == null
            ? Container()
            : screenBannerAdd(),
      ],
    );
  }

  Widget appBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                child: Icon(Icons.menu),
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              Text(
                'indehlize',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    decoration: TextDecoration.none
                ),
              ),
              SizedBox(width: 22),

              /*IconButton(
                icon: Icon(Icons.search),
                onPressed: () async{
                  await showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(searchTerms),
                  );
                },
              ),*/
              
            ],
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Future<void> downloadAndSavePdf(String url) async {
    Reference ref = storage.refFromURL(url);
    Uint8List? data = await ref.getData();
    final Directory directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/${ref.name}');
    await file.writeAsBytes(data!, flush: true);
    await openPdf(file.path);
  }

  Future<void> deletePdf(String url) async {
    Reference ref = storage.refFromURL(url);
    final Directory directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/${ref.name}');
    await file.delete();
    _googleInterstrialAdd.showIntersitialAd();
  }

  Future<void> openPdf(String path) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewScreen(path: path),
      ),
    );
  }

  Widget bodyBuilder2(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recently',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 24,
        ),
        ),
        SizedBox(
          height: 40,
        ),
        Container(
          height: 400,
          child: StreamBuilder<QuerySnapshot>(
            initialData: null,
            stream: firestore
                .collection('magazines')
                .orderBy("created_at", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: SizedBox(
                        width: 50, height: 50,
                        child: CircularProgressIndicator())); // Veri yüklenene kadar bekleme göstergesi gösterin.
              } else if (snapshot.hasError) {
                return Text('Hata: ${snapshot.error}');
              } else {
                return RefreshIndicator( // Verileri yenilemek için pull-to-refresh özelliği ekleyin.
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: Expanded(
                    child: ScrollSnapList(
                      itemSize: 250,
                      onItemFocus: (index) {},
                      itemCount: snapshot.data!.docs.length,
                      dynamicItemSize: true, //Dinamik boyut etkinleştirme
                      dynamicSizeEquation: (distance) => 1 - (0.001 * distance.abs()),
                      itemBuilder: (context, index) {
                        // Firestore'dan gelen belgeyi alın
                        var magazineData = snapshot.data!.docs[index];

                        // Kapak resmi URL'sini alın
                        var coverImageUrl = magazineData['cover'];

                        //URL Alın
                        var magazineUrl = magazineData['pdf'];

                        return InkWell( // <---- Burası değişti
                          onTap: () {
                            // Dergiye tıkladığında modal bottom sheet aç
                            showModalBottomSheet(
                              elevation: 10,
                              backgroundColor: Colors.amber,
                              context: context,
                              builder: (context) {

                                return Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
                                          children: [
                                            Container(
                                                height: 200,
                                                width: 160,
                                                child: FittedBox(
                                                    fit: BoxFit.cover,
                                                    child: CachedNetworkImage(imageUrl: coverImageUrl, height: 200,)
                                                )
                                            ),
                                            SizedBox(width: 20,),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Container(
                                                height: 200,
                                                width: 180,
                                                child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          magazineData['name'],
                                                          // <---- Dergi başlığını göster
                                                          style: TextStyle(
                                                            fontSize: 24,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text("Created by ${magazineData['editor']}", style: TextStyle(fontStyle: FontStyle.italic),),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(magazineData['description'] ?? 'There is no description'),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )

                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.read_more),
                                            onPressed: () async {
                                              await downloadAndSavePdf(magazineUrl);
                                              _googleInterstrialAdd.showIntersitialAd();
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () async {
                                              await deletePdf(magazineUrl).then((value) => Fluttertoast.showToast(
                                                  msg: "The magazine has removed from your storage.",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.blueGrey,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0
                                              )).onError((error, stackTrace) =>
                                                  Fluttertoast.showToast(
                                                      msg: "The magazine already removed.",
                                                      toastLength: Toast.LENGTH_SHORT,
                                                      gravity: ToastGravity.CENTER,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor: Colors.blueGrey,
                                                      textColor: Colors.white,
                                                      fontSize: 16.0
                                                  ));
                                            },
                                          ),
                                          /*    IconButton(
                                        icon: Icon(Icons.share),
                                        onPressed: () async {
                                          //Share with your friends
                                        },
                                      ),*/

                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 90, // Container'in yüksekliği
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: CachedNetworkImage(
                                imageUrl: coverImageUrl,
                                height:
                                270, // Resmin yüksekliğini ayarlayın.
                                width:
                                180, // Resmin genişliğini ayarlayın.
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
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
