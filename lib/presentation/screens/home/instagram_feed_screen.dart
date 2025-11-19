import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/credit_provider.dart';
import '../../providers/feed_provider.dart';
import '../../../core/utils/formatters.dart';

class InstagramFeedScreen extends StatefulWidget {
  const InstagramFeedScreen({super.key});

  @override
  State<InstagramFeedScreen> createState() => _InstagramFeedScreenState();
}

class _InstagramFeedScreenState extends State<InstagramFeedScreen> {
  final List<Map<String, dynamic>> _posts = <Map<String, dynamic>>[
    {
      'id': '1',
      'username': 'fitness_guru',
      'userAvatar': 'https://i.pravatar.cc/150?img=1',
      'caption':
          'Morning workout complete! 💪 Nothing beats starting the day with some exercise.',
      'imageUrl':
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&h=500&fit=crop',
      'likes': 2543,
      'comments': 128,
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isLiked': false,
      'isSaved': false,
    },
    {
      'id': '2',
      'username': 'tech_daily',
      'userAvatar': 'https://i.pravatar.cc/150?img=2',
      'caption':
          'The future of AI is here! 🤖 Check out this amazing breakthrough in machine learning.',
      'imageUrl':
          'https://images.unsplash.com/photo-1677442d019cecf8d0b94f27b2d4ecf0',
      'likes': 5234,
      'comments': 342,
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
      'isLiked': false,
      'isSaved': false,
    },
    {
      'id': '3',
      'username': 'travel_vibes',
      'userAvatar': 'https://i.pravatar.cc/150?img=3',
      'caption':
          'Paradise found! 🏝️ Nothing like a sunset on the beach to remind you what matters.',
      'imageUrl':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&h=500&fit=crop',
      'likes': 8934,
      'comments': 567,
      'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
      'isLiked': false,
      'isSaved': false,
    },
    {
      'id': '4',
      'username': 'food_lover',
      'userAvatar': 'https://i.pravatar.cc/150?img=4',
      'caption':
          'Homemade pizza night! 🍕 The best meals are made with love and shared with friends.',
      'imageUrl':
          'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?w=500&h=500&fit=crop',
      'likes': 3456,
      'comments': 234,
      'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
      'isLiked': false,
      'isSaved': false,
    },
    {
      'id': '5',
      'username': 'nature_explorer',
      'userAvatar': 'https://i.pravatar.cc/150?img=5',
      'caption':
          'Hiking season is here! 🏔️ The mountains are calling and I must go.',
      'imageUrl':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500&h=500&fit=crop',
      'likes': 6789,
      'comments': 445,
      'timestamp': DateTime.now().subtract(const Duration(hours: 10)),
      'isLiked': false,
      'isSaved': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final CreditProvider creditProvider = context.watch<CreditProvider>();
    final bool hasCredits = creditProvider.totalCredits > 0;

    if (hasCredits) {
      creditProvider.startCountdown();
    }

    return Stack(
      children: <Widget>[
        // Feed
        if (hasCredits)
          ListView.builder(
            itemCount: _posts.length,
            itemBuilder: (BuildContext context, int index) {
              final post = _posts[index];
              return _buildPostCard(context, post);
            },
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13ec6a).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Color(0xFF13ec6a),
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No credits left',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Complete exercises to earn more scroll time',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      DefaultTabController.of(context).animateTo(2);
                    },
                    icon: const Icon(Icons.fitness_center),
                    label: const Text('Go to Exercise'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF13ec6a),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Credits overlay
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.timer, color: Color(0xFF13ec6a), size: 18),
                const SizedBox(width: 8),
                Text(
                  formatCredits(creditProvider.totalCredits),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(post['userAvatar'] as String),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        post['username'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _getTimeAgo(post['timestamp'] as DateTime),
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
          ),
          // Image
          ClipRRect(
            child: Image.network(
              post['imageUrl'] as String,
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 400,
                  color: Colors.grey.withOpacity(0.2),
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    post['isLiked'] as bool
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: post['isLiked'] as bool ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    final FeedProvider feedProvider = context
                        .read<FeedProvider>();
                    setState(() {
                      post['isLiked'] = !(post['isLiked'] as bool);
                      if (post['isLiked'] as bool) {
                        post['likes'] = (post['likes'] as int) + 1;
                        feedProvider.incrementPostsLiked();
                      } else {
                        post['likes'] = (post['likes'] as int) - 1;
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {},
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    post['isSaved'] as bool
                        ? Icons.bookmark
                        : Icons.bookmark_outline,
                    color: post['isSaved'] as bool
                        ? const Color(0xFF13ec6a)
                        : Colors.black,
                  ),
                  onPressed: () {
                    final FeedProvider feedProvider = context
                        .read<FeedProvider>();
                    setState(() {
                      post['isSaved'] = !(post['isSaved'] as bool);
                      if (post['isSaved'] as bool) {
                        feedProvider.incrementPostsSaved();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          // Likes and caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${post['likes']} likes',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: '${post['username']} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: post['caption'] as String,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View all ${post['comments']} comments',
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
