# Decoder for APT (Automatic Picture Transmission)

![NOAA 19](/data/noaa.jpg)

NOAA-N (currently only NOAA 19 active) satellites transmit images in the APT format:

> ...a 256-level amplitude modulated 2400Hz subcarrier, which is then frequency modulated onto the 137 MHz-band RF carrier. Maximum subcarrier modulation is 87% (±5%), and overall RF bandwidth is 34 kHz. On NOAA POES vehicles, the signal is broadcast at approximately 37dBm (5 watts) effective radiated power.

This signal can be freely downlinked by an antenna, and then (frequency) demodulated into a .wav file. The scope of this project is to start at the .wav file and further (amplitude) demodulate the signal to generate the transmitted image.

![NOAA orbit](/data/orbit.png)

## Resampling
After some pre-processing to remove higher frequency components and to resample the audio into an intermediate format (11025 Hz), we get an angle modulated signal at carrier frequency 2400Hz. The signal (from time 200s to 200.5s) and its discrete fourier transform are presented below:

![time domain AM signal](/data/signal.png)
![dft of signal](/data/fft_signal.png)

## Demodulation
Two methods, which produce almost identical results, are used:

1. Complex Envelope/Analytical Function (which utilizes the hilbert() function)
2. Coherent Demodulation (here an approximated version which only utilizes two input values: the current and the previous ones)

The demodulated signal (in the time range aforementioned) and its discrete fourier transform (clipped at low frequency values to maintain readability):

![time domain demodulated signal](/data/demodulated.png)
![dft of demodulated signal](/data/fft_demodulated.png)


The demodulated signal as an envelope:

![both the original and demodulated signals in time domain](/data/envelope.png)

## Reshaping
We have obtained the original signal transmitted, but this is still a vector, we need to slice it at appropriate intervals to obtain the pixel values for each row, then construct a matrix out of these values, this matrix is our image. The APT image format is as follows:

![APT format](/data/APT_format.png)

Thus we first downsample the signal to 4160Hz, every element of the resulting signal represents a pixel. We also scale each element to a value between 0 and 255. Since the length of each line is 0.5s = 2080 pixels, we slice the signal vector every 2080 elements, reshaping it into a matrix. Further we transpose and flip this matrix for appropriate orientation. This matrix now represents the final image transmitted:

|Coherent Demodulation|Analytical Function|
|---|---|
|![image from coherent demodulation](/data/argentina1.png)|![image from complex envelope](/data/argentina2.png)|

APT is a grayscale format, however false-colour can be added. The image has a certain slant, this is due to the doppler effect - the movement of the satellite while it's taking the image, this can also be fixed on a software level, using the sync lines.

## TODO:
1. Remove the doppler shift
2. Apply false colouring
3. Design Web-GUI and a github-site
4. Set up an antenna to receive the signal directly, then demodulate and obtain the wav file


