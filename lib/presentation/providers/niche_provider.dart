import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/native_service.dart';

class NicheProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NativeService _nativeService = NativeService();

  List<Map<String, dynamic>> _niches = [];
  List<String> _selectedNiches = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get niches => _niches;
  List<String> get selectedNiches => _selectedNiches;
  bool get isLoading => _isLoading;

  // No longer need to set auth token manually as FirebaseAuth handles it
  void setAuthToken(String? token) {
    // No-op
  }

  Future<void> fetchNiches() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mock data to bypass Firestore permission issues
      _niches = [
        {
          'name': 'Fitness & Wellness',
          'icon': 'fitness_center',
          'positive_keywords': [
            'fitness', 'gym', 'workout', 'exercise', 'health', 'wellness', 'training', 'bodybuilding', 'yoga', 'cardio',
            'crossfit', 'pilates', 'nutrition', 'muscle', 'weightloss', 'running', 'calisthenics', 'physique', 'gains',
            'protein', 'deadlift', 'squat', 'bench press', 'hiit', 'athlete', 'sport', 'marathon', 'triathlon', 'powerlifting',
            'strongman', 'athletics', 'mobility', 'stretching', 'recovery', 'diet', 'macros', 'bulking', 'cutting'
          ],
          'negative_keywords': ['junk food', 'lazy', 'sedentary', 'unhealthy']
        },
        {
          'name': 'Tech Innovations',
          'icon': 'biotech',
          'positive_keywords': ['technology', 'tech', 'innovation', 'AI', 'machine learning', 'startup', 'gadget', 'software', 'hardware', 'blockchain'],
          'negative_keywords': ['outdated', 'obsolete', 'luddite']
        },
        {
          'name': 'Healthy Eating',
          'icon': 'restaurant',
          'positive_keywords': ['healthy', 'nutrition', 'diet', 'organic', 'vegetables', 'fruits', 'meal prep', 'vegan', 'protein', 'superfood'],
          'negative_keywords': ['junk food', 'fast food', 'processed', 'sugar', 'unhealthy']
        },
        {
          'name': 'Personal Development',
          'icon': 'trending_up',
          'positive_keywords': ['self improvement', 'growth', 'productivity', 'motivation', 'goals', 'success', 'mindset', 'habits', 'learning', 'skills'],
          'negative_keywords': ['procrastination', 'lazy', 'failure', 'negativity']
        },
        {
          'name': 'Mindfulness',
          'icon': 'self_improvement',
          'positive_keywords': ['mindfulness', 'meditation', 'mental health', 'awareness', 'peace', 'calm', 'balance', 'serenity', 'zen', 'relaxation'],
          'negative_keywords': ['stress', 'anxiety', 'chaos', 'panic']
        },
        {
          'name': 'Finance & Investing',
          'icon': 'attach_money',
          'positive_keywords': ['finance', 'investing', 'stocks', 'cryptocurrency', 'money', 'wealth', 'savings', 'portfolio', 'trading', 'passive income'],
          'negative_keywords': ['debt', 'broke', 'bankrupt', 'scam']
        },
        {
          'name': 'Art & Design',
          'icon': 'draw',
          'positive_keywords': ['art', 'design', 'creative', 'illustration', 'graphic design', 'UI/UX', 'painting', 'drawing', 'aesthetic', 'visual'],
          'negative_keywords': ['boring', 'ugly', 'bland']
        },
        {
          'name': 'Sustainable Living',
          'icon': 'recycling',
          'positive_keywords': ['sustainable', 'eco friendly', 'green', 'recycling', 'environment', 'climate', 'renewable', 'zero waste', 'organic', 'conservation'],
          'negative_keywords': ['pollution', 'waste', 'harmful', 'toxic']
        },
        {
          'name': 'Travel & Adventure',
          'icon': 'flight_takeoff',
          'positive_keywords': ['travel', 'adventure', 'explore', 'wanderlust', 'vacation', 'tourism', 'backpacking', 'destination', 'journey', 'trip'],
          'negative_keywords': ['homebod', 'boring', 'static']
        },
        {
          'name': 'Startups',
          'icon': 'rocket_launch',
          'positive_keywords': ['startup', 'entrepreneur', 'business', 'innovation', 'founder', 'venture', 'scaling', 'product', 'MVP', 'growth'],
          'negative_keywords': ['failure', 'quit', 'bankruptcy']
        },
        {
          'name': 'Programming',
          'icon': 'code',
          'positive_keywords': ['programming', 'coding', 'developer', 'software', 'javascript', 'python', 'web development', 'algorithm', 'debugging', 'framework'],
          'negative_keywords': ['bug', 'error', 'crash', 'deprecated']
        }
      ];
      
      // Also fetch user selections if logged in
      if (_auth.currentUser != null) {
        await fetchUserNiches();
      }
    } catch (e) {
      print('Error fetching niches: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserNiches() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('selected_niches')) {
          _selectedNiches = List<String>.from(data['selected_niches']);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error fetching user niches: $e');
    }
  }

  void toggleNiche(String nicheName) {
    if (_selectedNiches.contains(nicheName)) {
      _selectedNiches.remove(nicheName);
    } else {
      _selectedNiches.add(nicheName);
    }
    notifyListeners();
  }

  Future<void> saveNiches() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      
      // Only save to Firestore if logged in
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'selected_niches': _selectedNiches,
        }, SetOptions(merge: true));
      }
      
      // ALWAYS sync keywords with native service (local preference)
      await _syncKeywords();
      
    } catch (e) {
      print('Error saving niches: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncKeywords() async {
    try {
      List<String> positive = [];
      List<String> negative = [];

      // Aggregate keywords from selected niches locally
      // (since we have the full niche objects in _niches)
      for (var nicheName in _selectedNiches) {
        final niche = _niches.firstWhere(
          (n) => n['name'] == nicheName,
          orElse: () => {},
        );
        
        if (niche.isNotEmpty) {
          if (niche['positive_keywords'] != null) {
            positive.addAll(List<String>.from(niche['positive_keywords']));
          }
          if (niche['negative_keywords'] != null) {
            negative.addAll(List<String>.from(niche['negative_keywords']));
          }
        }
      }

      // Remove duplicates
      positive = positive.toSet().toList();
      negative = negative.toSet().toList();
      
      await _nativeService.updateKeywords(positive: positive, negative: negative);
      
    } catch (e) {
      print('Error syncing keywords: $e');
    }
  }

  // Temporary method to seed database from the app
  Future<void> seedDatabase() async {
    _isLoading = true;
    notifyListeners();

    final List<Map<String, dynamic>> nichesToSeed = [
      {
        'name': 'Fitness & Wellness',
        'icon': 'fitness_center',
        'positive_keywords': [
          'fitness', 'gym', 'workout', 'exercise', 'health', 'wellness', 'training', 'bodybuilding', 'yoga', 'cardio',
          'crossfit', 'pilates', 'nutrition', 'muscle', 'weightloss', 'running', 'calisthenics', 'physique', 'gains',
          'protein', 'deadlift', 'squat', 'bench press', 'hiit', 'athlete', 'sport', 'marathon', 'triathlon', 'powerlifting',
          'strongman', 'athletics', 'mobility', 'stretching', 'recovery', 'diet', 'macros', 'bulking', 'cutting'
        ],
        'negative_keywords': ['junk food', 'lazy', 'sedentary', 'unhealthy']
      },
      {
        'name': 'Tech Innovations',
        'icon': 'biotech',
        'positive_keywords': ['technology', 'tech', 'innovation', 'AI', 'machine learning', 'startup', 'gadget', 'software', 'hardware', 'blockchain'],
        'negative_keywords': ['outdated', 'obsolete', 'luddite']
      },
      {
        'name': 'Healthy Eating',
        'icon': 'restaurant',
        'positive_keywords': ['healthy', 'nutrition', 'diet', 'organic', 'vegetables', 'fruits', 'meal prep', 'vegan', 'protein', 'superfood'],
        'negative_keywords': ['junk food', 'fast food', 'processed', 'sugar', 'unhealthy']
      },
      {
        'name': 'Personal Development',
        'icon': 'trending_up',
        'positive_keywords': ['self improvement', 'growth', 'productivity', 'motivation', 'goals', 'success', 'mindset', 'habits', 'learning', 'skills'],
        'negative_keywords': ['procrastination', 'lazy', 'failure', 'negativity']
      },
      {
        'name': 'Mindfulness',
        'icon': 'self_improvement',
        'positive_keywords': ['mindfulness', 'meditation', 'mental health', 'awareness', 'peace', 'calm', 'balance', 'serenity', 'zen', 'relaxation'],
        'negative_keywords': ['stress', 'anxiety', 'chaos', 'panic']
      },
      {
        'name': 'Finance & Investing',
        'icon': 'attach_money',
        'positive_keywords': ['finance', 'investing', 'stocks', 'cryptocurrency', 'money', 'wealth', 'savings', 'portfolio', 'trading', 'passive income'],
        'negative_keywords': ['debt', 'broke', 'bankrupt', 'scam']
      },
      {
        'name': 'Art & Design',
        'icon': 'draw',
        'positive_keywords': ['art', 'design', 'creative', 'illustration', 'graphic design', 'UI/UX', 'painting', 'drawing', 'aesthetic', 'visual'],
        'negative_keywords': ['boring', 'ugly', 'bland']
      },
      {
        'name': 'Sustainable Living',
        'icon': 'recycling',
        'positive_keywords': ['sustainable', 'eco friendly', 'green', 'recycling', 'environment', 'climate', 'renewable', 'zero waste', 'organic', 'conservation'],
        'negative_keywords': ['pollution', 'waste', 'harmful', 'toxic']
      },
      {
        'name': 'Travel & Adventure',
        'icon': 'flight_takeoff',
        'positive_keywords': ['travel', 'adventure', 'explore', 'wanderlust', 'vacation', 'tourism', 'backpacking', 'destination', 'journey', 'trip'],
        'negative_keywords': ['homebod', 'boring', 'static']
      },
      {
        'name': 'Startups',
        'icon': 'rocket_launch',
        'positive_keywords': ['startup', 'entrepreneur', 'business', 'innovation', 'founder', 'venture', 'scaling', 'product', 'MVP', 'growth'],
        'negative_keywords': ['failure', 'quit', 'bankruptcy']
      },
      {
        'name': 'Programming',
        'icon': 'code',
        'positive_keywords': ['programming', 'coding', 'developer', 'software', 'javascript', 'python', 'web development', 'algorithm', 'debugging', 'framework'],
        'negative_keywords': ['bug', 'error', 'crash', 'deprecated']
      }
    ];

    try {
      final batch = _firestore.batch();
      
      for (var niche in nichesToSeed) {
        final docRef = _firestore.collection('niches').doc(niche['name']);
        batch.set(docRef, niche);
      }
      
      await batch.commit();
      await fetchNiches(); // Refresh local list
      
    } catch (e) {
      print('Error seeding database: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
