import 'package:flutter/material.dart';
import '../tts_controller.dart';
import '../widgets/large_back_button.dart';

class YesNoScreen extends StatelessWidget {
  const YesNoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LargeBackButton(),
        title: const Text('Yes / No'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              // YES button - left side
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    TtsController.instance.speak('Yes');
                  },
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate icon size based on available space
                        final iconSize = (constraints.maxHeight * 0.3).clamp(60.0, 140.0);
                        final fontSize = (constraints.maxHeight * 0.15).clamp(32.0, 80.0);
                        
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: iconSize,
                                color: Colors.white,
                              ),
                              SizedBox(height: constraints.maxHeight * 0.05),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'YES',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 4,
                                    ),
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // NO button - right side
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    TtsController.instance.speak('No');
                  },
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate icon size based on available space
                        final iconSize = (constraints.maxHeight * 0.3).clamp(60.0, 140.0);
                        final fontSize = (constraints.maxHeight * 0.15).clamp(32.0, 80.0);
                        
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel_rounded,
                                size: iconSize,
                                color: Colors.white,
                              ),
                              SizedBox(height: constraints.maxHeight * 0.05),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'NO',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 4,
                                    ),
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}