import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';

// IMPORTANT: Replace with your actual Gemini API Key or load from .env
const String _geminiApiKey = 'AIzaSyBqKYD6ePlNcQ3KU06K9_YVmPpshHJm3aA';

final generativeModelProvider = Provider<GenerativeModel?>((ref) {
  if (_geminiApiKey == 'YOUR_GEMINI_API_KEY' || _geminiApiKey.isEmpty) {
    return null;
  }
  return GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'AIzaSyBqKYD6ePlNcQ3KU06K9_YVmPpshHJm3aA',
  );
});

final aiInsightsProvider = FutureProvider.family<String, TouristSpot>((ref, spot) async {
  final model = ref.read(generativeModelProvider);
  if (model == null) {
    return 'Detailed AI cultural insights are currently unavailable because the API key is not configured. Please add your Gemini API key in ai_provider.dart.';
  }

  final prompt = '''
    Provide an engaging cultural context, historical anecdote, local lore, 
    and practical travel tips for a tourist visiting ${spot.name} in Nepal.
    Keep the response concise, visually appealing, and no longer than 3 paragraphs.
  ''';

  try {
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? 'No insight generated.';
  } catch (e) {
    return 'Error generating insights: \$e';
  }
});
