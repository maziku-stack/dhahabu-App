// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dhahabu => 'Dhahabu';

  @override
  String get tagline => 'Biashara ya Dhahabu kwa Uwazi';

  @override
  String get version => 'v1.0.0';

  @override
  String get skip => 'Skip';

  @override
  String get continueText => 'Continue';

  @override
  String get getStarted => 'Get Started';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get submit => 'Submit';

  @override
  String get save => 'Save changes';

  @override
  String get close => 'Close';

  @override
  String get copyJson => 'Copy JSON';

  @override
  String get copied => 'Data export copied to clipboard';

  @override
  String get loading => 'Please wait…';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get onboardingTitle1 => 'Trade Gold Securely';

  @override
  String get onboardingDesc1 =>
      'Post your gold listings and easily connect with licensed dealers across Tanzania.';

  @override
  String get onboardingTitle2 => 'Verified Dealers';

  @override
  String get onboardingDesc2 =>
      'Every dealer is vetted and approved before purchasing, ensuring you trade with trusted partners.';

  @override
  String get onboardingTitle3 => 'Transparent Taxes & Receipts';

  @override
  String get onboardingDesc3 =>
      '7% royalty is automatically calculated and secure digital receipts are stored for every transaction.';

  @override
  String get splashSubtitle => 'Biashara ya Dhahabu kwa Uwazi';

  @override
  String get signIn => 'Sign in';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in with your email and password.';

  @override
  String get emailAddress => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get passwordMin8 => 'Password (at least 8 chars)';

  @override
  String get newUserPrompt => 'New user? ';

  @override
  String get register => 'Register';

  @override
  String get chooseRole => 'Choose role';

  @override
  String get roleSelectionSubtitle =>
      'Select how you will participate in the Dhahabu platform.';

  @override
  String get miner => 'Miner';

  @override
  String get dealer => 'Dealer';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String registerAs(String role) {
    return 'Registering as $role';
  }

  @override
  String get createAccount => 'Create account';

  @override
  String get completeDetails => 'Complete your details';

  @override
  String get fullName => 'Full name';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get privacyNoticeAgreement =>
      'I have read and agree to the privacy notice';

  @override
  String get selectRoleError =>
      'Please select whether you are a Miner or Dealer.';

  @override
  String get privacyAckError =>
      'Read and acknowledge the privacy notice to continue.';

  @override
  String get roleNotSpecified =>
      'Role not specified. Please go back and select a role.';

  @override
  String get passwordsDoNotMatch => 'The passwords do not match.';

  @override
  String get validatorEmailRequired => 'Enter your email address.';

  @override
  String get validatorEmailValid => 'Enter a valid email address.';

  @override
  String get validatorPasswordRequired => 'Enter your password.';

  @override
  String get validatorPasswordLength =>
      'Use a password with at least 8 characters.';

  @override
  String get validatorPhoneValid => 'Enter a valid phone number.';

  @override
  String get validatorNameRequired => 'Enter your full name.';

  @override
  String get navHome => 'Home';

  @override
  String get navListings => 'Listings';

  @override
  String get navSales => 'Sales';

  @override
  String get navProfile => 'Profile';

  @override
  String get navOverview => 'Overview';

  @override
  String get navDealers => 'Dealers';

  @override
  String get navAudit => 'Audit';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get minerDashboard => 'Miner Dashboard';

  @override
  String get dealerDashboard => 'Dealer Dashboard';

  @override
  String get govDashboard => 'Government Dashboard';

  @override
  String get goldMarket => 'Gold Market';

  @override
  String get government => 'GOVERNMENT';

  @override
  String get recordSaleTooltip => 'Record a sale';

  @override
  String get recentSales => 'Recent Sales';

  @override
  String totalCount(int count) {
    return '$count total';
  }

  @override
  String governmentCharge(String status) {
    return 'Government charge: $status';
  }

  @override
  String paymentStatus(String status) {
    return 'Payment: $status';
  }

  @override
  String get notAssessed => 'not assessed';

  @override
  String get notStarted => 'not started';

  @override
  String get viewReceipt => 'View receipt';

  @override
  String get portfolioSummary => 'PORTFOLIO SUMMARY';

  @override
  String get dealerPortfolioSummary => 'DEALER PORTFOLIO SUMMARY';

  @override
  String get active => 'Active';

  @override
  String get totalSalesValue => 'Total Sales Value';

  @override
  String get goldSold => 'Gold Sold';

  @override
  String get totalPurchases => 'Total Purchases';

  @override
  String get goldAcquired => 'Gold Acquired';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get awaiting => 'Awaiting';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String get govOversightSubtitle => 'Government oversight and compliance';

  @override
  String get goldMarketOverviewSubtitle => 'Overview and portfolio';

  @override
  String get minerOverviewSubtitle =>
      'Manage your listings and sales portfolio';

  @override
  String get dealerLicensedSubtitle => 'Licensed gold buyer';

  @override
  String get browseListings => 'Browse Listings';

  @override
  String get myListings => 'My Listings';

  @override
  String get createListing => 'Create a listing';

  @override
  String get noOpenListings => 'No open listings';

  @override
  String get myListingsEmptyDesc =>
      'Listings you publish will appear here. Use the + button below to create one.';

  @override
  String get browseListingsEmptyDesc =>
      'Open gold listings from verified miners will appear here.';

  @override
  String get sharePhoneOnListing => 'Share phone on listing';

  @override
  String get sellerPhonePrivate => 'Seller phone is private.';

  @override
  String contactSeller(String phone) {
    return 'Contact: $phone';
  }

  @override
  String get createNewListing => 'Create New Listing';

  @override
  String get weightGrams => 'Weight (grams)';

  @override
  String get karat => 'Karat';

  @override
  String get askingPriceTzs => 'Asking price (TZS total)';

  @override
  String get notes => 'Notes';

  @override
  String get showPhoneOnListing => 'Show my phone number on this listing';

  @override
  String get showPhoneSubtitle =>
      'Only logged-in users browsing listings can see it. Off by default.';

  @override
  String get publishListing => 'Publish listing';

  @override
  String get sales => 'Sales';

  @override
  String get confirmWithPinTitle => 'Confirm with your PIN';

  @override
  String get accountPin => 'Account PIN';

  @override
  String get confirmSale => 'Confirm sale';

  @override
  String get agreeToSaleAndSign => 'Agree to sale & sign';

  @override
  String get noSalesYet => 'No sales yet';

  @override
  String get noSalesDesc =>
      'Sales you record or confirm will appear here with their receipts. Use the + button below to record a new sale.';

  @override
  String get recordASale => 'Record a sale';

  @override
  String get saleDetailsPrompt =>
      'Enter the details agreed with the other party. Both of you must confirm with your PIN to finalize the sale.';

  @override
  String get counterpartyPhone => 'Counterparty phone';

  @override
  String get weight => 'Weight';

  @override
  String get pricePerGram => 'Price per gram';

  @override
  String get selfReportedNote =>
      'Weight and karat are self-reported until an approved assay device or provider is connected.';

  @override
  String get agreedSaleValue => 'Agreed sale value';

  @override
  String get agreedSaleValueDesc =>
      'This is the price agreed by both parties. Official government charges and receipts will be generated automatically.';

  @override
  String get submitSale => 'Submit sale';

  @override
  String get saleCreatedSnackbar =>
      'Sale created. Both parties must confirm to finalize it.';

  @override
  String get receipt => 'Receipt';

  @override
  String get saleConfirmed => 'Sale confirmed';

  @override
  String get waitingForConfirmation => 'Waiting for confirmation';

  @override
  String get bothPartiesMustConfirmNote =>
      'Both the miner and the dealer must open Sales and confirm with their own PIN.';

  @override
  String transactionId(String id) {
    return 'Transaction $id';
  }

  @override
  String get parties => 'PARTIES';

  @override
  String get gold => 'GOLD';

  @override
  String get assayStatus => 'Assay status';

  @override
  String get unverified => 'unverified';

  @override
  String get verified => 'verified';

  @override
  String get measuredWeight => 'Measured weight';

  @override
  String get measuredKarat => 'Measured karat';

  @override
  String get measuredPurity => 'Measured purity';

  @override
  String get assayDevice => 'Assay device';

  @override
  String get assayReference => 'Assay reference';

  @override
  String get price => 'PRICE';

  @override
  String get priceBasis => 'Price basis';

  @override
  String get agreedPrice => 'Agreed price';

  @override
  String get governmentCharges => 'GOVERNMENT CHARGES';

  @override
  String get assessment => 'Assessment';

  @override
  String get unavailable => 'unavailable';

  @override
  String get payment => 'Payment';

  @override
  String get authorityReference => 'Authority reference';

  @override
  String get assessedAmount => 'Assessed amount';

  @override
  String get assessed => 'Assessed';

  @override
  String get legalBasis => 'Legal basis';

  @override
  String get paymentReference => 'Payment reference';

  @override
  String get agreement => 'AGREEMENT';

  @override
  String get recorded => 'Recorded';

  @override
  String get waiting => 'Waiting';

  @override
  String get downloadPdf => 'Download PDF (coming soon)';

  @override
  String get backToHome => 'Back to home';

  @override
  String get taxSummary => 'Tax Summary';

  @override
  String get assessedGovCharges => 'Assessed government charges';

  @override
  String confirmedTransactionsCount(int count) {
    return '$count confirmed transactions';
  }

  @override
  String get taxSummaryUnavailableNote =>
      'Authority assessment is not connected. This total includes assessed records only; it does not show payments collected.';

  @override
  String get govOverview => 'Government Overview';

  @override
  String get govOverviewSubtitle =>
      'A clear view of confirmed gold trade and royalties.';

  @override
  String get confirmedTransactions => 'Confirmed transactions';

  @override
  String get goldTraded => 'Gold traded';

  @override
  String get totalTradeValue => 'Total trade value';

  @override
  String get assessedChargesNotPayment => 'Assessed charges (not payment)';

  @override
  String get auditLog => 'Audit Log';

  @override
  String get dealerVerification => 'Dealer Verification';

  @override
  String get noPendingDealers => 'No pending dealers';

  @override
  String owner(String name) {
    return 'Owner: $name';
  }

  @override
  String phone(String phone) {
    return 'Phone: $phone';
  }

  @override
  String license(String license) {
    return 'License: $license';
  }

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutPrompt => 'Sign out?';

  @override
  String get signOutConfirm => 'You will need to sign in again to continue.';

  @override
  String get accountInfo => 'ACCOUNT INFO';

  @override
  String get region => 'Region';

  @override
  String get miningSite => 'Mining site';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get pending => 'Pending';

  @override
  String get settingsAndPrivacy => 'SETTINGS & PRIVACY';

  @override
  String get privacyAndDataPolicy => 'Privacy & Data Policy';

  @override
  String get appVersion => 'App Version';

  @override
  String get support => 'SUPPORT';

  @override
  String get feedbackAndSupport => 'Feedback & Support';

  @override
  String get officialTraNotConnected =>
      'Official TRA integration is not connected yet.';

  @override
  String get profileUpdated => 'Profile updated successfully!';

  @override
  String get required => 'Required';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get swahili => 'Swahili';

  @override
  String get feedbackInbox => 'Feedback Inbox';

  @override
  String get category => 'Category';

  @override
  String get feedback => 'Feedback';

  @override
  String get grievance => 'Grievance';

  @override
  String get subject => 'Subject';

  @override
  String get message => 'Message';

  @override
  String get feedbackSubmitted => 'Feedback submitted successfully.';

  @override
  String get allSubmissions => 'All Submissions';

  @override
  String get yourHistory => 'Your History';

  @override
  String get noFeedbackRecords => 'No feedback records found.';

  @override
  String reply(String reply) {
    return 'Reply: $reply';
  }

  @override
  String get respondResolve => 'Respond / resolve';

  @override
  String get resolveFeedback => 'Resolve feedback';

  @override
  String get responseOptional => 'Response (optional)';

  @override
  String get markResolved => 'Mark resolved';

  @override
  String get privacyAndData => 'Privacy and data';

  @override
  String get draftNotice =>
      'DRAFT — NOT READY FOR PRODUCTION. The operating entity, privacy contact, service providers, retention periods and legal terms still need confirmation.';

  @override
  String get dataWeCollect => 'Data we collect';

  @override
  String get dataCollectDesc =>
      'Account data: name, phone, email, account type and language; region and mining site are optional. We also process listing details, trade measurements and records, and dealer verification information. Passwords/PINs are stored as hashes; sign-in tokens are kept on your device.';

  @override
  String get useAndAccess => 'Use and access';

  @override
  String get useAndAccessDesc =>
      'Data supports accounts, listings, trades, security and support. A miner’s phone appears on a listing only when they choose to share it. Trade participants see relevant counterparty details. Authority access must have a lawful basis and approved integration; Mining Commission/TRA integrations are not connected yet.';

  @override
  String get retentionRights => 'Retention, providers and your rights';

  @override
  String get retentionRightsDesc =>
      'Retention periods, hosting/SMS/analytics providers, cross-border storage and the privacy officer’s contact still need confirmation. You can request access, correction, deletion, restriction or portability, or object to processing. Trade records may have legal retention requirements; a deletion request is reviewed and does not automatically erase such records.';

  @override
  String noticeVersionDesc(String version) {
    return 'Version $version. This product notice is a draft, not legal advice or a certification of compliance.';
  }

  @override
  String get useYourDataRights => 'Use your data rights';

  @override
  String get viewAndCopyDataExport => 'View and copy my data export';

  @override
  String get requestType => 'Request type';

  @override
  String get accessExport => 'Access / export';

  @override
  String get correctMyData => 'Correct my data';

  @override
  String get requestDeletion => 'Request deletion';

  @override
  String get restrictProcessing => 'Restrict processing';

  @override
  String get objectToProcessing => 'Object to processing';

  @override
  String get dataPortability => 'Data portability';

  @override
  String get withdrawConsent => 'Withdraw optional consent';

  @override
  String get detailsOptional => 'Details (optional)';

  @override
  String get submitRequestForReview => 'Submit request for review';

  @override
  String get requestsRecordedNote =>
      'Requests are recorded as received for an operator to review. This form does not automatically delete data.';

  @override
  String get yourDataExport => 'Your data export';

  @override
  String get dataExportCopied => 'Data export copied to clipboard';

  @override
  String get requestRecorded => 'Your request has been recorded for review.';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';
}
