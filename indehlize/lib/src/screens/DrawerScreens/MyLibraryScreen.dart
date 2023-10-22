import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:indehlize/main.dart';
import 'package:indehlize/src/google_adds/google_adds.dart';
import 'package:indehlize/src/screens/pdf_view_screen.dart';
import 'package:path_provider/path_provider.dart';


class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({Key? key}) : super(key: key);

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference magazineRef = FirebaseFirestore.instance.collection(
      'magazines');
  final FirebaseStorage storage = FirebaseStorage.instance;

  final GoogleAdds _googleBannerAdd  = GoogleAdds();
  final GoogleAdds _googleBannerAddMylib = GoogleAdds();
  final GoogleAdds _googleInterstrialAdd  = GoogleAdds();

  String? magazineName;
  var imageURL = "url";

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;

  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    // Load ads.

    _googleBannerAdd.loadBannerAd(adLoaded: () {
      setState(() {

      });
    });
    _googleBannerAddMylib.loadBannerAd(adLoaded: () {
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            appbar(),
            Center(child: bodyBuilder6()),
          ],
        ),
      ),
      bottomNavigationBar: _googleBannerAddMylib.bannerAd == null
      ? Container()
      : screenBannerAdd(),
    );
  }

  Widget bodyBuilder6() {
    return SizedBox(
      height: context.height,
      width: double.maxFinite,
      child: StreamBuilder<QuerySnapshot>(
        initialData: null,
        stream: firestore
            .collection('magazines')
            .where('user_id', isEqualTo: auth.currentUser!.uid)
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
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {

                  var magazineData = snapshot.data!.docs[index];

                  var coverImageUrl = magazineData['cover'];

                  var magazineUrl = magazineData['pdf'];


                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell( // <---- Burası değişti
                      onTap: () {
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
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: context.height, // Container'in yüksekliği
                        width: context.width, // Container'in genişliği
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.center, // Column'un hizalaması
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.network(
                                coverImageUrl,
                                height:
                                160, // Resmin yüksekliğini ayarlayın.
                                width:
                                90, // Resmin genişliğini ayarlayın.
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                    Icon(Icons.error),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
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
                'My Library',
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

  Future<Widget> downloadAndDeleteIconButton(String url) async {
    return IconButton(
      // Eğer dergi varsa silme ikonu, yoksa indirme ikonu göster
        icon: await checkPdf(url) ? Icon(Icons.delete) : Icon(Icons.download),
    // Eğer dergi varsa silme fonksiyonu, yoksa indirme fonksiyonu çağır
    onPressed: () async {
    await checkPdf(url) ? deletePdf(url) : downloadAndSavePdf(url);
    // Widget'ı yenile
    setState(() {});
    },
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

  Future<bool> checkPdf(String url) async {
    // Firebase storage referansını al
    Reference ref = storage.refFromURL(url);
    // Yerel dosya yolu oluştur
    final Directory directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/${ref.name}');
    // Dosyanın varlığını kontrol et
    return await file.exists();
  }

  Future<void> downloadOrDeletePdf(String url) async {
    // Derginin yerelde olup olmadığını kontrol et
    bool exists = await checkPdf(url);
    if (exists) {
      // Dergi yerelde varsa sil
      await deletePdf(url);

    } else {
      // Dergi yerelde yoksa indir ve sakla
      await downloadAndSavePdf(url);
      // Iconu değiştir (örnek olarak download iconu)
      setState(() {
        var icon = Icons.download;
      });
    }
  }

  Future<void> openPdf(String path) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewScreen(path: path),
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
