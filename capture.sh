#!/bin/bash
# This script will make automatic screenshots of the Ingress Intel, without the need
# for a browser. Especially useful for high resolution captures and timelapses.
# The captured images will be stored as a PNG file with the UNIX timastamp of the capture
# as filename. Which is useful for further processing and annotating the images.
#
# Dependencies:
# - Xvfb
# - CutyCapt
# - ImageMagick


# where to store the images
OUTDIR="/backup/screenshots"

# your login cookie, get this from your web browsers developer consoles header view
LOGIN=""

# the location you want to get (exmple is Stralsund, Germany; https://www.ingress.com/intel?ll=54.307168,13.069839&z=15)
LAT="54.307168"
LNG="13.069839"

# the zoom level
ZOOM="15"

# the resolution (example is 8K)
WIDTH=7680
HEIGHT=4320

# the delay between loading the page and taking the screenshot, depends on zoom level and resolution
DELAY=60000

#####
# SCRIPT
#####

DATE=`date +%s`
# we want to cut the borders, the ingame name, comm and settings; therfore we set some extra margins for the screenshot and cut them afterwards
REAL_WIDTH=`expr ${WIDTH} + 40`
REAL_HEIGHT=`expr ${HEIGHT} + 310`

# using xfvb as a minimal xserver here, If you have another X-implementation running on your system you can also execute it in there
xvfb-run --server-args="-screen 0, ${REAL_WIDTH}x${REAL_HEIGHT}x24" \
	cutycapt --min-width=${REAL_WIDTH} \
		--min-height=${REAL_HEIGHT} \
		--header="cookie: SACSID=${LOGIN}; ingress.intelmap.lat=${LAT}; ingress.intelmap.lng=${LNG}; ingress.intelmap.zoom=${ZOOM}" \
		--delay=${DELAY} \
		--javascript=on \
		--url="https://www.ingress.com/intel?ll=${LAT},${LNG}&z=${ZOOM}" \
		--out="${OUTDIR}/${DATE}.png"

# cropping the mentioned extra data (borders, ingame name, comm and settings)
CROP_POS_X=20
CROP_POS_Y=140
convert ${OUTDIR}/${DATE}.png -crop ${WIDTH}x${HEIGHT}+${CROP_POS_X}+${CROP_POS_Y} ${OUTDIR}/${DATE}.png

# give us some info what you did (so that we can redirect the output into a logfile if we are running from cron)
echo "${READABLE_DATE} captured ${OUTDIR=}/${DATE}.png"
