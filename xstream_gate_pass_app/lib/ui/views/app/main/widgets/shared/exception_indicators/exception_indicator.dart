import 'package:flutter/material.dart';

/// Basic layout for indicating that an exception occurred.
class ExceptionIndicator extends StatelessWidget {
  const ExceptionIndicator({
    required this.title,
    required this.assetName,
    required this.message,
    required this.onTryAgain,
    this.hideTryButton = false,
    Key? key,
  })  : assert(title != null),
        assert(assetName != null),
        super(key: key);
  final String title;
  final String message;
  final String assetName;
  final VoidCallback onTryAgain;
  final bool hideTryButton;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 75),
          child: Column(
            children: [
              Image.asset(
                assetName,
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
              if (message != null)
                const SizedBox(
                  height: 6,
                ),
              if (message != null)
                Text(
                  message,
                  textAlign: TextAlign.center,
                ),
              if (hideTryButton == false)
                const SizedBox(
                  height: 6,
                ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  icon: Icon(
                    Icons.login,
                    size: 28,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: onTryAgain,
                ),
              ),
            ],
          ),
        ),
      );
}
