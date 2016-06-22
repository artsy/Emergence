WORKSPACE = Emergence.xcworkspace
SCHEME = Emergence
APP_PLIST = Artsy/App_Resources/Artsy-Info.plist
PLIST_BUDDY = /usr/libexec/PlistBuddy
TARGETED_DEVICE_FAMILY = \"1,2\"
DEVICE_HOST = platform='iOS Simulator',OS='8.4',name='iPhone 6'

GIT_COMMIT_REV = $(shell git log -n1 --format='%h')
GIT_COMMIT_SHA = $(shell git log -n1 --format='%H')
GIT_REMOTE_ORIGIN_URL = $(shell git config --get remote.origin.url)

DATE_MONTH = $(shell date "+%e %h" | tr "[:lower:]" "[:upper:]")
DATE_VERSION = $(shell date "+%Y.%m.%d")

LOCAL_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
BRANCH = $(shell echo $(shell whoami)-$(shell git rev-parse --abbrev-ref HEAD))

update_featured_cities:
	curl https://s3.amazonaws.com/artsy-geodata/partner-cities/featured-cities.json > Emergence/Contexts/Presenting\ Locations/cities.js

synxify:
	bundle exec synx "$(SCHEME).xcodeproj" --exclusion "FrontPage/Essentials from Pods"

pr:
	if [ "$(LOCAL_BRANCH)" == "master" ]; then echo "In master, not PRing"; else git push upstream "$(LOCAL_BRANCH):$(BRANCH)"; open "https://github.com/artsy/emergence/pull/new/artsy:master...$(BRANCH)"; fi

push:
	if [ "$(LOCAL_BRANCH)" == "master" ]; then echo "In master, not pushing"; else git push upstream $(LOCAL_BRANCH):$(BRANCH); fi

fpush:
	if [ "$(LOCAL_BRANCH)" == "master" ]; then echo "In master, not pushing"; else git push upstream $(LOCAL_BRANCH):$(BRANCH) --force; fi
