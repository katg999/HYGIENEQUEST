import 'package:flutter/material.dart';
import 'baselayout.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBarTitle: 'Dettol Hygiene Quest',
      
      body: Center(
        child: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "🤖 Dettol Bot:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Welcome to the Dettol Hygiene Quest chatbot!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "I'm here to support your hygiene education efforts in class. 🧼🧽\n\nHow would you like to chat with me today?",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 32),

              // ========== Voice Chat Option ==========
              Row(
                children: [
                  const Icon(Icons.mic, size: 30),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/voice_screen');
                    },
                    child: const Text(
                      'Chat with Voice',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 193, 154, 107),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ========== Text Chat Option ==========
              Row(
                children: [
                  const Icon(Icons.textsms_outlined, size: 30),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/text_screen');
                    },
                    child: const Text(
                      'Chat with Text',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 193, 154, 107),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
