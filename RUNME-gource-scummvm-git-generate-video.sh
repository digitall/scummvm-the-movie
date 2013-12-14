#!/bin/sh

# ScummVM The Movie - Script to Generate
#
# WARNING: The resulting scummvm.mp4 will
# be around 200GB+ and around 4 hours long...
# Make popcorn while you wait! :)
#
# Required Dependencies:
# * Unix bash shell and core utils
# * Perl located in /usr/bin/perl
# * Git
# * wget
# * gource-0.40 or greater: http://code.google.com/p/gource/
# * FFMPEG with x264 library support

# Frame Rate
#FRAMERATE=60
FRAMERATE=30

#Screen Size
# 1080
SCREENSIZE=1920x1080
# 720p
#SCREENSIZE=1280x720
# 800x600
#SCREENSIZE=800x600
# 640x480
#SCREENSIZE=640x480

# Simulation Speed
#SECSPERDAY=10
#SECSPERDAY=1
SECSPERDAY=0.1

# Get ScummVM Git Repository
if [ ! -d ./scummvm ]; then
	git clone https://github.com/scummvm/scummvm.git
else
	cd scummvm
	git pull --ff-only
	cd ..
fi

# Generate Caption Log from Git Repo release tags
cd scummvm
git tag -l | grep "^v" | while read tag; do git log -1 --pretty=format:"%at|$tag%n" $tag ;done | sort -n > caption.log

# Get Gravatar Logos for users
if [ ! -d .git/avatar ]; then
	../gource-git-gravatar-fetch.pl
	#../gource-git-gravatar-fetch-newer-parallel.pl
fi

# Get ScummVM Logo
cd .git/avatar
if [ ! -f ./scummvm_logo.jpg ]; then
	wget http://www.scummvm.org/images/scummvm_logo.jpg
fi
cd ../..

echo "Screen Size: ${SCREENSIZE}"
echo "Sim Speed: ${SECSPERDAY}"
echo "Framerate: ${FRAMERATE}"

# Generate Video with Gource
gource -${SCREENSIZE} --seconds-per-day ${SECSPERDAY} --user-image-dir .git/avatar/  --caption-file caption.log --highlight-dirs --key --file-idle-time 0 --max-files 0 --stop-at-end --hide bloom,mouse,progress -r ${FRAMERATE} -o - | ffmpeg -y -r ${FRAMERATE} -f image2pipe -vcodec ppm -i - -vcodec libx264 -preset ultrafast -pix_fmt yuv420p -crf 1 -threads 0 -bf 0 ../scummvm.mp4
# --logo .git/avatar/scummvm_logo.jpg

# Clean up
rm -f caption.log
cd ..
