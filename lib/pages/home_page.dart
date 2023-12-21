import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;
  List<String> _tasks = [];
  String _selectedCategory = 'Study'; // Default category
  final List<Map<String, String>> _categories = [
    {
      'name': 'Study',
      'prompt':
          'Give only one random task for a student to increase study habits'
    },
    {
      'name': 'Workout',
      'prompt': 'Give only one random workout task for today'
    },
    {
      'name': 'Food',
      'prompt':
          'Suggest a nutritious and delicious recipe for a balanced meal to support a healthy lifestyle.'
    },
    {
      'name': 'Motivation',
      'prompt':
          'Share an inspiring quote or motivational message to boost morale and encourage positive thinking.'
    },
    {
      'name': 'Productivity',
      'prompt':
          'Offer a productivity tip or a time-management technique to enhance efficiency throughout the day.'
    },
    {
      'name': 'Relaxation',
      'prompt':
          'Recommend a calming activity or relaxation exercise to unwind and de-stress after a busy day.'
    },
    {
      'name': 'Coding Challenge',
      'prompt':
          'Challenge a programmer to solve a coding problem or implement a specific algorithm.'
    },
    {
      'name': 'Creativity Boost',
      'prompt':
          'Encourage creativity by suggesting an art project, writing prompt, or a musical improvisation idea.'
    },
    {
      'name': 'Language Learning',
      'prompt':
          'Provide a language learning task, such as learning five new words or practicing a specific grammar rule.'
    },
    {
      'name': 'Random Acts of Kindness',
      'prompt':
          'Inspire kindness by suggesting a random act of kindness to perform for someone in the community.'
    },
    {
      'name': 'Tech Innovation',
      'prompt':
          'Stimulate innovation by proposing a problem-solving task related to technology or proposing an app idea.'
    },
    {
      'name': 'Book Recommendation',
      'prompt':
          'Recommend a thought-provoking book and ask the user to read a chapter or share their favorite quote.'
    },
    {
      'name': 'Mindfulness Exercise',
      'prompt':
          'Guide a mindfulness or meditation exercise to promote relaxation and mental well-being.'
    },
    {
      'name': 'Environmental Awareness',
      'prompt':
          'Raise awareness about the environment by suggesting a task that contributes to sustainability or reduces waste.'
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchTask();
  }

  Future<void> fetchTask() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var apiKey = "AIzaSyA3LKzbOutMtS0TqpZMwenwrLLXstpYD0k";
      var url =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';

      var body = jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": _categories.firstWhere((category) =>
                    category['name'] == _selectedCategory)['prompt'],
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.9,
          "topK": 1,
          "topP": 1,
          "maxOutputTokens": 2048,
          "stopSequences": []
        },
      });

      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];

          if (candidate['content'] != null &&
              candidate['content']['parts'] != null) {
            final parts = candidate['content']['parts'];

            if (parts.isNotEmpty && parts[0]['text'] != null) {
              final task = parts[0]['text'];
              final splitTasks = task.split('.');
              setState(() {
                _tasks = splitTasks;
              });
            } else {
              print('Error: Text is null.');
            }
          } else {
            print('Error: Content or parts are null.');
          }
        } else {
          print('Error: Candidates array is null or empty.');
        }
      } else {
        print(
            'Error: HTTP request failed with status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset("assets/background.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity),
          Positioned(
            top: 15,
            right: 0,
            child: DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                  fetchTask();
                });
              },
              items: _categories.map<DropdownMenuItem<String>>(
                  (Map<String, String> category) {
                return DropdownMenuItem<String>(
                  value: category['name'],
                  child: Text(
                    category['name']!,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Center(
            child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 30.0),
                          Text(
                            'Task',
                            style: TextStyle(
                              fontSize: 26.0,
                              color: Colors.yellow[700],
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20.0),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _tasks
                                .map(
                                  (task) => Text(
                                    task.trim(),
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 20.0),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: fetchTask,
                            iconSize: 30.0,
                            color: Colors.white30,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
