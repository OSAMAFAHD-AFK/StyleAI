/// English strings — swap implementation later for intl / ARB without touching UI.
abstract final class AppStrings {
  // Brand
  static const String appName = 'StyleAI';
  static const String tagline = 'Your Global Fashion Match Engine';

  // Splash & auth
  static const String loginWithGoogle = 'Login with Google';

  // Profile setup
  static const String welcomeTitle = "Let's tailor your StyleAI!";
  static const String welcomeSubtitle =
      'We help you find your favorite pieces and their alternatives smartly.';
  static const String yourName = 'Your Name';
  static const String nameHint = 'Enter your name';
  static const String nameRequired = 'Please enter your name to continue';
  static const String whoAreYou = 'Who are you?';
  static const String male = 'Male';
  static const String female = 'Female';
  static const String shoppingCountry = 'Shopping Country';
  static const String preferredCurrency = 'Preferred Currency';
  static const String startExploring = 'Start Exploring';

  // Home
  static const String hello = 'Hello';
  static const String savedThisMonth = 'Saved this month';
  static const String captureLivePhoto = 'Capture Live Photo';
  static const String uploadScreenshot = 'Upload Screenshot';
  static const String recentSearchResults = 'Recent Search Results';
  static const String viewAll = 'View All';

  // Scanner
  static const String placeItemCenter = 'Place the item in the center';

  // Search analysis
  static const String goodMorning = 'Good Morning';
  static const String capturedClothing = 'Captured Clothing';
  static const String searchNow = 'Search Now';
  static const String searchNowDescription =
      'Finding your style with economic intelligence. We find the original piece and offer the best prices and discounts immediately.';
  static const String searchEmptyTitle = 'No outfit captured yet';
  static const String searchEmptySubtitle =
      'Capture a live photo or upload a screenshot from Home to start AI analysis and find the best prices.';
  static const String openCamera = 'Open Camera';
  static const String chooseFromGallery = 'Choose from Gallery';
  static const String deletePhoto = 'Delete photo';
  static const String replacePhoto = 'Replace photo';
  static const String deletePhotoTitle = 'Remove this photo?';
  static const String deletePhotoMessage =
      'This will clear the current capture. You can add a new outfit anytime.';
  static const String newSearch = 'New Search';
  static const String newSearchTitle = 'Start a new search?';
  static const String newSearchMessage =
      'This will clear your current results. Nothing will be searched again until you capture a new outfit.';
  static const String cancel = 'Cancel';
  static const String remove = 'Remove';
  static const String analyzingOutfit = 'Analyzing outfit with AI...';
  static const String aiEngineReady = 'AI Analysis Engine ready';

  // Processing
  static const String processing = 'PROCESSING';
  static const List<String> processingStatusMessages = [
    '⚡ Reviewing the image details...',
    '🏷️ We\'ll determine the style and crop the image...',
    '🔍 We\'ll search stores and find you the best price...',
    '🛒 We\'ll calculate your savings and prepare the purchase links...',
    '✨ Ranking your top matches and finalizing results...',
  ];

  // Results
  static const String analysisComplete = 'Analysis complete';
  static const String matchesFound = 'matches found';
  static const String exactMatch = 'Exact Match';
  static const String smartAlternatives = 'Smart Alternatives (Save up to 80%)';
  static const String startSaving = 'Start Saving';
  static const String getAlternative = 'Get Alternative';
  static const String addedToSaved = 'Added to your saved collection';
  static const String removedFromSaved = 'Removed from saved';
  static const String purchaseLinkComingSoon =
      'Purchase link will be available soon';

  // Collections
  static const String searchResultsTab = 'Search Results';
  static const String savedTab = 'Saved';
  static const String curatedCollection = 'Your Curated Collection';
  static const String savedPiecesCount = 'high-precision saved pieces';

  // Profile
  static const String accountPreferences = 'Account Preferences';
  static const String language = 'Language';
  static const String country = 'Country';
  static const String gender = 'Gender';
  static const String saveChanges = 'Save Changes';
  static const String edit = 'Edit';
  static const String logout = 'Logout';

  // Nav
  static const String home = 'Home';
  static const String search = 'Search';
  static const String scan = 'Scan';
  static const String discover = 'Discover';
  static const String profile = 'Profile';
}
