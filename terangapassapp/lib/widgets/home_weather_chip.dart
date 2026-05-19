import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pastille météo sur la bannière d’accueil (coin haut-gauche).
class HomeWeatherChip extends StatelessWidget {
  const HomeWeatherChip({
    super.key,
    required this.temperatureC,
    required this.label,
    required this.iconKey,
    this.placeName,
    this.isLoading = false,
  });

  final int? temperatureC;
  final String label;
  final String iconKey;
  final String? placeName;
  final bool isLoading;

  IconData _iconForKey(String key) {
    switch (key) {
      case 'sunny':
        return Icons.wb_sunny_rounded;
      case 'partly_cloudy':
        return Icons.wb_cloudy_rounded;
      case 'rain':
        return Icons.grain_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'fog':
        return Icons.blur_on_rounded;
      default:
        return Icons.cloud_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPlace =
        placeName != null && placeName!.trim().isNotEmpty && !isLoading;

    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isLoading
          ? const SizedBox(
              width: 72,
              height: 36,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _iconForKey(iconKey),
                  color: const Color(0xFFFFD54F),
                  size: 26,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        temperatureC != null ? '$temperatureC°C' : '--°C',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      if (hasPlace) ...[
                        const SizedBox(height: 3),
                        Text(
                          placeName!.trim(),
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 1.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
