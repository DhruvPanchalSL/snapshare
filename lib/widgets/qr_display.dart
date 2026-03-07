import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/transfer_model.dart';

class QrDisplay extends StatelessWidget {
  final TransferModel transfer;

  const QrDisplay({super.key, required this.transfer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          QrImageView(
            data: transfer.code,
            version: QrVersions.auto,
            size: 180,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            'Scan to receive',
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
