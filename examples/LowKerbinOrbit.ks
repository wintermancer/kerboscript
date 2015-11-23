//The MIT License (MIT)
//
// Copyright (c) 2015 Wintermancer <wintermancer13 at googlemail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

// welcome to kOS
// this simple example will guide you through your first kOS script
// which allows you to bring a specific rocket into Low Kerbin Orbit ( LKO )
// to see the reference ship, please follow this link <will be inserted later>
// Other rockets may but must not work.
CLEARSCREEN.

// Let us start with a simple countdown
PRINT "Counting down".
FROM {
  local countdown is 3.
  } UNTIL countdown = 0 STEP {
    SET countdown to countdown - 1.
    } DO {
    PRINT "..." + countdown.
    WAIT 1.
}

// We initialize a new variable for our throttle and lock throttle onto it.
// Also make sure we fly straight up. Nothing else.
set tValue to 0.
lock throttle to tValue.
lock steering to up + R(0, 0, 0).

// We ignite our main engine and prepare for throttle up
PRINT "Main engine ignition".
stage.
// throttle up to 10% thrust. We should still be at the ramp docked to the clamps
PRINT "Preliminary thrust level".
set tValue to 0.1.
wait 1.
// ok enough show effect. Lets go to space. Throttle to 100% and get rid of the
// clamps.
PRINT "Maximum thrust level".
set tValue to 1.0.
stage.

// check if we raise from the ground. If yes - celebrate Liftoff
set startalt to alt:radar + 5.
when alt:radar > startalt then {
  PRINT "Liftoff".
}

// This is dirty but we just assume you are using the right rocket for this
// example. Ihf you have no boosters, prepare for some surprise staging :D
WHEN STAGE:SOLIDFUEL < 0.1 THEN {
  PRINT "Boosters burnt out".
  stage.
}

// OK we are clear of the Launchpad. Initialize the KERBIN_ASCENT FUNCTION
// In this example we start turning at 3km and burn until 80km APOAPSIS.
// We head into eastern direction ( -90 degree on the zAxis)
KERBIN_ASCENT(3000,80000,-90).

DECLARE FUNCTION KERBIN_ASCENT {
  DECLARE PARAMETER turnHeight.
  DECLARE PARAMETER apoapsisHeight.
  DECLARE PARAMETER zValue.
  set xValue to 0.0.
  set yValue to 0.0.
  // Write some cool log output and then wait until we are intended to start
  // with our roll and gravity turn maneuvers.
  PRINT "Starting gravity turn subsequence at " + turnHeight.
  PRINT "Flying you up until " + apoapsisHeight.
  WAIT UNTIL SHIP:ALTITUDE > turnHeight.
  // OK - now comes the fun part. We start turning our zAxis to our desired
  // heading ( -90 - eastwards in this example ) and then start pitching down
  // the nose by 0.1 degree every 50 meters. This should end us pointing at
  // the horizon ( yValue -90.0 ) after 45km of ascent - so at 48km in this
  // example.
  UNTIL yValue < -90.0 {
      IF SHIP:ALTITUDE > turnHeight {
      lock steering to up + R(xValue, yValue, zValue).
      set turnHeight to turnHeight + 50.
      set yValue to yValue - 0.1.
    }
    // Ever heard of terminal velocity - punk? Stop going to fast and wasting
    // a lot of fuel. In this example we start limiting our throttle by 1%
    // as soon as dynamic pressure goes over 0.05. If we drop below we throttle
    // up again. Yeah - it's that easy
    IF SHIP:DYNAMICPRESSURE > 0.05 {
      IF tValue > 0 { set tValue to tValue - 0.01. }
      WAIT 0.2.
    } ELSE {
      IF tValue < 100 { set tValue to tValue + 0.01. }
      WAIT 0.2.
      }
    // Phew - seem like we are on track to the stars. Let us make sure we do
    // not overshoot and throttle to 0% as soon as we reach our desired
    // altitude for APOAPSIS
    IF ALT:APOAPSIS > apoapsisHeight {
        set tValue to 0.
        RCS on.
        PRINT "Ending ascent control at " + ALT:radar.
        // Coasting to edge of the athmosphere. Now we correct the height we
        // lost due to athmospheric drag. 10% throttle should be enough.
        WAIT UNTIL SHIP:ALTITUDE > 70000.
        IF ALT:APOAPSIS < apoapsisHeight {
          set tValue to 0.1.
        }
        WAIT:UNTIL ALT:APOAPSIS > apoapsisHeight {
          set tValue to 0.
        }
        // We should be done and gliding to our APOAPSIS. Let us handover to
        // the next function.
        PRINT "Handing over to Orbit subroutine".
        ORBIT_ME(apoapsisHeight).
      }
  }
}

DECLARE FUNCTION ORBIT_ME {
  DECLARE PARAMETER targetHeight.
  // Quick and dirty - wait until we are close to APOAPSIS. Then fire engine.
  // If PERIAPSIS goes over targetHeight we are done. Not perfect - but orbit.
  WAIT UNTIL SHIP:ALTITUDE > ( ALT:APOAPSIS - 100 ).
  set tValue to 1.
  WAIT UNTIL ALT:PERIAPSIS > targetHeight.
  set tValue to 0.
  PRINT "Orbit reached. Exiting".
}
