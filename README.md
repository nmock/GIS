Google Image Search
===========

This is a simple utility to search for images using the [`Google Images API`](https://developers.google.com/image-search/v1/jsondevguide).

Demonstrates Pinterest-esque layout, hiding navigation bar on scroll, recent searches, and auto-complete.

If you have any questions, email me at nathan@nathanmock.com or create a new issue with specifics.

## Demo
![Google Image Search Demo](http://i.imgur.com/D3QL0pd.gif)

## Restrictions
You are restricted to 64 results without an API key and 1000 results with an API key. 

### Auto Complete Delay
Google seems to be rate limiting the endpoint, so we are delaying auto-complete requests by 0.4 seconds by default to help cull excessive requests

## Libraries
*  AFNetworking
*  AMScrollingNavbar
*  CHTCollectionViewWaterfallLayout
*  PureLayout

## License
Artisan for iOS is released under a slightly modified [Simplified BSD License](https://github.com/nmock/artisan-ios/blob/master/LICENSE).

Please don't upload this code directly to the App Store as is without making subsantial improvements. In other words, please don't be a jerk.


## Contributing
If you want to fix bugs or implement new features, have at it! All that I ask is that you make proper attributions. 


## Known Bugs / Possible improvements
*  allow user to view full image, image details, etc.
*  allow user to change search options (grayscale images, faces, clip art, safe search, etc.)
*  better error handling
*  create plist to handle all constants / tweakable values for easy tweaking for stakeholders
*  show loading inline by way of custom uicollectionviewcell footer / headers
*  better error/state handling (reachability, network errors, API errors, end of results, no results, etc.)
