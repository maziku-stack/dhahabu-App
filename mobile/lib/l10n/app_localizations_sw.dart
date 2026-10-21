// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get dhahabu => 'Dhahabu';

  @override
  String get tagline => 'Biashara ya Dhahabu kwa Uwazi';

  @override
  String get version => 'v1.0.0';

  @override
  String get skip => 'Ruka';

  @override
  String get continueText => 'Endelea';

  @override
  String get getStarted => 'Anza';

  @override
  String get cancel => 'Ghairi';

  @override
  String get confirm => 'Thibitisha';

  @override
  String get submit => 'Wasilisha';

  @override
  String get save => 'Hifadhi mabadiliko';

  @override
  String get close => 'Funga';

  @override
  String get copyJson => 'Nakili JSON';

  @override
  String get copied => 'Hamisho la data limenakiliwa kwenye ubao wa klipu';

  @override
  String get loading => 'Tafadhali subiri…';

  @override
  String get error => 'Hitilafu';

  @override
  String get success => 'Mafanikio';

  @override
  String get onboardingTitle1 => 'Biashara Salama ya Dhahabu';

  @override
  String get onboardingDesc1 =>
      'Chapisha matangazo yako ya dhahabu na uunganishwe kwa urahisi na wafanyabiashara walioidhinishwa kote Tanzania.';

  @override
  String get onboardingTitle2 => 'Wafanyabiashara Walioidhinishwa';

  @override
  String get onboardingDesc2 =>
      'Kila mfanyabiashara hukaguliwa na kuidhinishwa kabla ya kununua, kuhakikisha unafanya biashara na washirika wanaoaminika.';

  @override
  String get onboardingTitle3 => 'Kodi na Stakabadhi za Uwazi';

  @override
  String get onboardingDesc3 =>
      'Royaliti ya 7% huhesabiwa kiotomatiki na stakabadhi salama za kidijitali huhifadhiwa kwa kila muamala.';

  @override
  String get splashSubtitle => 'Biashara ya Dhahabu kwa Uwazi';

  @override
  String get signIn => 'Ingia';

  @override
  String get welcomeBack => 'Karibu tena';

  @override
  String get signInSubtitle => 'Ingia kwa kutumia barua pepe na nenosiri lako.';

  @override
  String get emailAddress => 'Barua pepe';

  @override
  String get password => 'Nenosiri';

  @override
  String get passwordMin8 => 'Nenosiri (angalau herufi 8)';

  @override
  String get newUserPrompt => 'Mtumiaji mpya? ';

  @override
  String get register => 'Jisajili';

  @override
  String get chooseRole => 'Chagua jukumu';

  @override
  String get roleSelectionSubtitle =>
      'Chagua jinsi utakavyoshiriki kwenye jukwaa la Dhahabu.';

  @override
  String get miner => 'Mchimbaji';

  @override
  String get dealer => 'Mfanyabiashara';

  @override
  String get alreadyHaveAccount => 'Una akaunti tayari? ';

  @override
  String registerAs(String role) {
    return 'Jisajili kama $role';
  }

  @override
  String get createAccount => 'Fungua akaunti';

  @override
  String get completeDetails => 'Kamilisha maelezo yako';

  @override
  String get fullName => 'Jina kamili';

  @override
  String get phoneNumber => 'Namba ya simu';

  @override
  String get confirmPassword => 'Thibitisha nenosiri';

  @override
  String get privacyNoticeAgreement =>
      'Nimesoma na kukubaliana na taarifa ya faragha';

  @override
  String get acceptPrivacyNotice => 'Kubali na urudi';

  @override
  String get selectRoleError =>
      'Tafadhali chagua ikiwa wewe ni Mchimbaji au Mfanyabiashara.';

  @override
  String get privacyAckError =>
      'Soma na ukubali taarifa ya faragha ili kuendelea.';

  @override
  String get roleNotSpecified =>
      'Jukumu halijatajwa. Tafadhali rudi nyuma na uchague jukumu.';

  @override
  String get passwordsDoNotMatch => 'Manenosiri hayafanani.';

  @override
  String get validatorEmailRequired => 'Weka anwani yako ya barua pepe.';

  @override
  String get validatorEmailValid => 'Weka anwani sahihi ya barua pepe.';

  @override
  String get validatorPasswordRequired => 'Weka nenosiri lako.';

  @override
  String get validatorPasswordLength =>
      'Tumia nenosiri lenye angalau herufi 8.';

  @override
  String get validatorPhoneValid => 'Weka namba sahihi ya simu.';

  @override
  String get validatorNameRequired => 'Weka jina lako kamili.';

  @override
  String get navHome => 'Nyumbani';

  @override
  String get navListings => 'Matangazo';

  @override
  String get navSales => 'Mauzo';

  @override
  String get navProfile => 'Wasifu';

  @override
  String get navOverview => 'Muhtasari';

  @override
  String get navDealers => 'Wafanyabiashara';

  @override
  String get navAudit => 'Ukaguzi';

  @override
  String get notLoggedIn => 'Hujaingia kwenye akaunti';

  @override
  String get minerDashboard => 'Dashibodi ya Mchimbaji';

  @override
  String get dealerDashboard => 'Dashibodi ya Mfanyabiashara';

  @override
  String get govDashboard => 'Dashibodi ya Serikali';

  @override
  String get goldMarket => 'Soko la Dhahabu';

  @override
  String get indicativeReferenceTitle => 'Kiwango elekezi cha dhahabu';

  @override
  String get indicativeReferenceBasis =>
      'Makadirio ya soko la kimataifa la 24K · TZS kwa gramu';

  @override
  String get indicativeReferenceNotice =>
      'Ni kwa rejea tu. Si bei rasmi ya Tume ya Madini wala tathmini ya mauzo.';

  @override
  String indicativeReferenceUpdated(String goldTime, String fxDate) {
    return 'Dhahabu imesasishwa $goldTime · Tarehe ya FX $fxDate';
  }

  @override
  String get indicativeReferenceStale =>
      'Taarifa hii ya rejea huenda imepitwa na wakati.';

  @override
  String get indicativeReferenceUnavailable =>
      'Bei elekezi haipatikani kwa sasa.';

  @override
  String get government => 'SERIKALI';

  @override
  String get recordSaleTooltip => 'Rekodi mauzo';

  @override
  String get recentSales => 'Mauzo ya Hivi Karibuni';

  @override
  String totalCount(int count) {
    return 'Jumla $count';
  }

  @override
  String governmentCharge(String status) {
    return 'Ada ya serikali: $status';
  }

  @override
  String paymentStatus(String status) {
    return 'Malipo: $status';
  }

  @override
  String get notAssessed => 'haijathminiwa';

  @override
  String get notStarted => 'haijaanza';

  @override
  String get viewReceipt => 'Tazama stakabadhi';

  @override
  String get portfolioSummary => 'MUHTASARI WA PORTFOLIO';

  @override
  String get dealerPortfolioSummary =>
      'MUHTASARI WA PORTFOLIO YA MFANYABIASHARA';

  @override
  String get active => 'Hai';

  @override
  String get totalSalesValue => 'Jumla ya Thamani ya Mauzo';

  @override
  String get goldSold => 'Dhahabu Iliyouzwa';

  @override
  String get totalPurchases => 'Jumla ya Manunuzi';

  @override
  String get goldAcquired => 'Dhahabu Iliyopatikana';

  @override
  String get confirmed => 'Imethibitishwa';

  @override
  String get awaiting => 'Inasubiri';

  @override
  String welcomeUser(String name) {
    return 'Karibu, $name';
  }

  @override
  String get govOversightSubtitle => 'Usimamizi na utii wa serikali';

  @override
  String get goldMarketOverviewSubtitle => 'Muhtasari na portfolio';

  @override
  String get minerOverviewSubtitle =>
      'Simamia matangazo yako na portfolio ya mauzo';

  @override
  String get dealerLicensedSubtitle => 'Mnunuzi wa dhahabu aliyeidhinishwa';

  @override
  String get browseListings => 'Vinjari Matangazo';

  @override
  String get myListings => 'Matangazo Yangu';

  @override
  String get createListing => 'Unda tangazo';

  @override
  String get noOpenListings => 'Hakuna matangazo ya wazi';

  @override
  String get myListingsEmptyDesc =>
      'Matangazo unayochapisha yataonekana hapa. Tumia kitufe cha + hapa chini kuunda moja.';

  @override
  String get browseListingsEmptyDesc =>
      'Matangazo ya wazi ya dhahabu kutoka kwa wachimbaji waliothibitishwa yataonekana hapa.';

  @override
  String get sharePhoneOnListing => 'Shiriki namba ya simu kwenye tangazo';

  @override
  String get sellerPhonePrivate => 'Namba ya simu ya muuzaji ni ya faragha.';

  @override
  String contactSeller(String phone) {
    return 'Mawasiliano: $phone';
  }

  @override
  String get createNewListing => 'Unda Tangazo Jipya';

  @override
  String get weightGrams => 'Uzito (gramu)';

  @override
  String get karat => 'Karati';

  @override
  String get askingPriceTzs => 'Bei ya kuomba (Jumla ya TZS)';

  @override
  String get notes => 'Maelezo';

  @override
  String get showPhoneOnListing =>
      'Onyesha namba yangu ya simu kwenye tangazo hili';

  @override
  String get showPhoneSubtitle =>
      'Watumiaji walioingia tu ndio wanaoweza kuona. Imezimwa kwa chaguo-msingi.';

  @override
  String get publishListing => 'Chapisha tangazo';

  @override
  String get sales => 'Mauzo';

  @override
  String get confirmWithPinTitle => 'Thibitisha kwa PIN yako';

  @override
  String get accountPin => 'PIN ya Akaunti';

  @override
  String get confirmSale => 'Thibitisha mauzo';

  @override
  String get agreeToSaleAndSign => 'Kukubali mauzo na kusaini';

  @override
  String get noSalesYet => 'Hakuna mauzo bado';

  @override
  String get noSalesDesc =>
      'Mauzo unayorekodi au kuthibitisha yataonekana hapa na stakabadhi zake. Tumia kitufe cha + hapa chini kurekodi mauzo mapya.';

  @override
  String get recordASale => 'Rekodi mauzo';

  @override
  String get saleDetailsPrompt =>
      'Weka maelezo yaliyokubaliana na upande mwingine. Nyote wawili mnatakiwa kuthibitisha kwa PIN yenu ili kukamilisha mauzo.';

  @override
  String get counterpartyPhone => 'Namba ya simu ya upande mwingine';

  @override
  String get weight => 'Uzito';

  @override
  String get pricePerGram => 'Bei kwa gramu';

  @override
  String get selfReportedNote =>
      'Uzito na karati zinaripotiwa na wewe mwenyewe hadi kifaa au mtoa huduma aliyuidhinishwa aunganishwe.';

  @override
  String get agreedSaleValue => 'Thamani ya mauzo iliyokubaliwa';

  @override
  String get agreedSaleValueDesc =>
      'Hii ndiyo bei iliyokubaliwa na pande zote mbili. Ada rasmi za serikali na stakabadhi zitatolewa kiotomatiki.';

  @override
  String get submitSale => 'Wasilisha mauzo';

  @override
  String get saleCreatedSnackbar =>
      'Mauzo yameundwa. Pande zote mbili lazima zithibitishe ili kuyakamilisha.';

  @override
  String get receipt => 'Stakabadhi';

  @override
  String get saleConfirmed => 'Mauzo yamethibitishwa';

  @override
  String get waitingForConfirmation => 'Inasubiri uthibitisho';

  @override
  String get bothPartiesMustConfirmNote =>
      'Mchimbaji na mfanyabiashara lazima wafungue Sehemu ya Mauzo na wathibitishe kwa PIN zao wenyewe.';

  @override
  String transactionId(String id) {
    return 'Muamala $id';
  }

  @override
  String get parties => 'PANDE';

  @override
  String get gold => 'DHAHABU';

  @override
  String get assayStatus => 'Hali ya uchunguzi';

  @override
  String get unverified => 'haijathibitishwa';

  @override
  String get verified => 'imethibitishwa';

  @override
  String get measuredWeight => 'Uzito uliopimwa';

  @override
  String get measuredKarat => 'Karati iliyopimwa';

  @override
  String get measuredPurity => 'Usafi uliopimwa';

  @override
  String get assayDevice => 'Kifaa cha kupimia';

  @override
  String get assayReference => 'Rejea ya kupimia';

  @override
  String get price => 'BEI';

  @override
  String get priceBasis => 'Msingi wa bei';

  @override
  String get agreedPrice => 'Bei iliyokubaliwa';

  @override
  String get governmentCharges => 'ADA ZA SERIKALI';

  @override
  String get assessment => 'Tathmini';

  @override
  String get unavailable => 'haipatikani';

  @override
  String get payment => 'Malipo';

  @override
  String get authorityReference => 'Rejea ya mamlaka';

  @override
  String get assessedAmount => 'Kiasi kilichothaminiwa';

  @override
  String get assessed => 'Imethaminiwa';

  @override
  String get legalBasis => 'Msingi wa kisheria';

  @override
  String get paymentReference => 'Rejea ya malipo';

  @override
  String get agreement => 'MAKUBALIANO';

  @override
  String get recorded => 'Imerekodiwa';

  @override
  String get waiting => 'Inasubiri';

  @override
  String get downloadPdf => 'Pakua PDF (inakuja hivi karibuni)';

  @override
  String get backToHome => 'Rudi nyumbani';

  @override
  String get taxSummary => 'Muhtasari wa Kodi';

  @override
  String get assessedGovCharges => 'Ada za serikali zilizothaminiwa';

  @override
  String confirmedTransactionsCount(int count) {
    return 'Mikataba $count iliyothibitishwa';
  }

  @override
  String get taxSummaryUnavailableNote =>
      'Tathmini ya mamlaka haijaunganishwa. Jumla hii inajumuisha kumbukumbu zilizothaminiwa pekee; haionyeshi malipo yaliyokusanywa.';

  @override
  String get govOverview => 'Muhtasari wa Serikali';

  @override
  String get govOverviewSubtitle =>
      'Mtazamo wazi wa biashara ya dhahabu iliyothibitishwa na mrabaha.';

  @override
  String get confirmedTransactions => 'Mikataba iliyothibitishwa';

  @override
  String get goldTraded => 'Dhahabu iliyouzwa';

  @override
  String get totalTradeValue => 'Jumla ya thamani ya biashara';

  @override
  String get assessedChargesNotPayment => 'Ada zilizothaminiwa (si malipo)';

  @override
  String get auditLog => 'Kumbukumbu ya Ukaguzi';

  @override
  String get dealerVerification => 'Uthibitishaji wa Mfanyabiashara';

  @override
  String get noPendingDealers => 'Hakuna wafanyabiashara wanaosubiri';

  @override
  String owner(String name) {
    return 'Mmiliki: $name';
  }

  @override
  String phone(String phone) {
    return 'Simu: $phone';
  }

  @override
  String license(String license) {
    return 'Leseni: $license';
  }

  @override
  String get approve => 'Idhinisha';

  @override
  String get reject => 'Kataa';

  @override
  String get profile => 'Wasifu';

  @override
  String get editProfile => 'Hariri Wasifu';

  @override
  String get signOut => 'Ondoka';

  @override
  String get signOutPrompt => 'Ondoka kwenye akaunti?';

  @override
  String get signOutConfirm => 'Utahitaji kuingia tena ili kuendelea.';

  @override
  String get accountInfo => 'TAARIFA ZA AKAUNTI';

  @override
  String get region => 'Mkoa';

  @override
  String get miningSite => 'Eneo la uchimbaji';

  @override
  String get notSpecified => 'Haijatajwa';

  @override
  String get pending => 'Inasubiri';

  @override
  String get settingsAndPrivacy => 'MPANGILIO NA FARAGHA';

  @override
  String get privacyAndDataPolicy => 'Sera ya Faragha na Data';

  @override
  String get appVersion => 'Toleo la App';

  @override
  String get support => 'MSAADA';

  @override
  String get feedbackAndSupport => 'Maoni na Msaada';

  @override
  String get officialTraNotConnected =>
      'Ujumuishaji rasmi wa TRA bado haujaunganishwa.';

  @override
  String get profileUpdated => 'Wasifu umesasishwa kwa mafanikio!';

  @override
  String get required => 'Inahitajika';

  @override
  String get language => 'Lugha';

  @override
  String get english => 'Kiingereza';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get feedbackInbox => 'Kasha la Maoni';

  @override
  String get category => 'Kategoria';

  @override
  String get feedback => 'Maoni';

  @override
  String get grievance => 'Malalamiko';

  @override
  String get subject => 'Somo';

  @override
  String get message => 'Ujumbe';

  @override
  String get feedbackSubmitted => 'Maoni yamewasilishwa kwa mafanikio.';

  @override
  String get allSubmissions => 'Wasilisho Zote';

  @override
  String get yourHistory => 'Historia Yako';

  @override
  String get noFeedbackRecords => 'Hakuna kumbukumbu za maoni zilizopatikana.';

  @override
  String reply(String reply) {
    return 'Jibu: $reply';
  }

  @override
  String get respondResolve => 'Jibu / suluhisha';

  @override
  String get resolveFeedback => 'Suluhisha maoni';

  @override
  String get responseOptional => 'Jibu (si lazima)';

  @override
  String get markResolved => 'Weka kama imesuluhishwa';

  @override
  String get privacyAndData => 'Faragha na data';

  @override
  String get draftNotice =>
      'RASIMU — HAIJAKAMILIKA KWA UZALISHAJI. Shirika linaloendesha, mawasiliano ya faragha, watoa huduma, vipindi vya kuhifadhi na masharti ya kisheria bado yanahitaji uthibitisho.';

  @override
  String get dataWeCollect => 'Data tunayokusanya';

  @override
  String get dataCollectDesc =>
      'Data ya akaunti: jina, simu, barua pepe, aina ya akaunti na lugha; mkoa na eneo la uchimbaji ni vya hiari. Pia tunachakata maelezo ya matangazo, vipimo vya biashara na kumbukumbu, na taarifa za uthibitishaji wa mfanyabiashara. Nenosiri/PIN zinahifadhiwa kama hash; ishara za kuingia huwekwa kwenye kifaa chako.';

  @override
  String get useAndAccess => 'Matumizi na ufikiaji';

  @override
  String get useAndAccessDesc =>
      'Data inasaidia akaunti, matangazo, biashara, usalama na msaada. Namba ya simu ya mchimbaji inaonekana kwenye tangazo wakati tu anapochagua kuishiriki. Washiriki wa biashara wanaona maelezo husika ya upande mwingine. Ufikiaji wa mamlaka lazima uwe na msingi wa kisheria na ujumuishaji uliopitishwa; ujumuishaji wa Tume ya Madini/TRA bado haujaunganishwa.';

  @override
  String get retentionRights => 'Uhifadhi, watoa huduma na haki zako';

  @override
  String get retentionRightsDesc =>
      'Vipindi vya uhifadhi, watoa huduma za hosting/SMS/uchambuzi, uhifadhi wa mipakani na mawasiliano ya afisa faragha bado yanahitaji uthibitisho. Unaweza kuomba ufikiaji, urekebishaji, ufutaji, kuzuia au uhamishaji, au kupinga uchakataji. Kumbukumbu za biashara zinaweza kuwa na mahitaji ya kisheria ya uhifadhi; ombi la kufuta linakaguliwa na halifuti kiotomatiki kumbukumbu hizo.';

  @override
  String noticeVersionDesc(String version) {
    return 'Toleo $version. Taarifa hii ya bidhaa ni rasimu, si ushauri wa kisheria au cheti cha utii.';
  }

  @override
  String get useYourDataRights => 'Tumia haki zako za data';

  @override
  String get viewAndCopyDataExport =>
      'Tazama na unakili uhamisho wangu wa data';

  @override
  String get requestType => 'Aina ya ombi';

  @override
  String get accessExport => 'Fikia / hamisha';

  @override
  String get correctMyData => 'Sahihisha data yangu';

  @override
  String get requestDeletion => 'Omba kufutwa';

  @override
  String get restrictProcessing => 'Zuia uchakataji';

  @override
  String get objectToProcessing => 'Pingamizi la uchakataji';

  @override
  String get dataPortability => 'Uhamisho wa data';

  @override
  String get withdrawConsent => 'Ondoa idhini ya hiari';

  @override
  String get detailsOptional => 'Maelezo (si lazima)';

  @override
  String get submitRequestForReview => 'Wasilisha ombi kwa ukaguzi';

  @override
  String get requestsRecordedNote =>
      'Maombi yanarekodiwa kama yaliyopokelewa ili mwendeshaji ayakague. Fomu hii haifuti data kiotomatiki.';

  @override
  String get yourDataExport => 'Uhamisho wako wa data';

  @override
  String get dataExportCopied =>
      'Uhamisho wa data umenakiliwa kwenye ubao wa klipu';

  @override
  String get requestRecorded => 'Ombi lako limerekodiwa kwa ajili ya ukaguzi.';

  @override
  String get appearance => 'Muonekano';

  @override
  String get theme => 'Mandhari';

  @override
  String get lightTheme => 'Mwanga';

  @override
  String get darkTheme => 'Giza';

  @override
  String get systemTheme => 'Mfumo';
}
