import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController(
    text: '10000',
  );
  String _from = 'XOF';
  String _to = 'EUR';
  bool _isLoading = false;
  String? _error;
  double? _result;
  double? _rate;
  Timer? _convertDebounce;

  static const _currencies = ['XOF', 'EUR', 'USD'];

  void _appendAmount(String value) {
    final current = _amountController.text.trim();
    if (value == '⌫') {
      if (current.isEmpty) return;
      _amountController.text = current.substring(0, current.length - 1);
      return;
    }
    if (value == ',' && current.contains('.')) return;
    if (value == ',') {
      _amountController.text = current.isEmpty ? '0.' : '$current.';
      return;
    }
    _amountController.text = '$current$value';
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _from;
      _from = _to;
      _to = temp;
    });
    _convert();
  }

  void _scheduleConvert() {
    _convertDebounce?.cancel();
    _convertDebounce = Timer(const Duration(milliseconds: 280), _convert);
  }

  @override
  void initState() {
    super.initState();
    _convert();
  }

  @override
  void dispose() {
    _convertDebounce?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _convert() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      setState(() {
        _error = 'Montant invalide';
        _result = null;
        _rate = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService().convertCurrency(
        amount: amount,
        from: _from,
        to: _to,
      );
      if (!mounted) return;
      setState(() {
        _result = (data['converted_amount'] as num?)?.toDouble();
        _rate = (data['rate'] as num?)?.toDouble();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _result = null;
        _rate = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
                const Spacer(),
                Text(
                  'Convertisseur',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: const Color(0xFF1A1F2E),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 4),
            Center(
              child: Column(
                children: [
                  Text(
                    'TAUX DE CHANGE EN DIRECT',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF46609),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Convertisseur FCFA',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rate == null
                        ? 'Taux indisponible'
                        : '1 $_from = ${_rate!.toStringAsFixed(4)} $_to',
                    style: GoogleFonts.robotoMono(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 6),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF2E8B57), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vous payez',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _amountController.text.trim().isEmpty
                            ? '0'
                            : _amountController.text.trim(),
                        style: GoogleFonts.robotoSlab(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1F2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCurrencyChip(value: _from),
                  ],
                ),
              ],
            ),
            ),
            Transform.translate(
            offset: const Offset(0, -14),
            child: Center(
              child: InkWell(
                onTap: _swapCurrencies,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1F2E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_vert_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            ),
            Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5DFD3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _result == null ? '-' : _result!.toStringAsFixed(2),
                    style: GoogleFonts.robotoSlab(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF57A6E7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildCurrencyChip(value: _to),
              ],
            ),
            ),
            const SizedBox(height: 8),
            if (_error != null)
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppTheme.primaryRed),
              ),
            const SizedBox(height: 8),
            GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.6,
            children: [
              for (final key in ['1', '2', '3', '4', '5', '6', '7', '8', '9', ',', '0', '⌫'])
                InkWell(
                  onTap: () {
                    setState(() => _appendAmount(key));
                    _scheduleConvert();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5DFD3)),
                    ),
                    child: Center(
                      child: Text(
                        key,
                        style: GoogleFonts.robotoSlab(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyChip({required String value}) {
    return PopupMenuButton<String>(
      onSelected: (v) {
        setState(() {
          if (value == _from) {
            _from = v;
          } else {
            _to = v;
          }
        });
        _convert();
      },
      itemBuilder: (context) => _currencies
          .map((e) => PopupMenuItem(value: e, child: Text(e)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F1EA),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}

