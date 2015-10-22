<img src="https://raw.githubusercontent.com/artsy/emergence/master/docs/screenshots/artsy_logo.png" align="left" hspace="30px" vspace="30px">
<img src="https://raw.githubusercontent.com/artsy/emergence/master/docs/screenshots/emergence.png" align="right" hspace="30px" vspace="30px">


<img src ="https://raw.githubusercontent.com/artsy/emergence/master/docs/screenshots/featured.png">
<img src ="https://raw.githubusercontent.com/artsy/emergence/master/docs/screenshots/show.png"><img src ="https://raw.githubusercontent.com/artsy/emergence/master/docs/screenshots/artworks.png">

# Emergence

Finding Shows on your TV.

### Installation

Run this in your shell:

```sh
git clone https://github.com/artsy/emergence.git
cd Emergence
bundle install
bundle exec pod install
open "Emergence.xcworkspace"
```

### Keys

* For OSS:  Grab the Artsy  OSS keys from [eigen](https://github.com/artsy/eigen/blob/259be8ce00b07a33e02d4444ee01e5589df9b2f1/Makefile#L40-L42) - for Segment, just put some random gibberish in.

* For Artsy: Check engineering 1Password.

### Compiling

I think I added a `|| os(tvOS)` to Alamofire's `MultipartFormData.swift`.
