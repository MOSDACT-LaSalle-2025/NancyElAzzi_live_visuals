/**
 * SpectrumScene
 * Handles all spectrum analysis and drawing.
 */

void drawSpectrumScene() {
  noStroke();
// Run FFT analysis for both channels

  fftLeft.forward(song.left); 
  fftRight.forward(song.right);

  pushStyle();
  colorMode(HSB, 360, 100, 100, 100);
// L R Chanels
  if (showLeft)  drawSpectrum(fftLeft, -height/2, true);
  if (showRight) drawSpectrum(fftRight, 0, false);

  popStyle();
}

// -------- Spectrum drawing --------
void drawSpectrum(FFT fft, float yOffset, boolean flip) {
  float bandW = float(width) / bands;
  float perspectiveDepth = 1000.0; // Fixed depth for perspective calculation (Tweak this value!)

  for (int i = 0; i < bands; i++) {
    
    pushMatrix(); // Start matrix for Z-translation
    float zOffset = random(-zRandomRange, zRandomRange); 
    // ----------------------------------------------------------------
    //  scale factor based on Z position relative to camera
    // Smaller scaleFactor means the object is further away.

    translate(0, 0, zOffset);
    float scaleFactor = 1.0;
    if (perspectiveDepth - zOffset != 0) {
        scaleFactor = perspectiveDepth / (perspectiveDepth - zOffset);
    }
    
    float scaledRectH = height/2 * scaleFactor;
    
    // Calculate the amplitude (remains the same)
    int idx = int(constrain(
      map(i, 0, bands-1, fft.freqToIndex(minFreq), fft.freqToIndex(maxFreq)),
      0, fft.specSize()-1
    ));
    float amp = fft.getBand(idx) * 15;
    float alphaVal = constrain(amp, 0, 100);
    
    // Color settings
    float hue = map(i, 0, bands-1, 200, 360); 
    fill(hue, sat, fixedBri, alphaVal); 

    // Draw parameters
    float yBase = height/2 + yOffset;
    float xPos = flip ?
      width - (i+1) * bandW : i * bandW;
    
    // We must translate the bar to its correct X position BEFORE scaling, 
    // and then draw the rectangle at (0, 0) relative to that position.

    // 1. Move the canvas origin to the center of where the bar should be drawn
    translate(xPos + bandW/2, yBase + height/4, 0); 
    
    // 2. Apply the perspective scale
    scale(scaleFactor);
    
    // 3. Draw the original shape (now scaled) centered at the new origin
    rectMode(CENTER);
    rect(0, 0, bandW, scaledRectH);
        
    popMatrix(); // End matrix for Z-translation, scale, and X/Y translation
  }
}
