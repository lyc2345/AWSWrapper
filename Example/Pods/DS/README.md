# DS

[![CI Status](http://img.shields.io/travis/lyc2345/DS.svg?style=flat)](https://travis-ci.org/lyc2345/DS)
[![Version](https://img.shields.io/cocoapods/v/DS.svg?style=flat)](http://cocoapods.org/pods/DS)
[![License](https://img.shields.io/cocoapods/l/DS.svg?style=flat)](http://cocoapods.org/pods/DS)
[![Platform](https://img.shields.io/cocoapods/p/DS.svg?style=flat)](http://cocoapods.org/pods/DS)

Inspired by Neil Fraser, [Differential Synchronization](https://neil.fraser.name/writing/sync/).

![Image of DS](https://neil.fraser.name/writing/sync/diff2.gif) 

#### Deprecated!
```objective-c
// Deprecated!
+(NSDictionary *)diffShadowAndClient:(NSArray *)client shadow:(NSArray *)shadow;

// Use below
+(NSDictionary *)diffSetWins:(NSArray *)wins losesSet:(NSArray *)loses;

[DS diffSetWins: shadow losesSet: client];
```

## Usage
Differential Synchronizatioin step by step
1. diff client and shadow
2. apply remote into client
3. apply client_shadow (step.1) into newClient (step.2)
4. diff remote and whole new client(step.3)
5. push diff(step.4) , whole new client == new remote
6. if push success, save whole new client in shadow.

## Example
This example you can refer to Tests.m line: 119, test 3.1
```objective-c
NSArray *remote = @[@"A", @"B", @"C"];
NSArray *client = @[@"A", @"B", @"C", @"D"]; // client add "D"
NSArray *shadow = @[@"A", @"B", @"C"]; // last synchronized result == remote

// obtain a diff from client and shadow.
NSDictionary *diff_client_shadow = [DS diffShadowAndClient: client shadow: shadow];

// obtain a diff from remote and client.
NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client];

// apply remote_cilent_diff into client.
NSArray *newClient = [DS mergeInto: client applyDiff: need_to_apply_to_client];

// obtain a new client that applied diff_remote_client and diff_client_shadow.
newClient = [DS mergeInto: newClient applyDiff: diff_client_shadow];

// obtain a diff from remote and newClient.
NSDictionary *need_to_apply_to_remote = [DS diffShadowAndClient: newClient shadow: shadow];

// assuming push diff to remote.
NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];

// assuming push successfully. save newRemote in shadow
shadow = newRemote

// shadow == newRemote == newClient = @[@"A", @"B", @"C", @"D"];
	
```

##### New Method for duplicate objects
```
/**
Get a diff between win and lose. Both win and lose are depend what data are you defining and you can handle the duplicate data which you want to replace or not.

@param wins wins is the data that you think is most important
@param loses loses is the data that you think is less important compares to wins
@param duplicate block send a "wait to be added" data and a "wait to be deleted" data to find a duplicate for return. But here you need to implement by youself. But beware, if you don't return duplicate objects, that means if DS find duplicate objects, DS still does the force replacement for you. Even shouldReplace is NO.
@param shouldReplace shouldReplace block sent a duplicate data and return a Boolean that you can choose that whether you want to replace it or not.
@return a diff which is a dictionary that contains format: @{"add", "delete", "replace"}
*/
+(NSDictionary *)diffWins:(NSArray *)wins
                 andLoses:(NSArray *)loses
                duplicate:(id(^)(id add, id delete))duplicate
            shouldReplace:(BOOL(^)(id deplicate))shouldReplace;
```


This example you can refer to DuplicateTests.m line: 254, test @"example in README.md"
```objective-c
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  
  // client add "D", change A' url to A1
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A1"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"}
                      ];
  
  // last synchronized result == remote
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  // add    : [@{@"name": @"D", @"url": @"D"}]
  // delete : [@{@"name": @"B", @"url": @"B"}, @{@"name": @"A", @"url": @"A"}]
  // replace: [@{@"name": @A", @"url": @"A1"}]
  NSDictionary *diff_client_shadow = [DS diffWins: client andLoses: shadow primaryKey: @"name" shouldReplace:^BOOL(id oldValue, id newValue) {

    return YES;
  }];
  /*
    // shadow @[@{@"name": @"A", @"url": @"A"},
              @{@"name": @"B", @"url": @"B"},
              @{@"name": @"C", @"url": @"C"}]

    // diff   
    // add    : [@{@"name": @"D", @"url": @"D"}],
    // delete : [@{@"name": @"B", @"url": @"B"}, @{@"name": @"A", @"url": @"A"}]
    // replace: [@{@"name": @A", @"url": @"A1"}]
  */

  // obtain a diff from remote and client.
  // diff   
  // add    : [@{@"name": @B", @"url": @"B"}],
  // delete : []
  // replace: [@{@"name": @A", @"url": @"A"}]
  NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client];

  // apply remote_cilent_diff into client.
  NSArray *newClient = [DS mergeInto: client applyDiff: need_to_apply_to_client];
		      
  newClient = [DS mergeInto: newClient applyDiff: diff_client_shadow];
	
  newClient = @[
                      @{@"name": @"A", @"url": @"A1"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"}
                      ];
```

## Installation

To run the example project, clone the repo, and run `pod install` from the Example directory first.


DS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

### Manual
Drag DS.h/DS.m into your project.

### Use Cocoapods
```ruby
pod "DS", :git=> 'https://www.github.com/lyc2345/DS.git'

OR 

pod "DS"
```

## Author

lyc2345, lyc2345@gmail.com

## License

DS is available under the MIT license. See the LICENSE file for more info.
