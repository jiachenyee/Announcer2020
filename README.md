 <img src="Announcer/Support Files/Assets.xcassets/AppIcon.appiconset/iTunesArtwork@2x.png" width="70"> 
 
# SST Announcer (iOS) 

[![Language](http://img.shields.io/badge/swift-5-orange.svg?style=flat)](https://developer.apple.com/swift)
[![Xcode](http://img.shields.io/badge/xcode-12%20beta-red.svg?style=flat)](https://developer.apple.com/xcode)
[![Cocoapods](http://img.shields.io/badge/pod-v1.8.4-darkgray.svg?style=flat)](https://cocoapods.org/)

[![iOS](http://img.shields.io/badge/platform-iOS%2013-blue.svg?style=flat)](https://developer.apple.com/iphone/index.action)
[![iPadOS](http://img.shields.io/badge/platform-iPadOS%2013-blue.svg?style=flat)](https://developer.apple.com/ipad/)
[![Mac Catalyst](http://img.shields.io/badge/platform-MacOS%2011-blue.svg?style=flat)](https://developer.apple.com/mac-catalyst/)

[![Gitmoji](https://img.shields.io/badge/gitmoji-%20😜%20😍-FFDD67.svg?style=flat)](https://gitmoji.carloscuesta.me/)

[![License](https://img.shields.io/badge/license-Apache%202-blue.svg?style=flat)](https://github.com/sst-inc/SST-Announcer-iOS/blob/master/LICENSE)

SST Announcer was built to help SST Students stay up to date with the school’s announcements with ease and convenience on their devices. The app allows users to browse, pin and share important announcements made by the school. The app also sends notifications to students whenever a new announcement is posted. This helped to ensure that students are kept updated with the latest information from the school. 

> Original design by *FourierIndustries (formerly StatiX Industries)*
>
> Revamped in 2018 by *OrbitIndustries*
>
> Revamped, again, in 2020 by *Jia Chen and Shannen*

---
## Installation
This project uses Cocoapods. Check the Podfile for more information.

0. To install Cocoapods, in terminal, run `sudo gem install cocoapods`
1. To install the pods into the project, go to the project's directory and run `pod install` on this project
2. Open the `Announcer.xcworkspace`
3. Done

or just download on the [App Store](https://apps.apple.com/sg/app/sst-announcer/id683929182)

[![App Store](https://upload.wikimedia.org/wikipedia/commons/3/3c/Download_on_the_App_Store_Badge.svg)](https://apps.apple.com/sg/app/sst-announcer/id683929182)

## Requirements
- Xcode 12 Beta 2
- Swift 5.2
- Cocoapods 1.8.4 or greater

### Device Requirements
#### iPadOS
|Support        |Version |Notes                                                    |
|---------------|--------|---------------------------------------------------------|
|Minimum Support|13.0    |Timetables are not supported                             |
|Full Support   |14 (beta)|Full support for iPadOS                                  |

#### iOS
|Support        |Version |Notes                                                    |
|---------------|--------|---------------------------------------------------------|
|Minimum Support|13.0    |Certain animations may not work                          |
|Full Support   |14 (beta)|Full support for iOS                                     |

#### MacOS
|Support        |Version |Notes                                                    |
|---------------|--------|---------------------------------------------------------|
|Minimum Support|11 (beta) |                                                         |

## Technologies/Libraries Used
### Open Source Libraries
- [URLEmbeddedView](https://github.com/marty-suzuki/URLEmbeddedView)
  - Previewing Links in the blog posts
  - Installed using Cocoapods
- [FeedKit](https://github.com/nmdias/FeedKit)
  - Fetching data from Students' Blog (Atom feed)
- [SkeletonView](https://github.com/Juanpe/SkeletonView)
  - Loading animations while getting data from RSS feed
- [Alamofire](https://github.com/alamofire/alamofire)
  - Getting Timetable image from Google Drive API

### Apple Technologies
- [UIKit](https://developer.apple.com/documentation/uikit/)
  - User Interface for iOS, iPadOS and MacOS
- [Mac Catalyst](https://developer.apple.com/documentation/uikit/mac_catalyst)
  - To enable MacOS support
- [Background Tasks](https://developer.apple.com/documentation/backgroundtasks)
  - Fetching new blog posts in the background, on device.
  - This is easier and more cost effective than running a server to push notifications to each device 
    - TL;DR: I'm broke so this is the best way
    - Limitations: 
      - Unable to work with Low-Power Mode on 
- [User Notifications](https://developer.apple.com/documentation/usernotifications)
  - To send notifications to the users whenever a new post comes (works together with Background Tasks)
- [Core Spotlight](https://developer.apple.com/documentation/corespotlight)
  - To allow users to search for announcements using spotlight search
- [WidgetKit](https://developer.apple.com/widgets/)
  - Adding widgets to app for Timetables.
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)
  - For widgets interface as it does not support UIKit.

## Screenshots (iOS)
Dark and Light mode
<details>
<summary><strong>Home</strong></summary>
  <img src="Screenshots/iPhone/iPhone 6.5in/Dark Mode/home.png" width="250"><img src="Screenshots/iPhone/iPhone 6.5in/Light Mode/home.png" width="250">
</details>

<details>
<summary><strong>Content</strong></summary>
  <img src="Screenshots/iPhone/iPhone 6.5in/Dark Mode/content.png" width="250"><img src="Screenshots/iPhone/iPhone 6.5in/Light Mode/content.png" width="250">
</details>

<details>
<summary><strong>Search with Tags</strong></summary>
  <img src="Screenshots/iPhone/iPhone 6.5in/Dark Mode/search.png" width="250"><img src="Screenshots/iPhone/iPhone 6.5in/Light Mode/search.png" width="250">
</details>

<details>
<summary><strong>Spotlight Search</strong></summary>
<img src="Screenshots/iPhone/iPhone 6.5in/spotlight.png" width="250">
</details>

## Colors
### Main Colors
These colors are used for different parts of the app such as backgrounds and labels.

|Color Name |Identifier|Light Theme|Dark Theme |
|-----------|----------|-----------|-----------|
|Background |`"Background"`|![](https://via.placeholder.com/15/F5F4F6/F5F4F6) - #F5F4F6|![](https://via.placeholder.com/15/1D1D23/1D1D23) - #1D1D23|
|Global Tint|`"Global Tint"`|![](https://via.placeholder.com/15/A9A9A9/A9A9A9) - #A9A9A9|![](https://via.placeholder.com/15/A9A9A9/A9A9A9) - #A9A9A9|
|Grey 1     |`"Grey 1"`|![](https://via.placeholder.com/15/434343/434343) - #434343|![](https://via.placeholder.com/15/B8BABB/B8BABB) - #B8BABB|
|Grey 2     |`"Grey 2"`|![](https://via.placeholder.com/15/DCDADB/DCDADB) - #DCDADB|![](https://via.placeholder.com/15/252628/252628) - #252628|
|Grey 3     |`"Grey 3"`|![](https://via.placeholder.com/15/F0F0F7/F0F0F7) - #F0F0F7|![](https://via.placeholder.com/15/232328/232328) - #232328|
|Table View Selection     |`.systemGray5`|![](https://via.placeholder.com/15/e5e5ea/e5e5ea) - #E5E5EA|![](https://via.placeholder.com/15/2c2c2e/2c2c2e) - #2C2C2E|
|Table View Selection Hover     |`.systemGray4`|![](https://via.placeholder.com/15/d1d1d6/d1d1d6) - #D1D1D6|![](https://via.placeholder.com/15/3a3a3c/3a3a3c) - #3A3A3C|

### Apple Colors
These colors are the ones as part of Apple's [UIColor Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/)

|Color Name |API     |Light Theme|Dark Theme |
|-----------|--------|-----------|-----------|
|Blue       |`.systemBlue`|![](https://via.placeholder.com/15/007BFF/007BFF) - #007BFF|![](https://via.placeholder.com/15/0A84FF/0A84FF) - #0A84FF|
|Label      |`.label`|![](https://via.placeholder.com/15/000000/000000) - #000000|![](https://via.placeholder.com/15/FFFFFF/FFFFFF) - #FFFFFF|

### Loading Colors
These colors are used for loading content using KALoader

|Color Name |Identifier|Light Theme|Dark Theme |
|-----------|----------|-----------|-----------|
|First Load Color|`"First Load Color"`|![](https://via.placeholder.com/15/DEDEDE/DEDEDE) - #DEDEDE|![](https://via.placeholder.com/15/202020/202020) - #202020|
|Second Load Color|`"Second Load Color"`|![](https://via.placeholder.com/15/DDDDDD/DDDDDD) - #DDDDDD|![](https://via.placeholder.com/15/212121/212121) - #212121|
|Back Gray Color |`"Back Gray Color"`|![](https://via.placeholder.com/15/F6F6F6/F6F6F6) - #F6F6F6|![](https://via.placeholder.com/15/080808/080808) - #080808|

## Keyboard Shortcuts
### General
|Command          |Key (Symbols) |Key (Description)            |
|-----------------|--------------|-----------------------------|
|Open in Settings |`⌘ ,`         |Command-Comma                |

### Navigation
|Command          |Key (Symbols) |Key (Description)            |
|-----------------|--------------|-----------------------------|
|Next Post        | `▼`          |Arrow Right or Arrow Down    |
|Previous Post    |`▲`           |Arrow Left or Arrow Up       |

### Getting Announcements
|Command          |Key (Symbols) |Key (Description)            |
|-----------------|--------------|-----------------------------|
|Search           |`⌘ F`         |Command-F                    |
|Filter Post      |`⌘ ⇧ F`       |Command-Shift-F              |
|Reload           |`⌘ R`         |Command-R                    |

### Viewing Posts
|Command          |Key (Symbols) |Key (Description)            |
|-----------------|--------------|-----------------------------|
|Share            |`⌘ S`         |Command-S                    |
|Pin              |`⌘ P`         |Command-P                    |
|Safari           |`⌘ ⇧ S`       |Command-Shift-S              |

### Content Size
|Command          |Key (Symbols) |Key (Description)            |
|-----------------|--------------|-----------------------------|
|Zoom In          |`⌘ =`         |Command-Equal                |
|Zoom Out         |`⌘ -`         |Command-Minus                |
|Reset to Default |`⌘ 1`         |Command-One                  |
