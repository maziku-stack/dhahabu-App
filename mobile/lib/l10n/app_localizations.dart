import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw')
  ];

  /// No description provided for @dhahabu.
  ///
  /// In en, this message translates to:
  /// **'Dhahabu'**
  String get dhahabu;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Biashara ya Dhahabu kwa Uwazi'**
  String get tagline;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0'**
  String get version;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @copyJson.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get copyJson;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Data export copied to clipboard'**
  String get copied;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Trade Gold Securely'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Post your gold listings and easily connect with licensed dealers across Tanzania.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Verified Dealers'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Every dealer is vetted and approved before purchasing, ensuring you trade with trusted partners.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Transparent Taxes & Receipts'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'7% royalty is automatically calculated and secure digital receipts are stored for every transaction.'**
  String get onboardingDesc3;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Biashara ya Dhahabu kwa Uwazi'**
  String get splashSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your email and password.'**
  String get signInSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordMin8.
  ///
  /// In en, this message translates to:
  /// **'Password (at least 8 chars)'**
  String get passwordMin8;

  /// No description provided for @newUserPrompt.
  ///
  /// In en, this message translates to:
  /// **'New user? '**
  String get newUserPrompt;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @chooseRole.
  ///
  /// In en, this message translates to:
  /// **'Choose role'**
  String get chooseRole;

  /// No description provided for @roleSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select how you will participate in the Dhahabu platform.'**
  String get roleSelectionSubtitle;

  /// No description provided for @miner.
  ///
  /// In en, this message translates to:
  /// **'Miner'**
  String get miner;

  /// No description provided for @dealer.
  ///
  /// In en, this message translates to:
  /// **'Dealer'**
  String get dealer;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @registerAs.
  ///
  /// In en, this message translates to:
  /// **'Registering as {role}'**
  String registerAs(String role);

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @completeDetails.
  ///
  /// In en, this message translates to:
  /// **'Complete your details'**
  String get completeDetails;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @privacyNoticeAgreement.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the privacy notice'**
  String get privacyNoticeAgreement;

  /// No description provided for @selectRoleError.
  ///
  /// In en, this message translates to:
  /// **'Please select whether you are a Miner or Dealer.'**
  String get selectRoleError;

  /// No description provided for @privacyAckError.
  ///
  /// In en, this message translates to:
  /// **'Read and acknowledge the privacy notice to continue.'**
  String get privacyAckError;

  /// No description provided for @roleNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Role not specified. Please go back and select a role.'**
  String get roleNotSpecified;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @validatorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get validatorEmailRequired;

  /// No description provided for @validatorEmailValid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validatorEmailValid;

  /// No description provided for @validatorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get validatorPasswordRequired;

  /// No description provided for @validatorPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Use a password with at least 8 characters.'**
  String get validatorPasswordLength;

  /// No description provided for @validatorPhoneValid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number.'**
  String get validatorPhoneValid;

  /// No description provided for @validatorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name.'**
  String get validatorNameRequired;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get navListings;

  /// No description provided for @navSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get navSales;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get navOverview;

  /// No description provided for @navDealers.
  ///
  /// In en, this message translates to:
  /// **'Dealers'**
  String get navDealers;

  /// No description provided for @navAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get navAudit;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @minerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Miner Dashboard'**
  String get minerDashboard;

  /// No description provided for @dealerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dealer Dashboard'**
  String get dealerDashboard;

  /// No description provided for @govDashboard.
  ///
  /// In en, this message translates to:
  /// **'Government Dashboard'**
  String get govDashboard;

  /// No description provided for @goldMarket.
  ///
  /// In en, this message translates to:
  /// **'Gold Market'**
  String get goldMarket;

  /// **'Indicative gold reference'**
  String get indicativeReferenceTitle;

  /// **'24K international spot estimate · TZS per gram'**
  String get indicativeReferenceBasis;

  /// **'For reference only. Not an official Mining Commission price or sale assessment.'**
  String get indicativeReferenceNotice;

  /// **'Gold updated {goldTime} · FX date {fxDate}'**
  String indicativeReferenceUpdated(String goldTime, String fxDate);

  /// **'This reference data may be out of date.'**
  String get indicativeReferenceStale;

  /// **'Indicative reference price is unavailable.'**
  String get indicativeReferenceUnavailable;

  /// No description provided for @government.
  ///
  /// In en, this message translates to:
  /// **'GOVERNMENT'**
  String get government;

  /// No description provided for @recordSaleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Record a sale'**
  String get recordSaleTooltip;

  /// No description provided for @recentSales.
  ///
  /// In en, this message translates to:
  /// **'Recent Sales'**
  String get recentSales;

  /// No description provided for @totalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String totalCount(int count);

  /// No description provided for @governmentCharge.
  ///
  /// In en, this message translates to:
  /// **'Government charge: {status}'**
  String governmentCharge(String status);

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment: {status}'**
  String paymentStatus(String status);

  /// No description provided for @notAssessed.
  ///
  /// In en, this message translates to:
  /// **'not assessed'**
  String get notAssessed;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'not started'**
  String get notStarted;

  /// No description provided for @viewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View receipt'**
  String get viewReceipt;

  /// No description provided for @portfolioSummary.
  ///
  /// In en, this message translates to:
  /// **'PORTFOLIO SUMMARY'**
  String get portfolioSummary;

  /// No description provided for @dealerPortfolioSummary.
  ///
  /// In en, this message translates to:
  /// **'DEALER PORTFOLIO SUMMARY'**
  String get dealerPortfolioSummary;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @totalSalesValue.
  ///
  /// In en, this message translates to:
  /// **'Total Sales Value'**
  String get totalSalesValue;

  /// No description provided for @goldSold.
  ///
  /// In en, this message translates to:
  /// **'Gold Sold'**
  String get goldSold;

  /// No description provided for @totalPurchases.
  ///
  /// In en, this message translates to:
  /// **'Total Purchases'**
  String get totalPurchases;

  /// No description provided for @goldAcquired.
  ///
  /// In en, this message translates to:
  /// **'Gold Acquired'**
  String get goldAcquired;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @awaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting'**
  String get awaiting;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeUser(String name);

  /// No description provided for @govOversightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Government oversight and compliance'**
  String get govOversightSubtitle;

  /// No description provided for @goldMarketOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overview and portfolio'**
  String get goldMarketOverviewSubtitle;

  /// No description provided for @minerOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your listings and sales portfolio'**
  String get minerOverviewSubtitle;

  /// No description provided for @dealerLicensedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Licensed gold buyer'**
  String get dealerLicensedSubtitle;

  /// No description provided for @browseListings.
  ///
  /// In en, this message translates to:
  /// **'Browse Listings'**
  String get browseListings;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @createListing.
  ///
  /// In en, this message translates to:
  /// **'Create a listing'**
  String get createListing;

  /// No description provided for @noOpenListings.
  ///
  /// In en, this message translates to:
  /// **'No open listings'**
  String get noOpenListings;

  /// No description provided for @myListingsEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Listings you publish will appear here. Use the + button below to create one.'**
  String get myListingsEmptyDesc;

  /// No description provided for @browseListingsEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Open gold listings from verified miners will appear here.'**
  String get browseListingsEmptyDesc;

  /// No description provided for @sharePhoneOnListing.
  ///
  /// In en, this message translates to:
  /// **'Share phone on listing'**
  String get sharePhoneOnListing;

  /// No description provided for @sellerPhonePrivate.
  ///
  /// In en, this message translates to:
  /// **'Seller phone is private.'**
  String get sellerPhonePrivate;

  /// No description provided for @contactSeller.
  ///
  /// In en, this message translates to:
  /// **'Contact: {phone}'**
  String contactSeller(String phone);

  /// No description provided for @createNewListing.
  ///
  /// In en, this message translates to:
  /// **'Create New Listing'**
  String get createNewListing;

  /// No description provided for @weightGrams.
  ///
  /// In en, this message translates to:
  /// **'Weight (grams)'**
  String get weightGrams;

  /// No description provided for @karat.
  ///
  /// In en, this message translates to:
  /// **'Karat'**
  String get karat;

  /// No description provided for @askingPriceTzs.
  ///
  /// In en, this message translates to:
  /// **'Asking price (TZS total)'**
  String get askingPriceTzs;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @showPhoneOnListing.
  ///
  /// In en, this message translates to:
  /// **'Show my phone number on this listing'**
  String get showPhoneOnListing;

  /// No description provided for @showPhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only logged-in users browsing listings can see it. Off by default.'**
  String get showPhoneSubtitle;

  /// No description provided for @publishListing.
  ///
  /// In en, this message translates to:
  /// **'Publish listing'**
  String get publishListing;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @confirmWithPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm with your PIN'**
  String get confirmWithPinTitle;

  /// No description provided for @accountPin.
  ///
  /// In en, this message translates to:
  /// **'Account PIN'**
  String get accountPin;

  /// No description provided for @confirmSale.
  ///
  /// In en, this message translates to:
  /// **'Confirm sale'**
  String get confirmSale;

  /// No description provided for @agreeToSaleAndSign.
  ///
  /// In en, this message translates to:
  /// **'Agree to sale & sign'**
  String get agreeToSaleAndSign;

  /// No description provided for @noSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No sales yet'**
  String get noSalesYet;

  /// No description provided for @noSalesDesc.
  ///
  /// In en, this message translates to:
  /// **'Sales you record or confirm will appear here with their receipts. Use the + button below to record a new sale.'**
  String get noSalesDesc;

  /// No description provided for @recordASale.
  ///
  /// In en, this message translates to:
  /// **'Record a sale'**
  String get recordASale;

  /// No description provided for @saleDetailsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the details agreed with the other party. Both of you must confirm with your PIN to finalize the sale.'**
  String get saleDetailsPrompt;

  /// No description provided for @counterpartyPhone.
  ///
  /// In en, this message translates to:
  /// **'Counterparty phone'**
  String get counterpartyPhone;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @pricePerGram.
  ///
  /// In en, this message translates to:
  /// **'Price per gram'**
  String get pricePerGram;

  /// No description provided for @selfReportedNote.
  ///
  /// In en, this message translates to:
  /// **'Weight and karat are self-reported until an approved assay device or provider is connected.'**
  String get selfReportedNote;

  /// No description provided for @agreedSaleValue.
  ///
  /// In en, this message translates to:
  /// **'Agreed sale value'**
  String get agreedSaleValue;

  /// No description provided for @agreedSaleValueDesc.
  ///
  /// In en, this message translates to:
  /// **'This is the price agreed by both parties. Official government charges and receipts will be generated automatically.'**
  String get agreedSaleValueDesc;

  /// No description provided for @submitSale.
  ///
  /// In en, this message translates to:
  /// **'Submit sale'**
  String get submitSale;

  /// No description provided for @saleCreatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Sale created. Both parties must confirm to finalize it.'**
  String get saleCreatedSnackbar;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @saleConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Sale confirmed'**
  String get saleConfirmed;

  /// No description provided for @waitingForConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation'**
  String get waitingForConfirmation;

  /// No description provided for @bothPartiesMustConfirmNote.
  ///
  /// In en, this message translates to:
  /// **'Both the miner and the dealer must open Sales and confirm with their own PIN.'**
  String get bothPartiesMustConfirmNote;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction {id}'**
  String transactionId(String id);

  /// No description provided for @parties.
  ///
  /// In en, this message translates to:
  /// **'PARTIES'**
  String get parties;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'GOLD'**
  String get gold;

  /// No description provided for @assayStatus.
  ///
  /// In en, this message translates to:
  /// **'Assay status'**
  String get assayStatus;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'unverified'**
  String get unverified;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'verified'**
  String get verified;

  /// No description provided for @measuredWeight.
  ///
  /// In en, this message translates to:
  /// **'Measured weight'**
  String get measuredWeight;

  /// No description provided for @measuredKarat.
  ///
  /// In en, this message translates to:
  /// **'Measured karat'**
  String get measuredKarat;

  /// No description provided for @measuredPurity.
  ///
  /// In en, this message translates to:
  /// **'Measured purity'**
  String get measuredPurity;

  /// No description provided for @assayDevice.
  ///
  /// In en, this message translates to:
  /// **'Assay device'**
  String get assayDevice;

  /// No description provided for @assayReference.
  ///
  /// In en, this message translates to:
  /// **'Assay reference'**
  String get assayReference;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get price;

  /// No description provided for @priceBasis.
  ///
  /// In en, this message translates to:
  /// **'Price basis'**
  String get priceBasis;

  /// No description provided for @agreedPrice.
  ///
  /// In en, this message translates to:
  /// **'Agreed price'**
  String get agreedPrice;

  /// No description provided for @governmentCharges.
  ///
  /// In en, this message translates to:
  /// **'GOVERNMENT CHARGES'**
  String get governmentCharges;

  /// No description provided for @assessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get assessment;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'unavailable'**
  String get unavailable;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @authorityReference.
  ///
  /// In en, this message translates to:
  /// **'Authority reference'**
  String get authorityReference;

  /// No description provided for @assessedAmount.
  ///
  /// In en, this message translates to:
  /// **'Assessed amount'**
  String get assessedAmount;

  /// No description provided for @assessed.
  ///
  /// In en, this message translates to:
  /// **'Assessed'**
  String get assessed;

  /// No description provided for @legalBasis.
  ///
  /// In en, this message translates to:
  /// **'Legal basis'**
  String get legalBasis;

  /// No description provided for @paymentReference.
  ///
  /// In en, this message translates to:
  /// **'Payment reference'**
  String get paymentReference;

  /// No description provided for @agreement.
  ///
  /// In en, this message translates to:
  /// **'AGREEMENT'**
  String get agreement;

  /// No description provided for @recorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get recorded;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF (coming soon)'**
  String get downloadPdf;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @taxSummary.
  ///
  /// In en, this message translates to:
  /// **'Tax Summary'**
  String get taxSummary;

  /// No description provided for @assessedGovCharges.
  ///
  /// In en, this message translates to:
  /// **'Assessed government charges'**
  String get assessedGovCharges;

  /// No description provided for @confirmedTransactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} confirmed transactions'**
  String confirmedTransactionsCount(int count);

  /// No description provided for @taxSummaryUnavailableNote.
  ///
  /// In en, this message translates to:
  /// **'Authority assessment is not connected. This total includes assessed records only; it does not show payments collected.'**
  String get taxSummaryUnavailableNote;

  /// No description provided for @govOverview.
  ///
  /// In en, this message translates to:
  /// **'Government Overview'**
  String get govOverview;

  /// No description provided for @govOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A clear view of confirmed gold trade and royalties.'**
  String get govOverviewSubtitle;

  /// No description provided for @confirmedTransactions.
  ///
  /// In en, this message translates to:
  /// **'Confirmed transactions'**
  String get confirmedTransactions;

  /// No description provided for @goldTraded.
  ///
  /// In en, this message translates to:
  /// **'Gold traded'**
  String get goldTraded;

  /// No description provided for @totalTradeValue.
  ///
  /// In en, this message translates to:
  /// **'Total trade value'**
  String get totalTradeValue;

  /// No description provided for @assessedChargesNotPayment.
  ///
  /// In en, this message translates to:
  /// **'Assessed charges (not payment)'**
  String get assessedChargesNotPayment;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit Log'**
  String get auditLog;

  /// No description provided for @dealerVerification.
  ///
  /// In en, this message translates to:
  /// **'Dealer Verification'**
  String get dealerVerification;

  /// No description provided for @noPendingDealers.
  ///
  /// In en, this message translates to:
  /// **'No pending dealers'**
  String get noPendingDealers;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner: {name}'**
  String owner(String name);

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String phone(String phone);

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License: {license}'**
  String license(String license);

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutPrompt;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to continue.'**
  String get signOutConfirm;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT INFO'**
  String get accountInfo;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @miningSite.
  ///
  /// In en, this message translates to:
  /// **'Mining site'**
  String get miningSite;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @settingsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS & PRIVACY'**
  String get settingsAndPrivacy;

  /// No description provided for @privacyAndDataPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data Policy'**
  String get privacyAndDataPolicy;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get support;

  /// No description provided for @feedbackAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Feedback & Support'**
  String get feedbackAndSupport;

  /// No description provided for @officialTraNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Official TRA integration is not connected yet.'**
  String get officialTraNotConnected;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdated;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @swahili.
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get swahili;

  /// No description provided for @feedbackInbox.
  ///
  /// In en, this message translates to:
  /// **'Feedback Inbox'**
  String get feedbackInbox;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @grievance.
  ///
  /// In en, this message translates to:
  /// **'Grievance'**
  String get grievance;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @feedbackSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Feedback submitted successfully.'**
  String get feedbackSubmitted;

  /// No description provided for @allSubmissions.
  ///
  /// In en, this message translates to:
  /// **'All Submissions'**
  String get allSubmissions;

  /// No description provided for @yourHistory.
  ///
  /// In en, this message translates to:
  /// **'Your History'**
  String get yourHistory;

  /// No description provided for @noFeedbackRecords.
  ///
  /// In en, this message translates to:
  /// **'No feedback records found.'**
  String get noFeedbackRecords;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply: {reply}'**
  String reply(String reply);

  /// No description provided for @respondResolve.
  ///
  /// In en, this message translates to:
  /// **'Respond / resolve'**
  String get respondResolve;

  /// No description provided for @resolveFeedback.
  ///
  /// In en, this message translates to:
  /// **'Resolve feedback'**
  String get resolveFeedback;

  /// No description provided for @responseOptional.
  ///
  /// In en, this message translates to:
  /// **'Response (optional)'**
  String get responseOptional;

  /// No description provided for @markResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark resolved'**
  String get markResolved;

  /// No description provided for @privacyAndData.
  ///
  /// In en, this message translates to:
  /// **'Privacy and data'**
  String get privacyAndData;

  /// No description provided for @draftNotice.
  ///
  /// In en, this message translates to:
  /// **'DRAFT — NOT READY FOR PRODUCTION. The operating entity, privacy contact, service providers, retention periods and legal terms still need confirmation.'**
  String get draftNotice;

  /// No description provided for @dataWeCollect.
  ///
  /// In en, this message translates to:
  /// **'Data we collect'**
  String get dataWeCollect;

  /// No description provided for @dataCollectDesc.
  ///
  /// In en, this message translates to:
  /// **'Account data: name, phone, email, account type and language; region and mining site are optional. We also process listing details, trade measurements and records, and dealer verification information. Passwords/PINs are stored as hashes; sign-in tokens are kept on your device.'**
  String get dataCollectDesc;

  /// No description provided for @useAndAccess.
  ///
  /// In en, this message translates to:
  /// **'Use and access'**
  String get useAndAccess;

  /// No description provided for @useAndAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Data supports accounts, listings, trades, security and support. A miner’s phone appears on a listing only when they choose to share it. Trade participants see relevant counterparty details. Authority access must have a lawful basis and approved integration; Mining Commission/TRA integrations are not connected yet.'**
  String get useAndAccessDesc;

  /// No description provided for @retentionRights.
  ///
  /// In en, this message translates to:
  /// **'Retention, providers and your rights'**
  String get retentionRights;

  /// No description provided for @retentionRightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Retention periods, hosting/SMS/analytics providers, cross-border storage and the privacy officer’s contact still need confirmation. You can request access, correction, deletion, restriction or portability, or object to processing. Trade records may have legal retention requirements; a deletion request is reviewed and does not automatically erase such records.'**
  String get retentionRightsDesc;

  /// No description provided for @noticeVersionDesc.
  ///
  /// In en, this message translates to:
  /// **'Version {version}. This product notice is a draft, not legal advice or a certification of compliance.'**
  String noticeVersionDesc(String version);

  /// No description provided for @useYourDataRights.
  ///
  /// In en, this message translates to:
  /// **'Use your data rights'**
  String get useYourDataRights;

  /// No description provided for @viewAndCopyDataExport.
  ///
  /// In en, this message translates to:
  /// **'View and copy my data export'**
  String get viewAndCopyDataExport;

  /// No description provided for @requestType.
  ///
  /// In en, this message translates to:
  /// **'Request type'**
  String get requestType;

  /// No description provided for @accessExport.
  ///
  /// In en, this message translates to:
  /// **'Access / export'**
  String get accessExport;

  /// No description provided for @correctMyData.
  ///
  /// In en, this message translates to:
  /// **'Correct my data'**
  String get correctMyData;

  /// No description provided for @requestDeletion.
  ///
  /// In en, this message translates to:
  /// **'Request deletion'**
  String get requestDeletion;

  /// No description provided for @restrictProcessing.
  ///
  /// In en, this message translates to:
  /// **'Restrict processing'**
  String get restrictProcessing;

  /// No description provided for @objectToProcessing.
  ///
  /// In en, this message translates to:
  /// **'Object to processing'**
  String get objectToProcessing;

  /// No description provided for @dataPortability.
  ///
  /// In en, this message translates to:
  /// **'Data portability'**
  String get dataPortability;

  /// No description provided for @withdrawConsent.
  ///
  /// In en, this message translates to:
  /// **'Withdraw optional consent'**
  String get withdrawConsent;

  /// No description provided for @detailsOptional.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get detailsOptional;

  /// No description provided for @submitRequestForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit request for review'**
  String get submitRequestForReview;

  /// No description provided for @requestsRecordedNote.
  ///
  /// In en, this message translates to:
  /// **'Requests are recorded as received for an operator to review. This form does not automatically delete data.'**
  String get requestsRecordedNote;

  /// No description provided for @yourDataExport.
  ///
  /// In en, this message translates to:
  /// **'Your data export'**
  String get yourDataExport;

  /// No description provided for @dataExportCopied.
  ///
  /// In en, this message translates to:
  /// **'Data export copied to clipboard'**
  String get dataExportCopied;

  /// No description provided for @requestRecorded.
  ///
  /// In en, this message translates to:
  /// **'Your request has been recorded for review.'**
  String get requestRecorded;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
