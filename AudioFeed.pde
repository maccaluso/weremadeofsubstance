class AudioFeed {
  
  AudioIn inputSpectrum;
  AudioIn inputVolume;
  FFT fft;
  Amplitude amp;
  
  int bands = 512;
  float[] spectrum = new float[bands];

  AudioFeed(PApplet t) {
    fft = new FFT(t, bands);
    amp = new Amplitude(t);
    
    inputSpectrum = new AudioIn(t, 0);
    inputSpectrum.start();
    inputVolume = new AudioIn(t, 0);
    inputVolume.start();
    
    fft.input(inputSpectrum);
    amp.input(inputVolume);
  }
  
  float[] getSpectrum(){
    fft.analyze(spectrum);
    return spectrum;
    //for(int i = 0; i < bands; i++){
    // // The result of the FFT is normalized
    // // draw the line for frequency band i scaling it up by 5 to get more amplitude.
    // // line( i, height, i, height - spectrum[i]*height*5 );
      
    // return spectrum[i];
    //}
  }
  
  float getVolume() {
    return amp.analyze();
  }
  
}