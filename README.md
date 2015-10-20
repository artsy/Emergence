# Emergence

Finding Shows on your TV, it's getting there!

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

Grab the Artsy  OSS keys from [eigen](https://github.com/artsy/eigen/blob/259be8ce00b07a33e02d4444ee01e5589df9b2f1/Makefile#L40-L42) - for Segment, just put some random letters in.

### Compiling

I think I added a `|| os(tvOS)` to Alamofire's `MultipartFormData.swift`.
