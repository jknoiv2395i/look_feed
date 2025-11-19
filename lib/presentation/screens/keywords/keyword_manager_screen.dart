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

class _KeywordManagerScreenState extends State<KeywordManagerScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  bool _initialized = false;

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
    super.dispose();
  }

  Future<void> _addKeyword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final KeywordProvider provider = context.read<KeywordProvider>();
    final String value = _controller.text.trim();

    if (provider.keywords.length >= provider.keywordLimit) {
      context.showSnackBar('You have reached your keyword limit.');
      return;
    }

    provider.addKeyword(value);
    _controller.clear();
    context.hideKeyboard();
    context.showSnackBar('Keyword added');
  }

  @override
  Widget build(BuildContext context) {
    final KeywordProvider provider = context.watch<KeywordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Keywords'),
            Text(
              '${provider.keywords.length}/${provider.keywordLimit} used',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Add keywords to prioritize posts that matter to you. '
              'On the free tier you can add up to ${provider.keywordLimit} keyword(s).',
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'New keyword',
                      ),
                      validator: (String? value) {
                        if (!Validators.isValidKeyword(value)) {
                          return 'Only letters, numbers and spaces (max 100 chars).';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: provider.keywords.length >= provider.keywordLimit
                        ? null
                        : _addKeyword,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (provider.isLoading && provider.keywords.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (provider.keywords.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No keywords yet. Add your first keyword above.'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: provider.keywords.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String keyword = provider.keywords[index];
                    return ListTile(
                      title: Text(keyword),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          provider.removeKeyword(keyword);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
