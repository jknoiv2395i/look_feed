import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exercise_provider.dart';
import '../../../domain/entities/exercise_entity.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExerciseProvider provider = context.watch<ExerciseProvider>();

    final bool isActive = provider.isRecording;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Exercise to unlock your feed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    Text(
                      '${provider.reps}',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('reps'),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton.icon(
                          onPressed: () {
                            if (isActive) {
                              provider.stopSession();
                            } else {
                              provider.startSession();
                            }
                          },
                          icon: Icon(isActive ? Icons.stop : Icons.play_arrow),
                          label: Text(isActive ? 'Stop' : 'Start'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: provider.incrementRep,
                          icon: const Icon(Icons.add),
                          label: const Text('Manual rep'),
                        ),
                      ],
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
