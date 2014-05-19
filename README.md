Welcome to the Alfresco iOS SDK
===============================

The Alfresco iOS SDK includes a set of APIs and samples that allows developers to quickly build Alfresco-enabled applications. 

This SDK provides functionality to connect to both on-premise and Cloud-based servers. Alfresco servers of version 3.4.8 and above are supported. To access Alfresco in the cloud, you will need to [register for a free developer account](https://www.alfresco.com/develop).


Documentation
-------------

Full documentation, including getting started instructions can be found on our [documentation site](http://docs.alfresco.com/mobile_sdk/ios/concepts/mobile-sdk-ios-intro.html)

More information about Alfresco's various Mobile offerings is on [our website](http://www.alfresco.com/products/mobile).


A Note About Dependent Frameworks
---------------------------------
Alfresco iOS SDK v1.3 contains code that checks for network connectivity. This introduces a dependency on the `SystemConfiguration.framework` which your own project will need to link to.

The [LLVM compiler in Xcode 5](https://developer.apple.com/library/ios/documentation/DeveloperTools/Conceptual/WhatsNewXcode/Articles/xcode_5_0.html#//apple_ref/doc/uid/TP40012953-SW27) introduces an Auto Linking feature which makes linking system frameworks much simpler: simply search for and change the **Enable Modules (C and Objective-C)** setting in your project's configuration to **YES**. This setting is on by default for projects created with Xcode 5, so you may find it is already set.


Releases
--------

The master branch is used for development of new features so its stability cannot be guaranteed. The current stable release can be obtained 
from our [developer portal](https://developer.alfresco.com/mobile). All previous releases including the latest can also be downloaded from
[GitHub](https://github.com/Alfresco/alfresco-ios-sdk/releases)

Alternatively, use [one of the tags](https://github.com/Alfresco/alfresco-ios-sdk/tags) to build from source.


Known Issues
------------

Please refer to the [MOBSDK project with JIRA](https://issues.alfresco.com/jira/browse/MOBSDK) for all open issues relating to the SDK. This is also where bugs and improvement tickets should be raised.


License
-------

The Alfresco iOS SDK is distributed under the [Apache 2 License](http://www.apache.org/licenses/LICENSE-2.0.html).


Acknowledgements
----------------

The Alfresco iOS SDK uses the [ISO8601DateFormatter](https://bitbucket.org/boredzo/iso-8601-parser-unparser) by Peter Hosey.