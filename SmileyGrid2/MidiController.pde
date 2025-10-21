// ================================
// MidiController.pde
// Handles MIDI mappings and the controllerChange callback
// ================================
class MidiController {
  MidiBus myBus;
  MidiController(PApplet parent) {
    MidiBus.list();
myBus = new MidiBus(parent,"MPK mini 3", -1);
    // (parent sketch, input device index, output device index)
    // Change the "1" to match your MIDI input device in the console
  }
}

// ------------------ MIDI ------------------
void controllerChange(int channel, int number, int value) {
  println("MIDI: " + channel + " No:" + number + " value: " + value);
  
// ===== Box & grid controls ======= //
  if (number == 70) boxSize = map(value, 0, 127, 0, 335);  // K1 - base box size
  if (number == 74) gridSize = map(value, 0, 127, 3000, 5); // K5 - grid zoom (smaller -> denser)

  // NEW: Grid Z-axis control for depth (CC 78)
  if (number == 71) targetGridZ = map(value, 0, 127, -3500, 200); // Back/forth depth control

  // Image switch speed: CC 76 maps to ms between switches (fast -> slow)
  if (number == 76) {
    switchInterval = int(map(value, 0, 127, 700, 20)); 
  }

  // Rotation and toggles
  if (number == 1) boxYrot = map(value, 0, 127, -PI/4, PI/4); // Joystick Y-axis (CC 1) controls Y-rotation
if (number == 16 && value > 0) { rotToggle = !rotToggle; 
    if (rotToggle) { targetRotY = random(-1.5, 1.5);
targetRotX = random(-1.5, 1.5); }
    else { targetRotY = 0; targetRotX = 0;
}
  }
  if (number == 19) strobe = value > 0;
if (number == 20 && value > 0) targetRotY = random(-1.3, 1.3);
if (number == 21 && value > 0) targetRotX = random(-2, 2);
if (number == 22 && value > 0) cycleSmileys = !cycleSmileys;
// NEW: Pad 8 (CC 23) as a manual box pulse trigger
if (number == 23 && value > 0) { 
    // This provides a visual 'pulse' effect
    kickScale = 20.0; // Temporarily increase sensitivity
    smoothedKickEnergy = 2.0; // Force a strong kick
}
if (number == 23 && value == 0) {
    kickScale = 1.30; // Return to base sensitivity
}

// ====== Spectrum controls ===== //
  // K3 (CC 72) controls Saturation
  if (number == 72) sat = map(value, 0, 127, 0, 100); 
if (number == 77) bands = int(map(value, 0, 127, 3, 90)); // K8 - spectrum resolution
// CC 73: Spectrum Z-Randomization Range (variable is zRandomRange)
if (number == 73) zRandomRange = map(value, 0, 127, 0, 2000); // 0 (aligned) to 2000 (deeply randomized)
// Spectrum toggle pads
  if (number == 18 && value > 0) showLeft = !showLeft;
  if (number == 17 && value > 0) showRight = !showRight;
}
