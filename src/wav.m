
baud = 4160; %words/second 
W = 2080; %width of each line of APT image

fc = 2400; %AM subcarrier frequency

fs_i = 11025; %intermediate frequency used for processing

% test
[In, fs] = audioread('../data/argentina.wav');

signal = pre(In, fs, W, fc, fs_i);

dem1 = demod_coherent(signal, W, fc, fs_i);
img1 = shape(dem1, W, baud, fs_i);
image1 = histeq(mat2gray(img1)); %histogram equalization

dem2 = demod_hilbert(signal, W, fc, fs_i);
img2 = shape(dem2, W, baud, fs_i);
image2 = histeq(mat2gray(img2));


imwrite(image1,'../data/argentina1.png');
imwrite(image2,'../data/argentina2.png');
% /test

%preprocessing the recieved audio signal : lowpass filter followed, then resampling to an intermediate frequency of 11025Hz

function sig = pre(In, fs, W, fc, fs_i)
	in = lowpass(In, fc+W, fs); %filtering out higher frequency components, all usefull information is in the frequency range (fc-W,fc+W)

	[p, q] = rat(fs_i/fs); %fs_i/fs = p/q where p and q are integers
	sig = resample(in(:,1), p, q)'; %resample to 11250Hz and transpose
	sig = sig - mean(sig); %dc blocking
end

%demodulation: 1) analytical signal (hilbert transform); 2) coherent detection

function dem = demod_hilbert(sig, W, fc, fs_i)
	env = abs(hilbert(sig)); %absolute value of analytical signal, equivalent to the envelope 
	dem = lowpass(env, W, fs_i); %removing components higher than the bandwidth of the APT signal
end

function dem = demod_coherent(sig, W, fc, fs_i)
	n = length(sig);
	phi = 2*pi*fc/fs_i;
	for i = 2:n
		dem(i) = sqrt(sig(i)^2+sig(i-1)^2-2*sig(i)*sig(i-1)*cos(phi))/sin(phi);
	end
end

function img = shape(dem, W, baud, fs_i)
	mi = min(dem); ma = max(dem); %linear transform, normalizing all values to the range (0,255)
	img_vector = 255*(dem-mi)/(ma-mi);

	[p, q] = rat(baud/ fs_i); %downsampling the signal back to the origina sampling rate of the APT image
	img_vector = resample(img_vector, p, q);
	
	l = floor(length(img_vector)/W); %reshaping the vector into an image by creating a matrix of W columns, each element representing a pixed
	img = reshape(img_vector(1:W*l), [W,l]).';
	img = flip(flip(img,2));
end
