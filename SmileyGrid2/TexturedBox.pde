/**
 * draws the cubes
 */

void texturedBox(PImage tex, float s) {
  beginShape(QUADS);
  texture(tex);

  // Front
  vertex(-s/2, -s/2,  s/2, 0, 0);
  vertex( s/2, -s/2,  s/2, tex.width, 0);
  vertex( s/2,  s/2,  s/2, tex.width, tex.height);
  vertex(-s/2,  s/2,  s/2, 0, tex.height);

  // Back
  vertex( s/2, -s/2, -s/2, 0, 0);
  vertex(-s/2, -s/2, -s/2, tex.width, 0);
  vertex(-s/2,  s/2, -s/2, tex.width, tex.height);
  vertex( s/2,  s/2, -s/2, 0, tex.height);

  // Left
  vertex(-s/2, -s/2, -s/2, 0, 0);
  vertex(-s/2, -s/2,  s/2, tex.width, 0);
  vertex(-s/2,  s/2,  s/2, tex.width, tex.height);
  vertex(-s/2,  s/2, -s/2, 0, tex.height);

  // Right
  vertex( s/2, -s/2,  s/2, 0, 0);
  vertex( s/2, -s/2, -s/2, tex.width, 0);
  vertex( s/2,  s/2, -s/2, tex.width, tex.height);
  vertex( s/2,  s/2,  s/2, 0, tex.height);

  // Top
  vertex(-s/2, -s/2, -s/2, 0, 0);
  vertex( s/2, -s/2, -s/2, tex.width, 0);
  vertex( s/2, -s/2,  s/2, tex.width, tex.height);
  vertex(-s/2, -s/2,  s/2, 0, tex.height);

  // Bottom
  vertex(-s/2,  s/2,  s/2, 0, 0);
  vertex( s/2,  s/2,  s/2, tex.width, 0);
  vertex( s/2,  s/2, -s/2, tex.width, tex.height);
  vertex(-s/2,  s/2, -s/2, 0, tex.height);

  endShape();
}
