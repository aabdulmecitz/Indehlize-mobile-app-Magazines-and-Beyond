import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../google_adds/google_adds.dart';
import 'MyLibraryScreen.dart';

class AddMagazineScreen extends StatefulWidget {

  const AddMagazineScreen({Key? key}) : super(key: key);



  @override
  State<AddMagazineScreen> createState() => _AddMagazineScreenState();
}

class _AddMagazineScreenState extends State<AddMagazineScreen> {

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;

  bool isDrawerOpen = false;

  bool _uploading = false; // progress indicator durumunu tutan bir bool değişkeni

  var imageUri;

  File? selectedImage;

  final _formKey = GlobalKey<FormState>();

  String? _magazinePath;

  late String _coverImagePath;

  var magazineNameController = TextEditingController();
  var editorNameController = TextEditingController();
  var designerNameController = TextEditingController();
  var descriptionController = TextEditingController();
  var tagsController = TextfieldTagsController();

  final storage = FirebaseStorage.instance;
  final coversRef = FirebaseStorage.instance.ref().child('magazine covers');
  final pdfsRef = FirebaseStorage.instance.ref().child('magazines pdfs');

  final GoogleAdds _googleBannerAdd  = GoogleAdds();
  final GoogleAdds _googleInterstrialAdd  = GoogleAdds();

  var magazineNameSTR;
  var editorNameSTR;
  var designerNameSTR;
  var descriptionSTR = 'There is no description...';
  var selectedCategorySTR;

  late File coverFile;
  late File pdfFile;

  int _textLength = 0;

  List<String> labels = [];

  List<String> categoryList = [
    'Astroloji',
    'Bilim',
    'Çocuk',
    'Dekorasyon',
    'Dini',
    'Doğa',
    'Edebiyat',
    'Eğitim',
    'Ekonomi',
    'Erkek',
    'Felsefe',
    'Hayvan',
    'Hobi',
    'Kadın',
    'Kültür',
    'Matematik',
    'Moda',
    'Mizah',
    'Müzik',
    'Politika',
    'Psikoloji',
    'Sağlık',
    'Sanat',
    'Seyahat',
    'Sinema',
    'Spor',
    'Teknoloji',
    'Tarih',
    'Yaşam',
    'Yemek',
    'Diger',
  ];

  String? selectedCategory;

  var _distanceToField;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    super.dispose();
    tagsController.dispose();
  }

  @override
  void initState() {
    super.initState();
    tagsController = TextfieldTagsController();
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget> [
            appbar(),
            bodyBuilder(),
          ],
        ),
      ),
      bottomNavigationBar: _googleBannerAdd.bannerAd == null
          ? Container()
          : screenBannerAdd(),
    );

  }

  Widget bodyBuilder() {
    return _uploading ?
    Center(
      // _uploading true ise, progress indicator ve mesaj gösterir
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text("Dergi yükleniyor... Lütfen bekleyin..."),
        ],
      ),
    ) : Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: (){
                        _requestPermissionForCoverImage();
                      },
                      child: Container(
                        height: 200,
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: selectedImage != null
                            ? Image.file(selectedImage!)
                            : const Icon(Icons.add_a_photo),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: SizedBox(
                      width: 150,
                      child: _magazinePath == null
                        ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal
                        ),
                        onPressed: (){
                          _requestPermissionForMagazine();
                        },
                        child: Center(
                          child: SizedBox(
                            child: Row(children: [
                                    Icon(Icons.add_circle_outline),
                                    SizedBox(width: 3),
                                    Text("Select a Magazine", style: TextStyle(fontSize: 11),),
                              ]),
                          ),
                        ),
                      )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green
                              ),
                              onPressed: (){
                                _requestPermissionForMagazine();
                              },
                              child: Center(
                                child: SizedBox(
                                  child: Row(children: [
                                    Icon(Icons.add_circle),
                                    SizedBox(width: 3),
                                    Text("Select a Magazine", style: TextStyle(fontSize: 11),),
                                  ]),
                                ),
                              ),
                      )
                    ),
                  ),
                ],
              ),
              metaDatas(),
            ],
          ),
          magazineDescripton(),
          tagsWidget(),
          publishButton(),
        ],
      ),
    );
  }

  Widget metaDatas() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      width: 190, height: 260,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              buildMagazineName(),
              editorName(),
              designerName(),
              SizedBox(height: 7,),
              buttonSelectACategory(),
            ],
          ),
        ),
      ),
  );

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

  Widget editorName() {
    return TextFormField(
      controller: editorNameController,
      decoration: const InputDecoration(labelText: 'Editor Name'),
      onSaved: (value) {
        if (value == null || value.isEmpty || value.toString().trim() == "") {
          editorNameSTR = "Anonymous";
        }else{
          editorNameSTR = value.toString();
        }
      },
    );
  }

  Widget designerName() => TextFormField(
    controller: designerNameController,
    decoration: const InputDecoration(labelText: 'Designer Name'),
    onSaved: (value) {
      if (value == null || value.isEmpty || value.toString().trim() == "") {
        designerNameSTR = "Anonymous";
      }else{
        designerNameSTR = value.toString();
      }
    },
  );

  Widget buildMagazineName() => TextFormField(
    controller: magazineNameController,
    decoration: const InputDecoration(labelText: 'Magazine Name'),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Magazine Name cant be empty';
      }
      return null;
    },
    onSaved: (value) {
      magazineNameSTR = value.toString();
    },
  );

  Future<void> _requestPermissionForMagazine() async {
    // Check if the permission is already granted
    if (await Permission.storage.request().isGranted) {
      // Permission is already granted, pick a PDF file
      _pickMagazine();
    } else {
      // Permission is not granted, show a detailed explanation
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('İzin Gerekli'),
            content: Text(
                'Uygulama dosyalarınıza erişmek ve dergi seçmek istiyor. Lütfen izin verin.'),
            actions: [
              TextButton(
                child: Text('Tamam'),
                onPressed: () {
                  // Request the permission again
                  Navigator.of(context).pop();
                  Permission.storage.request();
                },
              ),
              TextButton(
                child: Text('İptal'),
                onPressed: () {
                  // Close the dialog
                  Navigator.of(context).pop();
                },
              ),
            ],
          ));
    }
  }

  Future<void> _pickMagazine() async {
    // Use the file_picker package to pick a PDF file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    setState(() {
      if (result != null) {
        // Set the file path
        _magazinePath = result.files.single.path!;
        // Check the file size limit (30 MB)
        if (result.files.single.size > 30 * 1024 * 1024) {
          // Show a toast message if the file size is too large
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lütfen 30 MB\'dan küçük bir dergi seçin.')));
          // Reset the file path
        }
      } else {
        // No file was selected, show a message
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lütfen bir dergi seçin.')));
      }
    });
  }

  Future<void> _requestPermissionForCoverImage() async {
    // Check if the permission is already granted
    if (await Permission.storage.request().isGranted) {
      // Permission is already granted, pick an image from the gallery
      _pickCoverImage();
    } else {
      // Permission is not granted, show a detailed explanation
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('İzin Gerekli'),
            content: Text(
                'Uygulama galerinize erişmek ve dergi kapağı seçmek istiyor. Lütfen izin verin.'),
            actions: [
              TextButton(
                child: Text('Tamam'),
                onPressed: () {
                  // Request the permission again
                  Navigator.of(context).pop();
                  Permission.storage.request();
                },
              ),
              TextButton(
                child: Text('İptal'),
                onPressed: () {
                  // Close the dialog
                  Navigator.of(context).pop();
                },
              ),
            ],
          ));
    }
  }

  Future<void> _pickCoverImage() async {
    // Use the image_picker package to pick an image
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        // Set the image file path
        _coverImagePath = pickedFile.path;
        selectedImage = convertImagePathToFile(_coverImagePath);

      } else {
        // No image was selected, show a message
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lütfen bir resim seçin.')));
      }
    });
  }

  Future<void> _cropCoverImage() async {
    // Use the image_cropper package to crop the image
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _coverImagePath,
      compressQuality: 100,
      maxWidth: 700,
      maxHeight: 990,
      compressFormat: ImageCompressFormat.jpg,

      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Dergi Kapağı Kırp',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],

    );

    setState(() {
      if (croppedFile != null) {
        // Set the cropped image file path
        _coverImagePath = croppedFile.path;
      } else {
        // No image was cropped, show a message
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lütfen bir resim kırpın.')));
      }
    });
  }

  File? convertImagePathToFile(String coverImagePath) {
    return File(coverImagePath);
  }

  Widget publishButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal
      ),
      onPressed: (){
        _googleInterstrialAdd.showIntersitialAd();
        publishMagazine();
      },
      child: Text(
        "Publish"
      ),

    );
  }

  Widget buttonSelectACategory() {
    return DropdownButtonFormField<String>(
      // Seçilen kategoriyi gösterin
      value: selectedCategory,
      // Açılır menüdeki her bir kategori için bir widget oluşturun
      items: categoryList.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      // Kullanıcı bir kategori seçtiğinde, seçilen kategoriyi güncelleyin ve durumu ayarlayın
      onChanged: (category) {
        setState(() {
          selectedCategory = category;
        });
      },
      onSaved: (value) {
        selectedCategorySTR = value.toString();
      },
      // Kategori seçilmediğinde uyarı mesajı vermek için bir doğrulayıcı fonksiyon belirtin
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen bir kategori seçiniz';
        }
        return null;
      },
      hint: Text('select a category'),
    );
  }

  Future<void> submitForm() async {
    final form = _formKey.currentState; // GlobalKey<FormState> nesnesinin currentState özelliğini kullanın
    if (form!.validate()) { // form.validate() yöntemi, tüm TextFormField widget'larının validator fonksiyonlarını çağırır ve eğer hepsi null döndürürse true döndürür
      form.save(); // form.save() yöntemi, tüm TextFormField widget'larının onSaved fonksiyonlarını çağırır ve değerleri kaydeder
      // Burada formu göndermek için istediğiniz işlemleri yapabilirsiniz
    }
  }

  Widget tagsWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 5),
      child: TextFieldTags(
        textfieldTagsController: tagsController,
        initialTags:  [
          //tags w'll come here
        ],
        textSeparators: const [ ','],
        letterCase: LetterCase.normal,
        validator: (String tag) {
          /*if (tag == 'php') {
            return 'No, please just no';
          } else if (tagsController.getTags!.contains(tag)) {
            return 'you already entered that';
          }
          return null;*/
        },
        inputfieldBuilder:
            (context, tec, fn, error, onChanged, onSubmitted) {
          return ((context, sc, tags, onTagDelete) {
            return TextField(
              controller: tec,
              focusNode: fn,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.teal,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.teal,
                    width: 1.0,
                  ),
                ),
                helperText: 'Enter tags which is describing your magaine',
                helperStyle: const TextStyle(
                  color: Colors.teal,
                ),
                hintText: tagsController.hasTags ? '' : "Enter tag...",
                errorText: error,
                prefixIconConstraints:
                BoxConstraints(maxWidth: _distanceToField * 0.74),
                prefixIcon: tags.isNotEmpty
                    ? SingleChildScrollView(
                  controller: sc,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: tags.map((String tag) {
                        return Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                            color: Colors.teal,
                          ),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 5.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                child: Text(
                                  '#$tag',
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                                onTap: () {
                                  print("$tag selected");
                                },
                              ),
                              const SizedBox(width: 4.0),
                              InkWell(
                                child: const Icon(
                                  Icons.cancel,
                                  size: 14.0,
                                  color: Color.fromARGB(
                                      255, 233, 233, 233),
                                ),
                                onTap: () {
                                  onTagDelete(tag);
                                },
                              )
                            ],
                          ),
                        );
                      }).toList()),
                )
                    : null,
              ),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              maxLength: 500,
            );
          });
        },
      )
    );
  }

  Widget magazineDescripton() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Stack(
        children: <Widget>[
          Positioned(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Once upon a time ..."
                  ),
               //   maxLength: 2000,
                  maxLines: null,
                  onSaved: (value){

                    if (value == null || value.isEmpty || value.toString().trim() == "" || value.toString().length > 2000) {
                      return ;
                    }else{
                      descriptionSTR = value.toString();
                    }

                  },
                  onChanged: (value) {
                    setState(() {
                      _textLength = value.length;
                    });
                  },
                ),
              ),
            ),
          ),

          Positioned(
            right: 8,
            bottom: 8,
            child: Text(
              '$_textLength/2000',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _textLength > 2000
                      ? Colors.red
                      : Colors.grey,
                ),
            ),
          ),
        ]
      ),
    );
  }

  Future <void> publishMagazine() async {

    if ((_magazinePath != null) && (_coverImagePath != null)
        && (magazineNameSTR != null) && (designerNameSTR != null)
        && (editorNameSTR != null)){

      setState(() {
        _uploading = true;
      });
      /// reward add calling will be here
      await submitForm();
      await uploadMagazine();
      // await uploadMagazine().then((value) => show30snAdd);// dergi yükleme fonksiyonunu çağırır
      setState(() {
        _uploading = false;
      });

    } else {
      Fluttertoast.showToast(
          msg: "Soemthing went wrong. Check your datas.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
  }

  Future<void> uploadMagazine() async {
    File coverFile = File(_coverImagePath); // coverController dergi kapağının dosya yolu bilgisini tutan bir TextEditingController olsun
    File pdfFile = File(_magazinePath!); // pdfController dergi pdf'inin dosya yolu bilgisini tutan bir TextEditingController olsun

    final magazinesRef = FirebaseFirestore.instance.collection('magazines');
    final docRef = magazinesRef.doc(); // yeni bir belge referansı oluşturur, ancak henüz veritabanına kaydetmez
    String magazineId = docRef.id; // belge referansının id'sini alır

    // Dergi kapağını yükler
    final coverUploadTask = coversRef.child('$magazineId.png').putFile(coverFile);
    final coverDownloadUrl = await (await coverUploadTask).ref.getDownloadURL();

    // Dergi pdf'ini yükler
    final pdfUploadTask = pdfsRef.child('$magazineId.pdf').putFile(pdfFile);
    final pdfDownloadUrl = await (await pdfUploadTask).ref.getDownloadURL();

    // Kullanıcı bilgilerini alır
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String? userEmail = FirebaseAuth.instance.currentUser!.email;
  //  String? userName = FirebaseAuth.instance.currentUser!.displayName;

    // descriptionController derginin açıklamasını tutan bir TextEditingController olsun
    List<String> magazineTags = tagsController.getTags.toString().split(','); // Burası değişti.......

    // Belge verilerini oluşturur
    Map<String, dynamic> docData = {
      'cover': coverDownloadUrl,
      'pdf': pdfDownloadUrl,
      'name': magazineNameSTR,
      'editor': editorNameSTR,
      'designer': designerNameSTR,
      'category': selectedCategorySTR,
      'description': descriptionSTR,
      'tags': magazineTags,
      'user_id': userId,
      'user_email': userEmail,
  //    'user_name': userName,
      'created_at': FieldValue.serverTimestamp(),
    };

// Belgeyi veritabanına kaydeder
    await docRef.set(docData);

// Başarılı olduğuna dair bir mesaj gösterir
    Fluttertoast.showToast(
        msg: "Dergi başarıyla yüklendi!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
        fontSize: 16.0
    );
    // My library sayfasına gider
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyLibraryScreen()),
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

