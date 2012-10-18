Welcome to the Alfresco iOS SDK
===============================

The Alfresco iOS SDK includes a set of APIs and samples that allows developers to quickly build Alfresco-enabled applications. 

This SDK provides functionality to connect to both on-premise and Cloud-based servers. Alfresco servers of version 3.4.x and above are supported. 


Documentation
-------------

Full documentation, including getting started instructions can be found in the [iOS SDK Reference PDF](https://developer.alfresco.com/resources/alfresco/pdf/iOSSDKReference-v1.0.pdf). 

More information can be found on our [developer portal](http://developer.alfresco.com/mobile) and on our [website](http://www.alfresco.com/products/mobile).


Releases
--------

The master branch is used for development of new features so it's stability can not be guaranteed, for the current stable release 
[download the pre-built binaries](https://developer.alfresco.com/resources/alfresco/downloads/alfresco-ios-sdk.zip) from the developer portal. 
Alternatively, use one of the [tags](https://github.com/Alfresco/alfresco-ios-sdk/tags) to build from source.


Known Issues
------------

- The searchWithKeywords:options:completionBlock and searchWithKeywords:options:listingContext:completionBlock methods on the AlfrescoSearchService
  generate a very basic query that only searches the name property. To use more advanced queries use one of the two searchWithStatement methods.

License
-------

The Alfresco iOS SDK is distributed under the [Apache 2 License](http://www.apache.org/licenses/LICENSE-2.0.html).


Acknowledgements
----------------

The Alfresco iOS SDK uses the [ISO8601DateFormatter](https://bitbucket.org/boredzo/iso-8601-parser-unparser) by Peter Hosey.