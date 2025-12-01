import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../providers/keyword_provider.dart';

class KeywordManagerScreen extends StatefulWidget {
  const KeywordManagerScreen({super.key});

  @override
  State<KeywordManagerScreen> createState() => _KeywordManagerScreenState();
}

class _KeywordManagerScreenState extends State<KeywordManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future<void>.microtask(
        () => context.read<KeywordProvider>().fetchKeywords(),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addKeyword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final KeywordProvider provider = context.read<KeywordProvider>();
    final String value = _controller.text.trim();
    final bool isPositive = _tabController.index == 0;

    // TODO: Add limit check if needed
    
    provider.addKeyword(value, isPositive: isPositive);
    _controller.clear();
    context.hideKeyboard();
    context.showSnackBar('${isPositive ? "Allowed" : "Blocked"} keyword added');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Keywords'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'Allowed (Positive)'),
            Tab(text: 'Blocked (Negative)'),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'New keyword',
                        hintText: 'e.g., fitness, politics',
                      ),
                      validator: (String? value) {
                        if (!Validators.isValidKeyword(value)) {
                          return 'Invalid keyword format.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addKeyword,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                _KeywordList(isPositive: true),
                _KeywordList(isPositive: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeywordList extends StatelessWidget {
  const _KeywordList({required this.isPositive});

  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final KeywordProvider provider = context.watch<KeywordProvider>();
    final List<String> keywords =
        isPositive ? provider.positiveKeywords : provider.negativeKeywords;

    if (provider.isLoading && keywords.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (keywords.isEmpty) {
      return Center(
        child: Text(
          'No ${isPositive ? "allowed" : "blocked"} keywords yet.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      itemCount: keywords.length,
      itemBuilder: (BuildContext context, int index) {
        final String keyword = keywords[index];
        return ListTile(
          title: Text(keyword),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              provider.removeKeyword(keyword, isPositive: isPositive);
            },
          ),
        );
      },
    );
  }
}
