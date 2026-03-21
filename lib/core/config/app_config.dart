class AppConfig {
  const AppConfig._();

  static const String _defaultSupabaseUrl =
      'https://kymqjgqhuwiktyjqcbyv.supabase.co';
  static const String _defaultSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5bXFqZ3FodXdpa3R5anFjYnl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQwNzk3NzMsImV4cCI6MjA4OTY1NTc3M30.EDIB9ExkNQXx1BwHz51lm2CTRnHo6qDOPPocwUZD0_o';

  static const String spotsRemoteCollection = 'tourist_spots';
  static const String spotImagesBucket = String.fromEnvironment(
    'SUPABASE_SPOT_IMAGES_BUCKET',
    defaultValue: 'spot-images',
  );
  static const String supabaseSchema = String.fromEnvironment(
    'SUPABASE_SCHEMA',
    defaultValue: 'public',
  );
  static const String supabaseTable = String.fromEnvironment(
    'SUPABASE_TABLE',
    defaultValue: 'tourist_spots',
  );
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultSupabaseUrl,
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: _defaultSupabaseAnonKey,
  );
  static const String spotsFeedUrl = String.fromEnvironment(
    'SPOTS_FEED_URL',
    defaultValue:
        'https://raw.githubusercontent.com/neupanegaurav/NepalExplore/main/server/spots.json',
  );

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String fallbackSpotImageUrl(String seed) {
    return 'https://picsum.photos/seed/$seed/1200/800';
  }
}
