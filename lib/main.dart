import 'package:flutter/material.dart';
import 'dart:async'; // For Timer functionality
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_cube/flutter_cube.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';


Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(RailwayNavigationApp());
}

Future<void> loadEnvFile() async {
  if (kIsWeb) {
    await dotenv.load(fileName: "assets/.env");
  } else {
    await dotenv.load(fileName: ".env");
  }
}

class RailwayNavigationApp extends StatelessWidget {
  const RailwayNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Railway Navigation',
      theme: ThemeData(
        brightness: Brightness.dark,
        cardColor: const Color.fromARGB(255, 70, 3, 255),
        fontFamily: 'CourierPrime',
      ),
      home: const SplashScreen(), // Set SplashScreen as the home
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NavigationMainPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/welcome_background.jpg'), // Add your image path here
            fit: BoxFit.cover, // Ensures the image covers the entire screen
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: const Text(
                  'PRAVAAH',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 20, 199),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'CourierPrime',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Welcome to Railway Navigator',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 20, 199),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'CourierPrime',
                ),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                color: Color.fromARGB(255, 70, 3, 255),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main Page with Navigation Bar
class NavigationMainPage extends StatefulWidget {
  const NavigationMainPage({super.key});

  @override
  State<NavigationMainPage> createState() => _NavigationMainPageState();
}

class _NavigationMainPageState extends State<NavigationMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const WelcomePage(username: '',),
    const SearchPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Railway Navigator",
            style: TextStyle(fontFamily: 'CourierPrime')),
        backgroundColor: const Color.fromARGB(255, 0, 20, 199),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              const DrawerHeader(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 0, 20, 199)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'CourierPrime',
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.chat,
                    color: Color.fromARGB(255, 0, 20, 199)),
                title: const Text('Chatbot',
                    style: TextStyle(color: Color.fromARGB(255, 0, 20, 199))),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatbotPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.contacts,
                    color: Color.fromARGB(255, 0, 20, 199)),
                title: const Text('Emergency Contacts',
                    style: TextStyle(color: Colors.deepPurpleAccent)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyContactsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.email,
                    color: Color.fromARGB(255, 0, 20, 199)),
                title: const Text('Emergency Emails',
                    style: TextStyle(color: Colors.deepPurpleAccent)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyEmailsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Add the rest of your pages such as ChatbotPage, EmergencyContactsPage, EmergencyEmailsPage,
// WelcomePage, SearchPage, ProfilePage, LoginPage, and SignUpPage below.

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // To store query-response pairs
  late GenerativeModel _model;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize the chatbot model
    final apiKey = 'AIzaSyAKPFifIPM1ZFWgC7UBzEkm4npQNSXiW3c';
    if (apiKey.isEmpty) {
      stderr.writeln('No API key found in the .env file.');
      exit(1);
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1.3,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
      systemInstruction: Content.system(
        'You are a bot for railway. I will provide you a dataset based on that, '
        'and you have to answer the queries. This is the dataset on which you '
        'have to answer the queries:\n'
        'THE INDIAN RAILWAY BOARD ACT, 1905\n'
        'ACT NO. 4 OF 1905.\n'
        '(22nd March, 1905)\n'
        '(Complete dataset text goes here)',
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'type': 'user', 'message': message}); // Add user message
      _isLoading = true;
    });

    try {
      final chat = _model.startChat(history: [
        Content.multi([TextPart(message)]),
      ]);

      final content = Content.text(message);
      final response = await chat.sendMessage(content);

      setState(() {
        _messages.add({'type': 'bot', 'message': response.text!}); // Add bot response
      });
    } catch (e) {
      setState(() {
        _messages.add({'type': 'bot', 'message': 'Error: ${e.toString()}'}); // Error handling
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chatbot",
          style: TextStyle(fontFamily: 'CourierPrime'),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 20, 199),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message['type'] == 'user';
                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Colors.blueAccent
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(
                        color: isUserMessage ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0), // Move input field upward
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type your query...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    final message = _controller.text.trim();
                    _controller.clear();
                    _sendMessage(message);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Contacts",
            style: TextStyle(fontFamily: 'CourierPrime')),
        backgroundColor: Color.fromARGB(255, 0, 20, 199),
      ),
      body: const Center(
        child: Text(
          'Emergency contacts will be displayed here.',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

class EmergencyEmailsPage extends StatelessWidget {
  const EmergencyEmailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Emails",
            style: TextStyle(fontFamily: 'CourierPrime')),
        backgroundColor: Color.fromARGB(255, 0, 20, 199),
      ),
      body: const Center(
        child: Text(
          'Emergency email addresses will be displayed here.',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

class LocalizationService {
  static final Map<String, Map<String, String>> _localizedStrings = {
    'English': {
      'welcome': 'Welcome',
      'namaste': 'Namaste',
      'select_station': 'Select Station',
      'start_navigation': 'Start Navigation',
      'navigation_started': 'Navigation Started',
      'view_3d_model': 'View 3D Model',
      'welcome_message':
          'Welcome to Railway Navigation App. Select your station to start.',
    },
    'हिंदी (Hindi)': {
      'welcome': 'स्वागत है',
      'namaste': 'नमस्ते',
      'select_station': 'स्टेशन चुनें',
      'start_navigation': 'नेविगेशन शुरू करें',
      'navigation_started': 'नेविगेशन शुरू हुआ',
      'view_3d_model': '3D मॉडल देखें',
      'welcome_message':
          'रेलवे नेविगेशन ऐप में आपका स्वागत है। शुरू करने के लिए अपना स्टेशन चुनें।',
    },
    'मराठी (Marathi)': {
      'welcome': 'स्वागत आहे',
      'namaste': 'नमस्कार',
      'select_station': 'स्टेशन निवडा',
      'start_navigation': 'नेव्हिगेशन सुरू करा',
      'navigation_started': 'नेव्हिगेशन सुरू झाले',
      'view_3d_model': '3D मॉडेल पहा',
      'welcome_message':
          'रेल्वे नेव्हिगेशन अॅपमध्ये तुमचे स्वागत आहे. सुरू करण्यासाठी तुमचे स्टेशन निवडा.',
    },
    'தமிழ் (Tamil)': {
      'welcome': 'வரவேற்கிறோம்',
      'namaste': 'வணக்கம்',
      'select_station': 'நிலையத்தைத் தேர்ந்தெடுக்கவும்',
      'start_navigation': 'வழிகாட்டியை தொடங்கவும்',
      'navigation_started': 'வழிகாட்டி தொடங்கப்பட்டது',
      'view_3d_model': '3D மாதிரியை காண்க',
      'welcome_message':
          'ரயில் வழிகாட்டு செயலியில் உங்களை வரவேற்கிறோம். தொடங்க உங்கள் நிலையத்தைத் தேர்ந்தெடுக்கவும்.',
    },
    'తెలుగు (Telugu)': {
      'welcome': 'స్వాగతం',
      'namaste': 'నమస్తే',
      'select_station': 'స్టేషన్‌ను ఎంచుకోండి',
      'start_navigation': 'నావిగేషన్‌ను ప్రారంభించండి',
      'navigation_started': 'నావిగేషన్ ప్రారంభమైంది',
      'view_3d_model': '3D మోడల్ చూడండి',
      'welcome_message':
          'రైల్వే నావిగేషన్ యాప్‌కి స్వాగతం. ప్రారంభించడానికి మీ స్టేషన్‌ను ఎంచుకోండి.',
    },
    'বাংলা (Bengali)': {
      'welcome': 'স্বাগত',
      'namaste': 'নমস্তে',
      'select_station': 'স্টেশন নির্বাচন করুন',
      'start_navigation': 'নেভিগেশন শুরু করুন',
      'navigation_started': 'নেভিগেশন শুরু হয়েছে',
      'view_3d_model': '3D মডেল দেখুন',
      'welcome_message':
          'রেলওয়ে নেভিগেশন অ্যাপে আপনাকে স্বাগত। শুরু করতে আপনার স্টেশন নির্বাচন করুন।',
    },
    'ગુજરાતી (Gujarati)': {
      'welcome': 'સ્વાગત છે',
      'namaste': 'નમસ્તે',
      'select_station': 'સ્ટેશન પસંદ કરો',
      'start_navigation': 'નેવિગેશન શરૂ કરો',
      'navigation_started': 'નેવિગેશન શરૂ થયું',
      'view_3d_model': '3D મોડલ જુઓ',
      'welcome_message':
          'રેલવે નેવિગેશન એપમાં તમારું સ્વાગત છે. શરૂ કરવા માટે તમારું સ્ટેશન પસંદ કરો.',
    },
    'ਪੰਜਾਬੀ (Punjabi)': {
      'welcome': 'ਸਵਾਗਤ ਹੈ',
      'namaste': 'ਨਮਸਤੇ',
      'select_station': 'ਸਟੇਸ਼ਨ ਚੁਣੋ',
      'start_navigation': 'ਨੇਵੀਗੇਸ਼ਨ ਸ਼ੁਰੂ ਕਰੋ',
      'navigation_started': 'ਨੇਵੀਗੇਸ਼ਨ ਸ਼ੁਰੂ ਹੋ ਗਿਆ ਹੈ',
      'view_3d_model': '3D ਮਾਡਲ ਵੇਖੋ',
      'welcome_message':
          'ਰੇਲਵੇ ਨੇਵੀਗੇਸ਼ਨ ਐਪ ਵਿੱਚ ਤੁਹਾਡਾ ਸਵਾਗਤ ਹੈ। ਸ਼ੁਰੂ ਕਰਨ ਲਈ ਆਪਣਾ ਸਟੇਸ਼ਨ ਚੁਣੋ।',
    },
    'ಕನ್ನಡ (Kannada)': {
      'welcome': 'ಸ್ವಾಗತ',
      'namaste': 'ನಮಸ್ಕಾರ',
      'select_station': 'ನಿಲ್ದಾಣವನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'start_navigation': 'ನಾವಿಗೇಶನ್ ಪ್ರಾರಂಭಿಸಿ',
      'navigation_started': 'ನಾವಿಗೇಶನ್ ಪ್ರಾರಂಭವಾಯಿತು',
      'view_3d_model': '3D ಮಾದರಿಯನ್ನು ವೀಕ್ಷಿಸಿ',
      'welcome_message':
          'ರೈಲು ನಾವಿಗೇಶನ್ ಅಪ್ಲಿಕೇಶನ್‌ಗೆ ಸ್ವಾಗತ. ಪ್ರಾರಂಭಿಸಲು ನಿಮ್ಮ ನಿಲ್ದಾಣವನ್ನು ಆಯ್ಕೆಮಾಡಿ.',
    },
    'മലയാളം (Malayalam)': {
      'welcome': 'സ്വാഗതം',
      'namaste': 'നമസ്കാരം',
      'select_station': 'സ്റ്റേഷൻ തിരഞ്ഞെടുക്കുക',
      'start_navigation': 'നാവിഗേഷൻ ആരംഭിക്കുക',
      'navigation_started': 'നാവിഗേഷൻ ആരംഭിച്ചു',
      'view_3d_model': '3D മോഡൽ കാണുക',
      'welcome_message':
          'റെയിൽവേ നാവിഗേഷൻ ആപ്പിലേക്ക് സ്വാഗതം. ആരംഭിക്കാൻ നിങ്ങളുടെ സ്റ്റേഷൻ തിരഞ്ഞെടുക്കുക.',
    },
    'ଓଡ଼ିଆ (Odia)': {
      'welcome': 'ସ୍ୱାଗତ',
      'namaste': 'ନମସ୍କାର',
      'select_station': 'ସ୍ଟେସନ୍ ବାଛନ୍ତୁ',
      'start_navigation': 'ନେଭିଗେସନ୍ ଆରମ୍ଭ କରନ୍ତୁ',
      'navigation_started': 'ନେଭିଗେସନ୍ ଆରମ୍ଭ ହେଲା',
      'view_3d_model': '3D ମୋଡେଲ୍ ଦେଖନ୍ତୁ',
      'welcome_message':
          'ରେଲୱେ ନେଭିଗେସନ୍ ଆପ୍ରେ ଆପଣଙ୍କୁ ସ୍ୱାଗତ। ଆରମ୍ଭ କରିବାକୁ ଆପଣଙ୍କର ସ୍ଟେସନ୍ ବାଛନ୍ତୁ।',
    },

    // Add more languages here
  };

  static String _currentLanguage = 'English';

  static Future<void> loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('selected_language') ?? 'English';
  }

  static Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
  }

  static String translate(String key) {
    return _localizedStrings[_currentLanguage]?[key] ?? key;
  }

  static String get currentLanguage => _currentLanguage;
}

// Welcome Page
// Welcome Page
class WelcomePage extends StatefulWidget {
  final String username;
  const WelcomePage({super.key,required this.username});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    LocalizationService.loadLanguagePreference().then((_) => setState(() {}));
    _setTtsLanguage();
  }

  void _setTtsLanguage() async {
    String ttsLanguage = _getTtsLanguage();
    await _flutterTts.setLanguage(ttsLanguage);
  }

  String _getTtsLanguage() {
    switch (LocalizationService.currentLanguage) {
      case 'हिंदी (Hindi)':
        return 'hi-IN';
      case 'मराठी (Marathi)':
        return 'mr-IN';
      case 'தமிழ் (Tamil)':
        return 'ta-IN';
      case 'తెలుగు (Telugu)':
        return 'te-IN';
      case 'বাংলা (Bengali)':
        return 'bn-IN';
      case 'ગુજરાતી (Gujarati)':
        return 'gu-IN';
      case 'ਪੰਜਾਬੀ (Punjabi)':
        return 'pa-IN';
      case 'ಕನ್ನಡ (Kannada)':
        return 'kn-IN';
      case 'മലയാളം (Malayalam)':
        return 'ml-IN';
      case 'ଓଡ଼ିଆ (Odia)':
        return 'or-IN';
      default:
        return 'en-US';
    }
  }

  void _readAloud(String key) async {
    _setTtsLanguage();
    await _flutterTts.speak(LocalizationService.translate(key));
  }

  void _startListening() async {
    if (!_isListening && await _speechToText.initialize()) {
      setState(() => _isListening = true);
      _speechToText.listen(onResult: (result) {
        setState(() => _searchText = result.recognizedWords);
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          LocalizationService.translate('welcome'),
          style: const TextStyle(fontFamily: 'CourierPrime'),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (value) {
              setState(() {
                LocalizationService.setLanguage(value);
                _setTtsLanguage();
              });
            },
            itemBuilder: (context) {
              return LocalizationService._localizedStrings.keys
                  .map((lang) => PopupMenuItem(value: lang, child: Text(lang)))
                  .toList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.white),
            onPressed: () {
              _readAloud('welcome_message');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              LocalizationService.translate('welcome'),
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 20, 199),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'CourierPrime',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              LocalizationService.translate('namaste'),
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 20, 199),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'CourierPrime',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: _searchText),
                      decoration: InputDecoration(
                        labelText:
                            LocalizationService.translate('select_station'),
                        labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 0, 20, 199)),
                        prefixIcon: const Icon(Icons.train,
                            color: Color.fromARGB(255, 0, 20, 199)),
                        suffixIcon: const Icon(Icons.search,
                            color: Color.fromARGB(255, 0, 20, 199)),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 0, 20, 199)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 0, 20, 199)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: const Color.fromARGB(255, 0, 20, 199),
                    ),
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 70, 3, 255),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                _readAloud('navigation_started');
              },
              child: Text(
                LocalizationService.translate('start_navigation'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'CourierPrime',
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.view_in_ar),
              label: Text(LocalizationService.translate('view_3d_model')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 70, 3, 255),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModelViewerScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ModelViewerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Model Viewer'),
      ),
      body: Container(
        color: Colors.white, // Set the background color to white
        child: Center(
          child: Cube(
            onSceneCreated: (Scene scene) {
              final object = Object(fileName: 'assets/models/model.obj');
              object.scale.setValues(100.0, 100.0, 100.0);
              scene.world.add(object);
            },
          ),
        ),
      ),
    );
  }
}

enum TtsState { playing, stopped }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _options = [
    {"icon": Icons.hotel, "label": "Hotels", "color": Colors.blueGrey},
    {"icon": Icons.nature_people, "label": "Picnic Spots", "color": Colors.teal},
    {"icon": Icons.shopping_cart, "label": "Shopping", "color": Colors.purple},
    {"icon": Icons.restaurant, "label": "Restaurants", "color": Colors.redAccent},
  ];

  late final AnimationController _controller;
  final List<int> _visibleItems = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    for (int i = 0; i < _options.length; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _visibleItems.add(i);
      });
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Search Nearby",
          style: TextStyle(fontFamily: 'CourierPrime'),
        ),
        backgroundColor: const Color.fromARGB(255, 70, 3, 255),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _options.length,
        itemBuilder: (context, index) {
          return _visibleItems.contains(index)
              ? _buildAnimatedOption(index, _options[index])
              : const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAnimatedOption(int index, Map<String, dynamic> option) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0), // Start from off-screen (left)
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchResultPage(option["label"])),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: option["color"]?.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                option["label"],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'CourierPrime',
                ),
              ),
              Icon(option["icon"], size: 40, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchResultPage extends StatelessWidget {
  final String label;

  const SearchResultPage(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    // Define the list of hotels
    final List<Map<String, String>> hotels = [
      {
        "name": "Hotel Aurora Towers",
        "rating": "7.2/10",
        "location": "Near MG Road, Pune",
        "mapLink": "https://www.google.com/maps?q=Hotel+Aurora+Towers,+MG+Road,+Pune",
        "image":
            "https://cf.bstatic.com/xdata/images/hotel/max1024x768/43385385.jpg?k=b00d46d759606ec73d09cab56e55f30eb62d36b83e2858ed468574d0e5256c34&o=&hp=1",
      },
      {
        "name": "Shantai Hotel",
        "rating": "8.1/10",
        "location": "Central Pune, 1 km from station",
        "mapLink": "https://www.google.com/maps?q=Shantai+Hotel,+Pune",
        "image":
            "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/08/a9/bb/7d/shantai-hotel.jpg?w=700&h=-1&s=1",
      },
      // More hotels...
    ];

    // Define the list of picnic spots
    final List<Map<String, String>> picnicSpots = [
      {
        "name": "Bund Garden",
        "rating": "8.0/10",
        "location": "Bund Garden Road, Pune",
        "mapLink": "https://www.google.com/maps?q=Bund+Garden,+Pune",
        "image":
            "https://www.trawell.in/admin/images/upload/306349749Bund_Garden_Main.jpg",
      },
      {
        "name": "Pashan Lake",
        "rating": "8.5/10",
        "location": "Pashan, Pune",
        "mapLink": "https://www.google.com/maps?q=Pashan+Lake,+Pune",
        "image":
            "https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/Pashan_Lake_-_Evening_View.jpg/1280px-Pashan_Lake_-_Evening_View.jpg",
      },
      // More picnic spots...
    ];

    // Define the list of shopping malls
    final List<Map<String, String>> shoppingMalls = [
      {
        "name": "Phoenix Marketcity",
        "rating": "9.0/10",
        "location": "Viman Nagar, Pune",
        "mapLink": "https://www.google.com/maps?q=Phoenix+Marketcity,+Pune",
        "image":
            "https://upload.wikimedia.org/wikipedia/commons/d/d8/Phoenix_Marketcity%2C_Pune.jpg",
      },
      {
        "name": "Seasons Mall",
        "rating": "8.5/10",
        "location": "Magarpatta, Pune",
        "mapLink": "https://www.google.com/maps?q=Seasons+Mall,+Pune",
        "image":
            "https://www.punekarnews.in/wp-content/uploads/2019/07/Seasons-Mall-Pune.jpg",
      },
      // More shopping malls...
    ];

    // Define the list of restaurants
    final List<Map<String, String>> restaurants = [
      {
        "name": "Malaka Spice",
        "rating": "9.2/10",
        "location": "Koregaon Park, Pune",
        "mapLink": "https://www.google.com/maps?q=Malaka+Spice,+Pune",
        "image":
            "https://b.zmtcdn.com/data/pictures/3/10593/7cbcb8bfb6b65a5cf3e69f8267e71563.jpg",
      },
      {
        "name": "Vaishali Restaurant",
        "rating": "8.9/10",
        "location": "FC Road, Pune",
        "mapLink": "https://www.google.com/maps?q=Vaishali+Restaurant,+Pune",
        "image":
            "https://static.tnn.in/photo/msid-73058580/73058580.jpg",
      },
      // More restaurants...
    ];

    // Select the list to display based on the label
    List<Map<String, String>> selectedList;
    switch (label) {
      case "Hotels":
        selectedList = hotels;
        break;
      case "Picnic Spots":
        selectedList = picnicSpots;
        break;
      case "Shopping Malls":
        selectedList = shoppingMalls;
        break;
      case "Restaurants":
        selectedList = restaurants;
        break;
      default:
        selectedList = [];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(label),
        backgroundColor: const Color.fromARGB(255, 70, 3, 255),
      ),
      body: Container(
        color: Colors.white,
        child: selectedList.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: selectedList.length,
                itemBuilder: (context, index) {
                  final item = selectedList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["name"]!,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text('Rating: ${item["rating"]}'),
                          const SizedBox(height: 8.0),
                          Text('Location: ${item["location"]}'),
                          const SizedBox(height: 8.0),
                          Image.network(item["image"]!),
                          const SizedBox(height: 8.0),
                          ElevatedButton(
                            onPressed: () async {
                              final url = item["mapLink"]!;
                              if (await canLaunch(url)) {
                                await launch(url);
                              }
                            },
                            child: const Text('View on Map'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: Text('No data available'),
              ),
      ),
    );
  }
}



// Placeholder Page for Search Results
// class SearchResultPage extends StatelessWidget {
//   final String label;
//   const SearchResultPage(this.label, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text("$label Results", style: const TextStyle(fontFamily: 'CourierPrime')),
//         backgroundcolor: Color.fromARGB(255, 0, 20, 199),
//       ),
//       body: Center(
//         child: Text(
//           'Results for $label',
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'CourierPrime',
//           ),
//         ),
//       ),
//     );
//   }
// }

// Profile Page
const translations = {
  'en-US': {
    'profileTitle': 'Profile',
    'signIn': 'Sign In',
    'signUp': 'Sign Up',
    'loginTitle': 'Login',
    'signInToYourAccount': 'Sign in to your account',
    'emailAddress': 'Email Address',
    'password': 'Password',
    'forgotPassword': 'Forgot Password?',
    'confirm': 'Confirm',
    'signUpTitle': 'Sign Up',
    'name': 'Name',
    'mobileNumber': 'Mobile Number',
    'confirmPassword': 'Confirm Password',
  },
  'hi-IN': {
    'profileTitle': 'प्रोफ़ाइल',
    'signIn': 'साइन इन करें',
    'signUp': 'साइन अप करें',
    'loginTitle': 'लॉगिन',
    'signInToYourAccount': 'अपने खाते में साइन इन करें',
    'emailAddress': 'ईमेल पता',
    'password': 'पासवर्ड',
    'forgotPassword': 'पासवर्ड भूल गए?',
    'confirm': 'पुष्टि करें',
    'signUpTitle': 'साइन अप',
    'name': 'नाम',
    'mobileNumber': 'मोबाइल नंबर',
    'confirmPassword': 'पासवर्ड की पुष्टि करें',
  },
  'mr-IN': {
    'profileTitle': 'प्रोफाइल',
    'signIn': 'साइन इन',
    'signUp': 'साइन अप',
    'loginTitle': 'लॉगिन',
    'signInToYourAccount': 'तुमच्या खात्यात साइन इन करा',
    'emailAddress': 'ईमेल पत्ता',
    'password': 'पासवर्ड',
    'forgotPassword': 'पासवर्ड विसरलात?',
    'confirm': 'पुष्टी करा',
    'signUpTitle': 'साइन अप',
    'name': 'नाव',
    'mobileNumber': 'मोबाइल नंबर',
    'confirmPassword': 'पासवर्डची पुष्टी करा',
  },
  'ta-IN': {
    'profileTitle': 'சுயவிவரம்',
    'signIn': 'உள்நுழைவு',
    'signUp': 'பதிவு செய்யவும்',
    'loginTitle': 'உள்நுழையவும்',
    'signInToYourAccount': 'உங்கள் கணக்கில் உள்நுழைக',
    'emailAddress': 'மின்னஞ்சல் முகவரி',
    'password': 'கடவுச்சொல்',
    'forgotPassword': 'கடவுச்சொல் மறந்துவிட்டதா?',
    'confirm': 'உறுதிப்படுத்தவும்',
    'signUpTitle': 'பதிவு செய்யவும்',
    'name': 'பெயர்',
    'mobileNumber': 'மொபைல் எண்',
    'confirmPassword': 'கடவுச்சொல்லை உறுதிப்படுத்தவும்',
  },
  'te-IN': {
    'profileTitle': 'ప్రొఫైల్',
    'signIn': 'సైన్ ఇన్ చేయండి',
    'signUp': 'చేరండి',
    'loginTitle': 'లాగిన్',
    'signInToYourAccount': 'మీ ఖాతాలో సైన్ ఇన్ చేయండి',
    'emailAddress': 'ఇమెయిల్ చిరునామా',
    'password': 'పాస్వర్డ్',
    'forgotPassword': 'పాస్వర్డ్ మర్చిపోయారా?',
    'confirm': 'నిర్ధారించండి',
    'signUpTitle': 'చేరండి',
    'name': 'పేరు',
    'mobileNumber': 'మొబైల్ నంబర్',
    'confirmPassword': 'పాస్వర్డ్ నిర్ధారించండి',
  },
  'bn-IN': {
    'profileTitle': 'প্রোফাইল',
    'signIn': 'সাইন ইন করুন',
    'signUp': 'সাইন আপ করুন',
    'loginTitle': 'লগইন',
    'signInToYourAccount': 'আপনার অ্যাকাউন্টে সাইন ইন করুন',
    'emailAddress': 'ইমেল ঠিকানা',
    'password': 'পাসওয়ার্ড',
    'forgotPassword': 'পাসওয়ার্ড ভুলে গেছেন?',
    'confirm': 'নিশ্চিত করুন',
    'signUpTitle': 'সাইন আপ করুন',
    'name': 'নাম',
    'mobileNumber': 'মোবাইল নম্বর',
    'confirmPassword': 'পাসওয়ার্ড নিশ্চিত করুন',
  },
  'gu-IN': {
    'profileTitle': 'પ્રોફાઇલ',
    'signIn': 'સાઇન ઇન કરો',
    'signUp': 'સાઇન અપ કરો',
    'loginTitle': 'લૉગિન',
    'signInToYourAccount': 'તમારા ખાતામાં સાઇન ઇન કરો',
    'emailAddress': 'ઇમેઇલ સરનામું',
    'password': 'પાસવર્ડ',
    'forgotPassword': 'પાસવર્ડ ભૂલી ગયા છો?',
    'confirm': 'પુષ્ટિ કરો',
    'signUpTitle': 'સાઇન અપ',
    'name': 'નામ',
    'mobileNumber': 'મોબાઇલ નંબર',
    'confirmPassword': 'પાસવર્ડની પુષ્ટિ કરો',
  },
  'pa-IN': {
    'profileTitle': 'ਪ੍ਰੋਫਾਈਲ',
    'signIn': 'ਸਾਈਨ ਇਨ ਕਰੋ',
    'signUp': 'ਸਾਈਨ ਅਪ ਕਰੋ',
    'loginTitle': 'ਲਾਗਿਨ',
    'signInToYourAccount': 'ਆਪਣੇ ਖਾਤੇ ਵਿੱਚ ਸਾਈਨ ਇਨ ਕਰੋ',
    'emailAddress': 'ਈਮੇਲ ਪਤਾ',
    'password': 'ਪਾਸਵਰਡ',
    'forgotPassword': 'ਪਾਸਵਰਡ ਭੁੱਲ ਗਏ?',
    'confirm': 'ਪੁਸ਼ਟੀ ਕਰੋ',
    'signUpTitle': 'ਸਾਈਨ ਅਪ ਕਰੋ',
    'name': 'ਨਾਮ',
    'mobileNumber': 'ਮੋਬਾਈਲ ਨੰਬਰ',
    'confirmPassword': 'ਪਾਸਵਰਡ ਦੀ ਪੁਸ਼ਟੀ ਕਰੋ',
  },
  'kn-IN': {
    'profileTitle': 'ಪ್ರೊಫೈಲ್',
    'signIn': 'ಸೈನ್ ಇನ್ ಮಾಡಿ',
    'signUp': 'ಸೈನ್ ಅಪ್ ಮಾಡಿ',
    'loginTitle': 'ಲಾಗಿನ್',
    'signInToYourAccount': 'ನಿಮ್ಮ ಖಾತೆಗೆ ಸೈನ್ ಇನ್ ಮಾಡಿ',
    'emailAddress': 'ಇಮೇಲ್ ವಿಳಾಸ',
    'password': 'ಪಾಸ್‌ವರ್ಡ್',
    'forgotPassword': 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿದ್ದೀರಾ?',
    'confirm': 'ದೃಢೀಕರಿಸಿ',
    'signUpTitle': 'ಸೈನ್ ಅಪ್',
    'name': 'ಹೆಸರು',
    'mobileNumber': 'ಮೊಬೈಲ್ ನಂಬರ್',
    'confirmPassword': 'ಪಾಸ್‌ವರ್ಡ್ ದೃಢೀಕರಿಸಿ',
  },
  'ml-IN': {
    'profileTitle': 'പ്രൊഫൈൽ',
    'signIn': 'സൈൻ ഇൻ ചെയ്യുക',
    'signUp': 'സൈൻ അപ്പ് ചെയ്യുക',
    'loginTitle': 'ലോഗിൻ',
    'signInToYourAccount': 'നിങ്ങളുടെ അക്കൗണ്ടിൽ സൈൻ ഇൻ ചെയ്യുക',
    'emailAddress': 'ഇമെയിൽ വിലാസം',
    'password': 'പാസ്വേഡ്',
    'forgotPassword': 'പാസ്വേഡ് മറന്നോ?',
    'confirm': 'സ്ഥിരീകരിക്കുക',
    'signUpTitle': 'സൈൻ അപ്പ് ചെയ്യുക',
    'name': 'പേര്',
    'mobileNumber': 'മൊബൈൽ നമ്പർ',
    'confirmPassword': 'പാസ്വേഡ് സ്ഥിരീകരിക്കുക',
  },
  'or-IN': {
    'profileTitle': 'ପ୍ରୋଫାଇଲ୍',
    'signIn': 'ସାଇନ୍ ଇନ୍ କରନ୍ତୁ',
    'signUp': 'ସାଇନ୍ ଅପ୍ କରନ୍ତୁ',
    'loginTitle': 'ଲଗଇନ୍',
    'signInToYourAccount': 'ଆପଣଙ୍କର ଖାତାରେ ସାଇନ୍ ଇନ୍ କରନ୍ତୁ',
    'emailAddress': 'ଇମେଲ୍ ଠିକଣା',
    'password': 'ପାସୱାର୍ଡ',
    'forgotPassword': 'ପାସୱାର୍ଡ ଭୁଲିଗଲାନି?',
    'confirm': 'ନିଶ୍ଚିତ କରନ୍ତୁ',
    'signUpTitle': 'ସାଇନ୍ ଅପ୍ କରନ୍ତୁ',
    'name': 'ନାମ',
    'mobileNumber': 'ମୋବାଇଲ୍ ନମ୍ବର',
    'confirmPassword': 'ପାସୱାର୍ଡ ନିଶ୍ଚିତ କରନ୍ତୁ',
  },
};

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _selectedLanguage = 'en-US'; // Default to English
  final FlutterTts _flutterTts = FlutterTts();

  final List<String> languages = [
    'English',
    'हिंदी (Hindi)',
    'मराठी (Marathi)',
    'தமிழ் (Tamil)',
    'తెలుగు (Telugu)',
    'বাংলা (Bengali)',
    'ગુજરાતી (Gujarati)',
    'ਪੰਜਾਬੀ (Punjabi)',
    'ಕನ್ನಡ (Kannada)',
    'മലയാളം (Malayalam)',
    'ଓଡ଼ିଆ (Odia)',
  ];

  void _updateLanguage(String language) {
    setState(() {
      _selectedLanguage = _getLanguageCode(language);
    });
  }

  Future<void> _speak(
      String profileText, String signInText, String signUpText) async {
    final String speechText =
        '$profileText. $signInText or $signUpText? Please choose.';
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.speak(speechText);
  }

  String _getLanguageCode(String language) {
    switch (language) {
      case 'हिंदी (Hindi)':
        return 'hi-IN';
      case 'मराठी (Marathi)':
        return 'mr-IN';
      case 'தமிழ் (Tamil)':
        return 'ta-IN';
      case 'తెలుగు (Telugu)':
        return 'te-IN';
      case 'বাংলা (Bengali)':
        return 'bn-IN';
      case 'ગુજરાતી (Gujarati)':
        return 'gu-IN';
      case 'ਪੰਜਾਬੀ (Punjabi)':
        return 'pa-IN';
      case 'ಕನ್ನಡ (Kannada)':
        return 'kn-IN';
      case 'മലയാളം (Malayalam)':
        return 'ml-IN';
      case 'ଓଡ଼ିଆ (Odia)':
        return 'or-IN';
      default:
        return 'en-US';
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = translations[_selectedLanguage]!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          translation['profileTitle']!,
          style: const TextStyle(fontFamily: 'CourierPrime'),
        ),
        backgroundColor: const Color.fromARGB(255, 70, 3, 255),
        actions: [
          DropdownButtonHideUnderline(
            // Hide the underline of the dropdown
            child: DropdownButton<String>(
              value: languages.firstWhere(
                (lang) => _getLanguageCode(lang) == _selectedLanguage,
              ),
              icon: const Icon(Icons.language, color: Colors.white),
              dropdownColor: const Color.fromARGB(255, 70, 3, 255),
              onChanged: (String? newValue) => _updateLanguage(newValue!),
              items: languages.map((String language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(
                    language,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.white),
            onPressed: () => _speak(
              translation['profileTitle']!,
              translation['signIn']!,
              translation['signUp']!,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(selectedLanguage: _selectedLanguage),
                  ),
                );
              },
              child: Text(translation['signIn']!),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SignUpPage(selectedLanguage: _selectedLanguage),
                  ),
                );
              },
              child: Text(translation['signUp']!),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final String selectedLanguage;

  const LoginPage({super.key, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    final translation = translations[selectedLanguage]!;
    return Scaffold(
      appBar: AppBar(
        title: Text(translation['loginTitle']!,
            style: const TextStyle(fontFamily: 'CourierPrime')),
        backgroundColor: const Color.fromARGB(255, 70, 3, 255),
      ),
      backgroundColor: Colors.white,
      body: Center(
       
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              translation['signInToYourAccount']!,
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            TextField(
              decoration: InputDecoration(
                labelText: translation['emailAddress']!,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15.0),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: translation['password']!,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Forgot password functionality
                },
                child: Text(translation['forgotPassword']!),
              ),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Sign-in functionality
                },
                child: Text(translation['confirm']!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  final String selectedLanguage;

  const SignUpPage({super.key, required this.selectedLanguage});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://sih-pravaah.onrender.com/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out. Please try again.');
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomePage(
                username: _nameController.text,
              ),
            ),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _errorMessage =
              errorData['message'] ?? 'Registration failed: ${response.statusCode}';
        });
      }
    } on TimeoutException catch (_) {
      setState(() {
        _errorMessage = 'Connection timed out. Please check your internet connection.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = translations[widget.selectedLanguage]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(translation['signUpTitle']!,
            style: const TextStyle(fontFamily: 'CourierPrime')),
        backgroundColor: const Color.fromARGB(255, 70, 3, 255),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                translation['signUpTitle']!,
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: translation['name']!,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: translation['emailAddress']!,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: translation['mobileNumber']!,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: translation['password']!,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: translation['confirmPassword']!,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(translation['confirm']!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
