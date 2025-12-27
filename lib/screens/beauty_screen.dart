import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../widgets/option_selector.dart';

class BeautyScreen extends StatefulWidget {
  const BeautyScreen({super.key});

  @override
  State<BeautyScreen> createState() => _BeautyScreenState();
}

class _BeautyScreenState extends State<BeautyScreen> {
  String? _selectedService;

  final List<String> _services = ['cut', 'perm', 'color'];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _save() async {
    if (_selectedService == null) {
      return;
    }

    final provider = Provider.of<MemoryProvider>(context, listen: false);
    final memory = BeautyMemory(
      service: _selectedService!,
    );

    await provider.addMemory(memory);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('미용 기록이 저장되었습니다'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('미용실'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OptionSelector<String>(
              title: '서비스',
              options: _services.map((s) {
                String label;
                switch (s) {
                  case 'cut':
                    label = '컷트';
                    break;
                  case 'perm':
                    label = '펌';
                    break;
                  case 'color':
                    label = '염색';
                    break;
                  default:
                    label = s;
                }
                return OptionItem(value: s, label: label);
              }).toList(),
              selectedValue: _selectedService,
              onSelected: (value) {
                setState(() {
                  _selectedService = value;
                });
                _save(); // Auto-save on selection
              },
            ),
          ],
        ),
      ),
    );
  }
}

