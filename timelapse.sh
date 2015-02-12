#!/bin/bash
# This script makes Timelapse videos of a set of images and uploads them to Youtube (optional)
# It is mandatory that the files use the unix timestamp of creation as filename. That time is
# used fo a time and date annotation on the picture, which will be visible in the video afterwards.
#
# Before usage run an inital video upload with googlecl to set things up
# google youtube post -u ${YT_EMAIL} --title "GoogleCL setup" --category Games anyvideo.mp4


#
# Dependencies:
# - ImageMagick
# - ffmpeg >= 1.x
# - googlecl (when using automatic youtube upload)

###
# General settings (self explaining)
##

DIR="/backup/shots"
TMP_DIR="/home/ingress/vid_tmp"

TIMEZONE="Europe/Berlin"

# leave these two at default unless you know what you're doing. But we have to define
# these here to use the in other variables
YESTERDAY=`date -d 'TZ="${TIMEZONE}" 00:00:01 yesterday'`
TODAY=`date -d 'TZ="${TIMEZONE}" 00:00:01'`

###
# Image annotation settings
###

# the font name to use for the annotation, must be installed
FONT="Coda-Regular"

# the font size for the annotation
FONTSIZE=92

# the font color for the annotation
COLOR="white"

# the position of the annotation (the images have a slight offset due to the cropping,
# therefore you have to add 140px more as intended on the Y axis)
POSITION="+100+4400"

###
# Video settings
###

# if you don't want any audio leave this empty, example is from YouTubes Audio Library
AUDIOPATH="/home/ingress/nemesis.mp3"

# choose wheter you want to upload the video to YouTube
UPLOAD=1

# Your YouTube accounts e-mail address
YT_EMAIL="your-youtube-email@gmail.com"

# the title for the video, as it appears on YouTube
YT_TITLE="24h Ingress Stralsund timelapse for ${YESTERDAY}"

# the category for the YouTube video (mandatory)
YT_CATEGORY="Games"


#####
# SCRIPT
#####

FILE=`date -d "$YESTERDAY" +%s`
FILEEND=`date -d "$TODAY" +%s`

while [ $FILE -lt $FILEEND ]; do
        # it is possible, that the timestamp differs a bit, therefore we need to check if the exact timestamp is correct
        if [ -e ${DIR}/${FILE}.png ]; then
                convert ${DIR}/${FILE}.png -fill white -font Coda-Regular -pointsize 92 -annotate +100+4400 "`date -d @${FILE}`" ${TMP_DIR}/${FILE}.png
        else
                # and if it is not, we will try some more
                TRYFILE=${FILE}
                while [ ! -e ${DIR}/${TRYFILE}.png ]; do
                        let TRYFILE=TRYFILE+1
                        if [ -e ${DIR}/${TRYFILE}.png]; then
                                convert ${DIR}/${TRYFILE}.png -fill white -font Coda-Regular -pointsize 92 -annotate +100+4400 "`date -d @${FILE}`" ${TMP_DIR}/${TRYFILE}.png
                        fi
                done
        fi
	let FILE=FILE+600
done

if [ ${AUDIOPATH} ]; then
	ffmpeg -framerate 1 -pattern_type glob -i "${TMP_DIR}/*.png" -i ${AUDIOPATH} -c:v libx264 -c:a libfaac -vf scale=4096:-1 ${TMP_DIR}/timelapse.mp4
else
	ffmpeg -framerate 1 -pattern_type glob -i "${TMP_DIR}/*.png" -c:v libx264 -vf scale=4096:-1 ${TMP_DIR}/timelapse.mp4
fi

if [ ${UPLOAD} == 1 ]; then
	if [ ! -d ~/.local/share/googlecl ]; then
		mkdir -p ~/.local/share/googlecl/
		echo "Before usage run an inital video upload with googlecl to set things up:"
		echo "   google youtube post -u your-youtube-e-mail-address@gmail.com --title \"GoogleCL setup\" --category Games anyvideo.mp4"
		echo "Afterwards you can delete that video"
		exit 1
	fi

	google youtube post -u ${YT_EMAIL} --title "${YT_TITLE}" --category ${YT_CATEGORY} ${TMP_DIR}/timelapse.mp4
fi

rm -R ${TMP_DIR}/*
