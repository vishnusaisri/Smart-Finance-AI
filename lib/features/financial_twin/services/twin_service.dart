import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/validation_utils.dart';
import 'twin_simulator_engine.dart';

final twinServiceProvider = Provider<TwinService>((ref) {
  return TwinService();
});

class TwinService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';
  
  DatabaseReference get _twinDataRef {
    return _database.ref('users/$_userId/simulations/latest');
  }

  Map<String, dynamic>? _convertToMap(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return data.map((key, value) {
        final keyString = key.toString();
        if (value is Map) {
          return MapEntry(keyString, _convertToMap(value));
        } else if (value is List) {
          return MapEntry(keyString, value.map((item) {
            if (item is Map) {
              return _convertToMap(item);
            }
            return item;
          }).toList());
        }
        return MapEntry(keyString, value);
      });
    }
    return null;
  }

  Future<void> saveSimulationResult(TwinSimulationResult result) async {
    if (_userId.isEmpty) return;
    
    await _twinDataRef.set({
      'currentTrajectory': result.currentTrajectory,
      'optimizedTrajectory': result.optimizedTrajectory,
      'monthLabels': result.monthLabels,
      'currentNetWorth': result.currentNetWorth,
      'optimizedNetWorth': result.optimizedNetWorth,
      'recommendations': result.recommendations,
      'updatedAt': ServerValue.timestamp,
    });
    debugPrint('Simulation result saved');
  }

  Future<TwinSimulationResult?> getLatestSimulation() async {
    if (_userId.isEmpty) return null;
    
    try {
      final snapshot = await _twinDataRef.get();
      if (!snapshot.exists || snapshot.value == null) return null;
      
      final Map<String, dynamic> data = _convertToMap(snapshot.value) ?? {};
      
      return TwinSimulationResult(
        currentTrajectory: (data['currentTrajectory'] as List?)?.map((e) => safeDouble(e)).toList() ?? [],
        optimizedTrajectory: (data['optimizedTrajectory'] as List?)?.map((e) => safeDouble(e)).toList() ?? [],
        monthLabels: (data['monthLabels'] as List?)?.map((e) => e.toString()).toList() ?? [],
        currentNetWorth: safeDouble(data['currentNetWorth']),
        optimizedNetWorth: safeDouble(data['optimizedNetWorth']),
        recommendations: (data['recommendations'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
    } catch (e) {
      debugPrint('Error getting simulation: $e');
      return null;
    }
  }

  // Real-time stream for simulation updates
  Stream<TwinSimulationResult?> watchSimulation() {
    if (_userId.isEmpty) return Stream.value(null);
    
    return _twinDataRef.onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null || val is! Map) return null;
      final Map<String, dynamic> data = _convertToMap(val) ?? {};
      return TwinSimulationResult(
        currentTrajectory: (data['currentTrajectory'] as List?)?.map((e) => safeDouble(e)).toList() ?? [],
        optimizedTrajectory: (data['optimizedTrajectory'] as List?)?.map((e) => safeDouble(e)).toList() ?? [],
        monthLabels: (data['monthLabels'] as List?)?.map((e) => e.toString()).toList() ?? [],
        currentNetWorth: safeDouble(data['currentNetWorth']),
        optimizedNetWorth: safeDouble(data['optimizedNetWorth']),
        recommendations: (data['recommendations'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
    });
  }
}
