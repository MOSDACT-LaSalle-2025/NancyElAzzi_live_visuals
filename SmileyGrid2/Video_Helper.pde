// ================================
// VideoHelpers.pde
// Handles video recording functions
// ================================

void startRecording() {
  try {
    java.io.File dir = new java.io.File(sketchPath("exports"));
if (!dir.exists()) dir.mkdirs();
    String timestamp = nf(year(),4) + "-" + nf(month(),2) + "-" + nf(day(),2) + "_" +
                       nf(hour(),2) + "-" + nf(minute(),2) + "-" + nf(second(),2);
String fname = sketchPath("exports/NNC-FinalPerformance-" + timestamp + ".mp4");
    video = new VideoExport(this, fname);
    video.setFrameRate(30);
    video.startMovie();
    recording = true;
println("Video recording started: " + fname);
  } catch (Exception ex) {
    println("VideoExport start error: " + ex.getMessage());
recording = false;
  }
}
void stopRecording() {
  try {
    recording = false;
if (video != null) {
      video.endMovie();
      println("Video saved.");
}
  } catch (Exception ex) {
    println("VideoExport stop error: " + ex.getMessage());
}
}
void toggleVideo() {
  if (!recording) startRecording(); else stopRecording();
}
