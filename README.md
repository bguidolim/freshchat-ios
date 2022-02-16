Freshchat iOS SDK Cocoapods with XCFramework (Beta)
===================================================

"Modern messaging software that your sales and customer engagement teams will love." [Freshchat](http://www.freshchat.com) by [Freshworks](https://www.freshworks.com).

## Installation
Freshchat iOS SDK can be integrated using cocoapods by specifying the following in your podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'Your project target' do
pod 'FreshchatSDK', :git => 'https://github.com/freshdesk/freshchat-ios', :branch => 'cocoapods_xcframework'
end
```

After addition please add  "-all_load" flag in Project Settings, General > Build Settings > Other Linker flags


## Existing minor bug 
1. App version always comes as 1.0 (We are fixng this in upcoming release)
2. Bitcode embed - Fixed



Note : 
- After fixing the issue, this branch will be merged into master. 
- For SPM - Drag and Drop - FCLocalization.bundle, FCResources.bundle and FreshchatModels.bundle from FreshchatSDK folder

## Documentation
[Integration Guide](https://support.freshchat.com/support/solutions/articles/50000000048-freshchat-ios-sdk-integration-steps) 

[API docs](http://cocoadocs.org/docsets/FreshchatSDK)

## License
FreshchatSDK is released under the Commercial license. See [LICENSE](https://github.com/freshdesk/freshchat-ios/blob/master/FreshchatSDK/LICENSE) for details.

## Support
[support@freshchat.com](mailto:support@freshchat.com)

[Support Portal](https://support.freshchat.com)
