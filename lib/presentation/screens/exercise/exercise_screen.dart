import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exercise_provider.dart';
import '../../providers/credit_provider.dart';
import '../../providers/exercise_stats_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/exercise_entity.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExerciseProvider provider = context.watch<ExerciseProvider>();
    final CreditProvider creditProvider = context.read<CreditProvider>();
    final ExerciseStatsProvider statsProvider = context
        .read<ExerciseStatsProvider>();

    final bool isActive = provider.isRecording;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF13ec6a).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Exercise to unlock your feed',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Consumer<CreditProvider>(
                    builder: (BuildContext context, CreditProvider credits, _) {
                      return Text(
                        'Current credits: ${formatCredits(credits.totalCredits)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ExerciseType.values
                    .map(
                      (ExerciseType type) => ChoiceChip(
                        label: Text(type.name),
                        selected: provider.currentExercise == type,
                        onSelected: (_) => provider.selectExercise(type),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              SwitchListTile.adaptive(
                title: const Text('Use camera detection'),
                value: provider.useCameraDetection,
                onChanged: provider.toggleCameraDetection,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF13ec6a).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF13ec6a).withOpacity(0.3)
                              : Colors.grey.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '${provider.reps}',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? const Color(0xFF13ec6a)
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'reps',
                            style: TextStyle(
                              fontSize: 16,
                              color: isActive
                                  ? const Color(0xFF13ec6a)
                                  : Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton.icon(
                          onPressed: () {
                            if (isActive) {
                              final int reps = provider.reps;
                              provider.stopSession();
                              if (reps > 0) {
                                creditProvider.addCredits(reps);
                                creditProvider.startCountdown();
                                statsProvider.addSession(reps, reps);
                                context.showSnackBar(
                                  'Added $reps minutes of credits',
                                );
                                // Auto-navigate to Instagram after earning credits
                                Future<void>.delayed(
                                  const Duration(milliseconds: 1500),
                                  () {
                                    DefaultTabController.of(
                                      context,
                                    ).animateTo(1);
                                  },
                                );
                              }
                            } else {
                              provider.startSession();
                            }
                          },
                          icon: Icon(isActive ? Icons.stop : Icons.play_arrow),
                          label: Text(
                            isActive ? 'Stop Session' : 'Start Session',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isActive
                                ? Colors.red
                                : const Color(0xFF13ec6a),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: provider.incrementRep,
                          icon: const Icon(Icons.add),
                          label: const Text('Manual rep'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF13ec6a).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF13ec6a),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Session in progress...',
                              style: TextStyle(
                                color: Color(0xFF13ec6a),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
