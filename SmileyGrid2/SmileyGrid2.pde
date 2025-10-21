/**
 * Mixture Grid  
 * modified from an example by Simon Greenwold. 
 * 
 */

import com.hamoid.*; 
import themidibus.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

VideoExport video;
boolean recording = false;

MidiController midi;

//=========== 3D GRID & BOX SETTINGS (Controlled by MIDI Knobs) =======
float boxSize = 0;                 // Base cube size (K1 / CC 70: 0-335)
boolean rotToggle = false;
float targetRot = 0;
float targetRotY = -1;             // Target Y-rotation for smoothing
float targetRotX = 1;              // Target X-rotation for smoothing
float targetGridZ = -500;          // Target Z-position for smooth depth control (CC 71)
float gridZ = 0;                   // Current Z-axis position 

int imgSwitchRate = 1;             // Placeholder, superseded by switchInterval

float boxYrot = 0;                 // Current Y-rotation
float boxXrot = 0;                 // Current X-rotation
float gridSize = 550;              // Grid zoom/density base (K5 / CC 74: 3000-5)

// ===== LIGHTING SETTING (Adjust these values in defineLights()) ===
boolean strobe = false;            // Screen invert effect (CC 19)

//=========== SMILEY TEXTURE SETTINGS ========
PImage tex;
PImage[] smileys;
int numSmileys = 30;               // Total number of images loaded
int currentSmiley = 0;
boolean cycleSmileys = true;       // Texture cycling toggle (CC 22)

// ====== Image switching timing (Millis) ======
int lastSwitchTime = 0;
int switchInterval = 300;          // Texture swap interval in ms (CC 76: 700-20ms)

//=========== SPECTRUM & AUDIO SETTINGS ========
Minim minim;
AudioPlayer song;                  // Audio source for reactivity (loaded MP3/WAV)
FFT fftLeft, fftRight;             // FFT objects for stereo analysis

float minFreq = 10;
float maxFreq = 4000;              // Upper frequency limit for spectrum
int bands = 100;                   // Number of spectrum bars (K8 / CC 77)
float fixedBri = 100;              // Fixed brightness
float sat = 80;                    // Saturation (K3 / CC 72: 0-100)
float zRandomRange = 0;            // Max Z-axis random range for spectrum (CC 73: 0-2000)

boolean showLeft = true;
boolean showRight = true;
// ===== KICK DETECTION (Controls box size reactivity) =====
int kickRange = 3;                 // Number of low-frequency bins averaged (fixed to 3)
float kickScale = 1.30;            // Multiplier for kick energy impact (tweakable)
float smoothedKickEnergy = 0;      // Smoothed value for soft box scaling

void setup() {
  // Set full screen on external display 3 (P3D required for 3D and lights).
  fullScreen(P3D, 3);
  
  // Set the target frame rate for consistent video export sync.
  frameRate(30);

  noStroke();
  
  // Load smiley textures (must be in data folder, e.g., "Smiley 01.jpg").
  smileys = new PImage[numSmileys];
  for (int i = 0; i < numSmileys; i++) {
    String fileName = "Smiley " + nf(i+1, 2) + ".jpg";
    smileys[i] = loadImage(fileName);
    if (smileys[i] == null) println("⚠️ Missing file: " + fileName);
  }

  tex = smileys[currentSmiley];
  
  // Initialize MIDI control.
  MidiBus.list();
  midi = new MidiController(this);

  // Audio setup: Load song file and initialize FFT.
  minim = new Minim(this);
  song = minim.loadFile("Charlotte Adigery & Bolis Pupul - HAHA (Official Video).mp3");
  song.loop(); // Start playback and loop
  
  // FFT setup uses the song's audio properties.
  fftLeft  = new FFT(song.bufferSize(), song.sampleRate());
  fftRight = new FFT(song.bufferSize(), song.sampleRate());
}

void draw() {
  background(0);
  defineLights();

  // Smooth grid Z-position toward its MIDI-controlled target.
  gridZ = lerp(gridZ, targetGridZ, 0.15); 

  // Smooth rotations toward their targets.
  boxYrot = lerp(boxYrot, targetRotY, 0.1);
  boxXrot = lerp(boxXrot, targetRotX, 0.1);
  
  // Run FFT analysis on the song's audio buffers.
  fftLeft.forward(song.left);
  fftRight.forward(song.right);
  
  // --- Kick detection (average low frequencies) ---
  float kickEnergy = 0;
  int kickMaxIndex = fftLeft.freqToIndex(40); // Max index for 40 Hz
  int safeRange = constrain(kickRange, 1, min(kickMaxIndex, fftRight.specSize()));
  
  for (int i = 0; i < safeRange; i++) {
    kickEnergy += fftLeft.getBand(i) + fftRight.getBand(i);
  }
  kickEnergy /= (safeRange * 1.0); // Averaging
  
  // Apply smoothing to kick energy for softer visual reaction.
  smoothedKickEnergy = lerp(smoothedKickEnergy, kickEnergy, 0.05);

  // Calculate final reactive box size.
  float reactiveSize = boxSize + smoothedKickEnergy * kickScale;
  reactiveSize = max(1, reactiveSize); 

  // Draw the 3D grid and the spectrum visualization.
  drawSmileyGrid(reactiveSize);
  drawSpectrumScene(); // Function defined in SpectrumScene.pde

  // Video recording frame saver.
  if (recording && video != null) {
    try {
      video.saveFrame();
    } catch (Exception ex) {
      println("video save err: " + ex.getMessage());
      stopRecording();
    }
  }
}

// -------- Smiley Matrix Drawing --------
void drawSmileyGrid(float reactiveSize) {
  // Map gridSize (CC 74) to proportional spacing between boxes.
  float proportionalGrid = map(gridSize, 5, 500, width/40.0, width/2.0);
  
  // Calculate columns/rows (ensuring a minimum of 1).
  int cols = max(1, ceil(width / proportionalGrid));
  int rows = max(1, ceil(height / proportionalGrid));
  float gridW = cols * proportionalGrid;
  float gridH = rows * proportionalGrid;
  float offsetX = (width - gridW) / 2.0;
  float offsetY = (height - gridH) / 2.0;

  pushMatrix();
  translate(0, 0, gridZ); // Apply depth position

  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      float px = offsetX + x * proportionalGrid + proportionalGrid/2.0;
      float py = offsetY + y * proportionalGrid + proportionalGrid/2.0;

      pushMatrix();
      translate(px, py);
      rotateX(boxYrot);
      rotateY(boxXrot);
      
      // Image switching logic.
      if (cycleSmileys && (millis() - lastSwitchTime) > switchInterval) {
        currentSmiley = (currentSmiley + 1) % smileys.length;
        tex = smileys[currentSmiley];
        lastSwitchTime = millis();
      }

      // Draw the textured cube (function in TexturedBox.pde).
      texturedBox(tex, reactiveSize);
      popMatrix();
    }
  }

  popMatrix(); // End grid depth transformation
  
  // Strobe effect: screen invert every 5 frames when active.
  if (strobe && frameCount % 5 < 2) {
    filter(INVERT);
  }
}

//-------------- Light Definition (Adjust colors/positions here) -----------------
void defineLights() {
  // Orange point light (r,g,b, x,y,x)
  pointLight(150, 100, 0, 200, -150, 0); 
  // Blue directional light (r,g,b, x,y,x)
  directionalLight(0, 102, 255, 1, 0, -1);
  // Yellow spotlight (Color: 255, 255, 109)
  spotLight(255, 255, 109, 0, 40, 200, 0, -0.5, -0.5, PI / 2, 2);
}

void keyPressed() {
  // 'v' key toggles video recording (function in Video_Helper.pde).
  if (key == 'v' || key == 'V') {
    toggleVideo();
  }
  
  // 'r' key resets the song playback.
  if (key == 'r' || key == 'R') {
    if (song != null) {
      song.pause();
      song.rewind(); // Rewinds audio
      song.loop();   // Resumes looped playback
      println("Music reset and resumed.");
    }
  }
}
