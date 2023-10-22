import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAdds{

  InterstitialAd? interstitialAd;
  BannerAd? bannerAd;
  RewardedAd? rewardedAd;



  /// Loads an interstitial ad.
  void loadInterstialAd({bool showAfterLoad = false}) {
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/1033173712'
        : 'ca-app-pub-3940256099942544/4411468910';

    InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            interstitialAd = ad;
            if (showAfterLoad ) showIntersitialAd();
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  void showIntersitialAd(){
    if(interstitialAd != null){
     interstitialAd!.show();
    }
  }

  /// Loads a banner ad.
  void loadBannerAd({required VoidCallback adLoaded}) {
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716';
    bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          bannerAd = ad as BannerAd;
          adLoaded();
        },
        onAdFailedToLoad: (ad, err) {
          print('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }
/*
  /// Loads a rewarded ad.
  void loadRewardedAd() {
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/5224354917'
        : 'ca-app-pub-3940256099942544/1712485313';
    RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(), rewardedAdLoadCallback: null
      ,

    );
  }

*/



}