class ContentFilterService {
  // List of inappropriate words to filter out
  static const List<String> _blockedWords = [
    // Explicit content
    'sex', 'porn', 'xxx', 'adult', 'nude', 'naked', 'nsfw',
    'fuck', 'shit', 'damn', 'bitch', 'ass', 'cock', 'dick', 'pussy',
    'boobs', 'tits', 'penis', 'vagina', 'orgasm', 'masturbate',

    // Hate speech and slurs
    'nigger', 'nigga', 'faggot', 'retard', 'gay', 'lesbian', 'tranny',
    'jew', 'nazi', 'hitler', 'terrorist', 'kill', 'murder', 'rape',

    // Drug-related
    'weed', 'marijuana', 'cocaine', 'heroin', 'meth', 'drugs', 'dealer',
    'addict', 'junkie', 'high', 'stoned', 'drunk', 'alcohol',

    // Violence
    'violence', 'fight', 'punch', 'kick', 'hurt', 'pain', 'blood',
    'death', 'dead', 'suicide', 'bomb', 'gun', 'weapon', 'knife',

    // Spam/scam
    'scam', 'fraud', 'fake', 'spam', 'bot', 'hack', 'cheat',
    'money', 'cash', 'bitcoin', 'crypto', 'invest', 'profit',

    // Inappropriate usernames
    'admin', 'moderator', 'mod', 'staff', 'support', 'official',
    'ecohero', 'administrator', 'root', 'system', 'test', 'null',

    // Additional inappropriate terms
    'whore', 'slut', 'bastard', 'cunt', 'prick', 'douche',
    'moron', 'idiot', 'stupid', 'dumb', 'loser', 'freak',
  ];

  /// Check if a display name contains inappropriate content
  static bool isDisplayNameAppropriate(String displayName) {
    if (displayName.trim().isEmpty) return false;

    final cleanName = displayName.toLowerCase().trim();

    // Check for blocked words
    for (final blockedWord in _blockedWords) {
      if (cleanName.contains(blockedWord.toLowerCase())) {
        return false;
      }
    }

    // Check for excessive special characters or numbers
    final alphaCount = cleanName.replaceAll(RegExp(r'[^a-zA-Z]'), '').length;
    if (alphaCount < cleanName.length * 0.5) {
      return false; // Less than 50% alphabetic characters
    }

    // Check for minimum length
    if (cleanName.length < 2) return false;

    // Check for maximum length
    if (cleanName.length > 30) return false;

    // Check for repeated characters (like "aaaaaaa")
    if (RegExp(r'(.)\1{4,}').hasMatch(cleanName)) {
      return false;
    }

    // Check for inappropriate patterns
    if (RegExp(r'^\d+$').hasMatch(cleanName)) {
      return false; // Only numbers
    }

    return true;
  }

  /// Check if bio content is appropriate
  static bool isBioAppropriate(String bio) {
    if (bio.trim().isEmpty) return true; // Bio is optional

    final cleanBio = bio.toLowerCase().trim();

    // Check for blocked words in bio
    for (final blockedWord in _blockedWords) {
      if (cleanBio.contains(blockedWord.toLowerCase())) {
        return false;
      }
    }

    // Check for excessive length
    if (bio.length > 500) return false;

    // Check for spam patterns (repeated words/characters)
    final words = cleanBio.split(' ');
    if (words.length > 3) {
      final uniqueWords = words.toSet();
      if (uniqueWords.length < words.length * 0.3) {
        return false; // Too much repetition
      }
    }

    return true;
  }

  /// Get a user-friendly error message for inappropriate display names
  static String getDisplayNameErrorMessage() {
    return 'Please choose a family-friendly display name that represents you positively in our eco-community.';
  }

  /// Get a user-friendly error message for inappropriate bio
  static String getBioErrorMessage() {
    return 'Please keep your bio positive and family-friendly for our eco-community.';
  }

  /// Suggest alternative names based on eco-friendly themes
  static List<String> suggestAlternativeNames() {
    final ecoNames = [
      'EcoWarrior',
      'GreenHero',
      'NatureLover',
      'EarthGuardian',
      'ClimateChampion',
      'SustainableSoul',
      'EcoFriendly',
      'GreenThumb',
      'EcoAdvocate',
      'NatureProtector',
      'EcoMinded',
      'GreenSpirit',
      'EcoConscious',
      'EarthLover',
      'GreenLiving',
      'EcoInspired',
      'NatureFirst',
      'GreenPlanet',
      'EcoSmart',
      'EarthCare',
    ];

    // Return 3 random suggestions
    ecoNames.shuffle();
    return ecoNames.take(3).toList();
  }
}
