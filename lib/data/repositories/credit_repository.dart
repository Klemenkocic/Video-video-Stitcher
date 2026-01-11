import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'credit_repository.g.dart';

class CreditRepository {
  final SupabaseClient _client;

  CreditRepository(this._client);

  Stream<int> watchCredits() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value(0);

    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((event) {
          if (event.isEmpty) return 0;
          return event.first['credits'] as int? ?? 0;
        });
  }

  /// Attempts to deduct credits via database RPC.
  /// Returns true if successful, false if insufficient funds.
  Future<bool> deductCredits(int amount, String description) async {
    try {
      final success = await _client.rpc('deduct_credits', params: {
        'amount': amount,
        'description': description,
      });
      return success as bool;
    } catch (e) {
      // If RPC fails (e.g. function not found), logs error
      print('Credit deduction failed: $e');
      return false;
    }
  }

  // For testing/demo purposes
  Future<void> addCredits(int amount) async {
    await _client.rpc('top_up_credits', params: {
      'amount': amount,
      'description': 'Test Top Up',
    });
  }
}

@riverpod
CreditRepository creditRepository(CreditRepositoryRef ref) {
  return CreditRepository(Supabase.instance.client);
}

@riverpod
Stream<int> userCredits(UserCreditsRef ref) {
  return ref.watch(creditRepositoryProvider).watchCredits();
}
