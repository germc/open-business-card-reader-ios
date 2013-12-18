Open Business Card Reader for iOS
================

Interested in adding Card Reading functionality into a new or existing iOS application? Look no further.

Open Business Card Reader for iOS is an open source example implementation of FullContact Card Reader.  It's built on top of our [fullcontact-objc](https://github.com/fullcontact/fullcontact-objc) library and shows how to caputure business card images, send them to the FullContact [Card Reader API](http://www.fullcontact.com/developer/card-reader-api/), and receive transcribed Contact information back to your device.

## Getting Started
Once you clone the Open Business Card Reader Source locally, you'll need to get a FullContact API key to get up and running.
###Obtain a FullContact API Key
A FullContact API key can be obtained on our [Developer Portal](https://www.fullcontact.com/developer/pricing).
###Insert your FullContact API Key
After obtaining a FullContact API Key, search for `FCCardReaderHelper.m` inside the `Code\Helpers` folder.  Add your key to the following line:

```
NSString *const kAPIKey = nil;  //TODO:  Enter your API key here
```
For example:

```
NSString *const kAPIKey = @"MYAPIKEY";  
```
## Using the Application
Depending on your application architecture and requirements there are different methods for integrating Open Business Card Reader into your application.

Check out the [Wiki](https://github.com/fullcontact/open-business-card-reader-ios/wiki) for more information.

## Requirements

Open Business Card Reader requires [iOS 7.0](https://developer.apple.com/library/ios/releasenotes/General/WhatsNewIniOS/Articles/iOS7.html#//apple_ref/doc/uid/TP40013162-SW1) or above.

### ARC

This project uses ARC.

If you are using Open Business Card Reader in your non-arc project, you will need to set a `-fobjc-arc` compiler flag on all of the source files. 

To set a compiler flag in Xcode, go to your active target and select the "Build Phases" tab. Now select all Open Buisness Card Reader source files, press Enter, insert `-fobjc-arc` and then "Done" to enable ARC.

##Need Help - No Problem!
We're always available to help in any way we can.  Check out our [Support Page](http://support.fullcontact.com) to access our Knowledge Base or contact our Support group.

##Got an Idea?
We love ideas!  Submit your ideas, suggestions, or feedback on our [API Developer Forum](http://support.fullcontact.com/forums/187136-api-developer-forum) or fork our repo.  We review pull requests regularly and look forward to seeing what you come up with!

## License

Open Business Card Reader for iOS is available under the Apache License Version 2.0 license. See the [LICENSE](LICENSE) file for more info.
