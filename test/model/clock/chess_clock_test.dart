import 'package:dartchess/dartchess.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lichess_mobile/src/model/clock/chess_clock.dart';

void main() {
  test('make clock', () {
    final clock = ChessClock(
      whiteTime: const Duration(seconds: 5),
      blackTime: const Duration(seconds: 5),
    );
    expect(clock.isRunning, false);
    expect(clock.whiteTime.value, const Duration(seconds: 5));
    expect(clock.blackTime.value, const Duration(seconds: 5));
  });

  test('start clock', () {
    fakeAsync((async) {
      final clock = ChessClock(
        whiteTime: const Duration(seconds: 5),
        blackTime: const Duration(seconds: 5),
      );
      clock.start();
      expect(clock.isRunning, true);
    });
  });

  test('clock ticking', () {
    fakeAsync((async) {
      final clock = ChessClock(
        whiteTime: const Duration(seconds: 5),
        blackTime: const Duration(seconds: 5),
      );
      clock.start();
      expect(clock.whiteTime.value, const Duration(seconds: 5));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      async.elapse(const Duration(seconds: 1));
      expect(clock.whiteTime.value, const Duration(seconds: 4));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      async.elapse(const Duration(seconds: 1));
      expect(clock.whiteTime.value, const Duration(seconds: 3));
      expect(clock.blackTime.value, const Duration(seconds: 5));
    });
  });

  test('stop clock', () {
    fakeAsync((async) {
      final clock = ChessClock(
        whiteTime: const Duration(seconds: 5),
        blackTime: const Duration(seconds: 5),
      );
      clock.start();
      expect(clock.isRunning, true);
      async.elapse(const Duration(seconds: 1));
      expect(clock.whiteTime.value, const Duration(seconds: 4));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      final thinkTime = clock.stop();
      expect(clock.isRunning, false);
      expect(thinkTime, const Duration(seconds: 1));
      async.elapse(const Duration(seconds: 1));
      expect(clock.whiteTime.value, const Duration(seconds: 4));
      expect(clock.blackTime.value, const Duration(seconds: 5));
    });
  });

  test('start side', () {
    fakeAsync((async) {
      final clock = ChessClock(
        whiteTime: const Duration(seconds: 5),
        blackTime: const Duration(seconds: 5),
      );
      final thinkTime = clock.startSide(Side.black);
      expect(thinkTime, null);
      async.elapse(const Duration(seconds: 1));
      expect(clock.whiteTime.value, const Duration(seconds: 5));
      expect(clock.blackTime.value, const Duration(seconds: 4));
    });
  });

  test('start side (running clock)', () {
    fakeAsync((async) {
      final clock = ChessClock(
        whiteTime: const Duration(seconds: 5),
        blackTime: const Duration(seconds: 5),
      );
      clock.start();
      expect(clock.isRunning, true);
      expect(clock.whiteTime.value, const Duration(seconds: 5));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      async.elapse(const Duration(seconds: 1));
      expect(clock.whiteTime.value, const Duration(seconds: 4));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      final thinkTime = clock.startSide(Side.black);
      expect(thinkTime, const Duration(seconds: 1));
      async.elapse(const Duration(seconds: 1));
      expect(clock.whiteTime.value, const Duration(seconds: 4));
      expect(clock.blackTime.value, const Duration(seconds: 4));
    });
  });

  test('start side (running clock, same side)', () {
    fakeAsync((async) {
      final clock = ChessClock(
        whiteTime: const Duration(seconds: 5),
        blackTime: const Duration(seconds: 5),
      );
      clock.start();
      expect(clock.isRunning, true);
      expect(clock.whiteTime.value, const Duration(seconds: 5));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      async.elapse(const Duration(seconds: 1));
      expect(clock.whiteTime.value, const Duration(seconds: 4));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      final thinkTime = clock.startSide(Side.white);
      expect(thinkTime, const Duration(seconds: 1));
      async.elapse(const Duration(seconds: 1));
      expect(clock.whiteTime.value, const Duration(seconds: 3));
      expect(clock.blackTime.value, const Duration(seconds: 5));
    });
  });

  test('start with delay', () {
    fakeAsync((async) {
      final clock = ChessClock(
        whiteTime: const Duration(seconds: 5),
        blackTime: const Duration(seconds: 5),
      );
      clock.start(delay: const Duration(milliseconds: 20));
      expect(clock.isRunning, true);
      expect(clock.whiteTime.value, const Duration(seconds: 5));
      async.elapse(const Duration(milliseconds: 10));
      expect(clock.whiteTime.value, const Duration(seconds: 5));
      // the start delay is reached, but clock not updated yet since tick delay is 100ms
      async.elapse(const Duration(milliseconds: 100));
      expect(clock.whiteTime.value, const Duration(seconds: 5));
      async.elapse(const Duration(milliseconds: 10));
      expect(clock.whiteTime.value, const Duration(milliseconds: 4900));
      final thinkTime = clock.stop();
      expect(thinkTime, const Duration(milliseconds: 100));
    });
  });

  test('increment times', () {
    fakeAsync((async) {
      final clock = ChessClock(
        whiteTime: const Duration(seconds: 5),
        blackTime: const Duration(seconds: 5),
      );
      clock.start();
      expect(clock.whiteTime.value, const Duration(seconds: 5));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      clock.incTimes(whiteInc: const Duration(seconds: 1));
      expect(clock.whiteTime.value, const Duration(seconds: 6));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      clock.incTimes(blackInc: const Duration(seconds: 1));
      expect(clock.whiteTime.value, const Duration(seconds: 6));
      expect(clock.blackTime.value, const Duration(seconds: 6));
    });
  });

  test('increment specific side', () {
    fakeAsync((async) {
      final clock = ChessClock(
        whiteTime: const Duration(seconds: 5),
        blackTime: const Duration(seconds: 5),
      );
      clock.start();
      expect(clock.whiteTime.value, const Duration(seconds: 5));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      clock.incTime(Side.white, const Duration(seconds: 1));
      expect(clock.whiteTime.value, const Duration(seconds: 6));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      clock.incTime(Side.black, const Duration(seconds: 1));
      expect(clock.whiteTime.value, const Duration(seconds: 6));
      expect(clock.blackTime.value, const Duration(seconds: 6));
    });
  });

  test('flag', () {
    fakeAsync((async) {
      int flagCount = 0;
      final clock = ChessClock(
        whiteTime: const Duration(seconds: 5),
        blackTime: const Duration(seconds: 5),
        onFlag: () {
          flagCount++;
        },
      );
      clock.start();
      expect(clock.whiteTime.value, const Duration(seconds: 5));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      async.elapse(const Duration(seconds: 5));
      expect(flagCount, 1);
      expect(clock.whiteTime.value, Duration.zero);
      expect(clock.blackTime.value, const Duration(seconds: 5));

      // continue ticking and calling onFlag
      async.elapse(const Duration(milliseconds: 200));
      expect(flagCount, 3);
      clock.stop();

      // no more onFlag calls
      async.elapse(const Duration(seconds: 5));
      expect(flagCount, 3);
    });
  });

  test('onEmergency', () {
    fakeAsync((async) {
      int onEmergencyCount = 0;
      final clock = ChessClock(
        whiteTime: const Duration(seconds: 5),
        blackTime: const Duration(seconds: 5),
        emergencyThreshold: const Duration(seconds: 2),
        onEmergency: (_) {
          onEmergencyCount++;
        },
      );
      clock.start();
      expect(clock.whiteTime.value, const Duration(seconds: 5));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      async.elapse(const Duration(seconds: 2));
      expect(clock.whiteTime.value, const Duration(seconds: 3));
      expect(clock.blackTime.value, const Duration(seconds: 5));
      async.elapse(const Duration(seconds: 1));
      expect(onEmergencyCount, 1);
      async.elapse(const Duration(milliseconds: 100));
      expect(onEmergencyCount, 1);
    });
  });

  // This bug was caused by the "have we played the emergency sound" flag not being tracked separately per side.
  test('Regression tests for issue #1626', () {
    fakeAsync((async) {
      int onEmergencyCount = 0;
      final clock = ChessClock(
        whiteTime: const Duration(seconds: 60),
        blackTime: const Duration(seconds: 60),
        emergencyThreshold: const Duration(seconds: 30),
        onEmergency: (_) {
          onEmergencyCount++;
        },
      );
      clock.start();
      async.elapse(const Duration(seconds: 30));
      expect(onEmergencyCount, 1);

      // Switch to black. We're above 1.5x the emergency threshold, so this used to reset the flag (for both sides).
      clock.startSide(Side.black);
      // There's an internal 20s cooldown for the emergency callback, so wait for that.
      async.elapse(const Duration(seconds: 20));
      expect(onEmergencyCount, 1);

      // Switch back to white, this used to incorrectly play the sound again
      clock.startSide(Side.white);
      async.elapse(const Duration(milliseconds: 100));
      expect(onEmergencyCount, 1);
    });
  });
}
