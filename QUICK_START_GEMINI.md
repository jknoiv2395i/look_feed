# ⚡ QUICK START: Gemini Classification

**Get up and running in 10 minutes**

---

## 🚀 STEP 1: Get API Key (5 minutes)

```
1. Open: https://aistudio.google.com/app/apikey
2. Click: "Create API Key"
3. Copy: Your API key
4. Done! ✅
```

---

## 📝 STEP 2: Add to .env (1 minute)

**Create file**: `look_feed/.env`

```env
GOOGLE_AI_API_KEY=your-key-here
```

---

## 📦 STEP 3: Install Dependencies (2 minutes)

```bash
cd look_feed
flutter pub get
```

---

## ✅ STEP 4: Verify (2 minutes)

```bash
flutter run
```

**Check logs for**:
```
✅ Gemini Classifier initialized successfully
```

---

## 💻 STEP 5: Use in Code (1 minute)

```dart
import 'package:provider/provider.dart';
import 'package:feed_lock/presentation/providers/classification_provider.dart';

// In your widget
final provider = context.read<ClassificationProvider>();

final result = await provider.classifyPost(
  caption: "Post caption",
  hashtags: ["#tag1", "#tag2"],
  userKeywords: ["keyword1", "keyword2"],
);

print(result.decision); // "SHOW", "HIDE", or "UNCERTAIN"
```

---

## 📊 WHAT YOU GET

| Feature | Value |
|---------|-------|
| **Cost** | $0/month |
| **Speed** | 200-500ms |
| **Rate Limit** | 15 req/min |
| **Daily Limit** | 1500 req/day |
| **Model** | gemini-1.5-flash |

---

## 🎯 CLASSIFICATION RESULT

```dart
ClassificationResult(
  relevanceScore: 0.85,      // 0.0 - 1.0
  decision: "SHOW",          // "SHOW", "HIDE", "UNCERTAIN"
  isAiClassified: true,
  timestamp: DateTime.now(),
)
```

---

## 🔍 DECISION LOGIC

```
Score > 0.7  → SHOW       (High confidence)
Score < 0.4  → HIDE       (Low confidence)
0.4 ≤ Score ≤ 0.7 → Ask Gemini
```

---

## 📚 FULL DOCUMENTATION

- **Setup**: `FLUTTER_GEMINI_IMPLEMENTATION.md`
- **Architecture**: `ARCHITECTURE_UPDATE_CLIENT_SIDE_AI.md`
- **Summary**: `REFACTORING_COMPLETE_SUMMARY.md`

---

## 🆘 TROUBLESHOOTING

### API Key Not Found?
```bash
# Create .env file
echo "GOOGLE_AI_API_KEY=your-key" > .env
```

### Rate Limit Exceeded?
```dart
// Check remaining requests
final status = provider.rateLimitStatus;
if (status['remaining'] == 0) {
  // Wait 1 minute or use fallback
}
```

### Classification Failed?
```dart
// Automatic fallback to keyword matching
// No action needed - handled automatically
```

---

## ✨ THAT'S IT!

You're ready to use Gemini classification! 🎉

**Next**: Integrate with your feed screen using the examples in `feed_classification_example.dart`

---

**Status**: ✅ **READY TO USE**
