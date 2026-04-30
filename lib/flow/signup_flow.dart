import 'package:flutter/material.dart';

class SignupFlow extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const SignupFlow({super.key, required this.onComplete});

  @override
  State<SignupFlow> createState() => _SignupFlowState();
}

class _SignupFlowState extends State<SignupFlow> {
  int step = 0;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final cityCtrl = TextEditingController();

  String? style;
  double? lat;
  double? lon;

  void next() => setState(() => step++);

  @override
  Widget build(BuildContext context) {
    final steps = [
      _step1(),
      _step2(),
      _step3(),
      _step4(),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001B33), Color(0xFF0071BB)],
          ),
        ),
        child: Center(child: steps[step]),
      ),
    );
  }

  Widget _step1() {
    return _box(
      title: "Your Pirate Name",
      child: TextField(controller: nameCtrl),
      onNext: next,
    );
  }

  Widget _step2() {
    return _box(
      title: "Your Email",
      child: TextField(controller: emailCtrl),
      onNext: next,
    );
  }

  Widget _step3() {
    return _box(
      title: "Create Password",
      child: TextField(controller: passCtrl, obscureText: true),
      onNext: next,
    );
  }

  Widget _step4() {
    return _box(
      title: "Choose Your Origin",
      child: TextField(controller: cityCtrl),
      onNext: () {
        widget.onComplete({
          "pirate_name": nameCtrl.text,
          "email": emailCtrl.text,
          "password": passCtrl.text,
          "city": cityCtrl.text,
          "lat": lat,
          "lon": lon,
        });
      },
    );
  }

  Widget _box({required String title, required Widget child, required VoidCallback onNext}) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          child,
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onNext, child: const Text("Next")),
        ],
      ),
    );
  }
}