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
+(NSDictionary *)diffWins:(NSArray *)wins andLoses:(NSArray *)loses;

[DS diffWins: shadow andLoses: client];
```

## Updates
```objective-c

This method doesn't find out duplicate objs.
+(NSDictionary *)diffWins:(NSArray *)wins
                    loses:(NSArray *)loses;
                    
// ** Now if there is no any add, delete, replace in the diff, diff will be nil. **
NSDictionary *diff = [DS diffWins: ["A"] loses: ["A"]];
// diff is nil.

// primaryKey is for finding duplicate objs.
+(NSDictionary *)diffWins:(NSArray *)wins
                    loses:(NSArray *)loses
               primaryKey:(NSString *)key;
               

// This method will find out duplicate objs and pass out to you.
// You can choose which value you want to keep. return YES if you want to keep newValue.
+(NSArray *)mergeInto:(NSArray *)array
            applyDiff:(NSDictionary *)diff
           primaryKey:(NSString *)key
        shouldReplace:(BOOL(^)(id oldValue, id newValue))shouldReplace;
```

## Usage
Differential Synchronizatioin step by step
1. diff client and shadow
2. create a newClient and make it equal to remote
3. apply client_shadow (step.1) into newClient (step.2)
4. diff remote and newClient (step.3)
5. push diff (step.4) to remote, so that new remote == new client
6. if push success, save new client in shadow

## Example
This example you can refer to Tests.m line: 148, test 3.1
```objective-c
NSArray *remote = @[@"A", @"B", @"C"];
NSArray *client = @[@"A", @"B", @"C", @"D"]; // client add "D"
NSArray *shadow = @[@"A", @"B", @"C"]; // last synchronized result == remote

// obtain a diff from client and shadow.
NSDictionary *diff_client_shadow = [DS diffShadowAndClient: client shadow: shadow];

// create a newClient and make it equal to remote
NSArray *newClient = remote;

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
 Get a array that from diff and find duplicate.
 
 @param array into the array that will be patched by diff.
 @param diff diff the diff object between two dictionaries. it contains keys ("add", "delete", "replace")
 @param key primaryKey
 @param shouldReplace shouldReplace block sent a oldValue and newValue data and return a Boolean that you can choose that whether you want to replace it or not.

  @return return array that old data merge new diff.
 */
+(NSArray *)mergeInto:(NSArray *)array
            applyDiff:(NSDictionary *)diff
           primaryKey:(NSString *)key
        shouldReplace:(BOOL(^)(id oldValue, id newValue))shouldReplace;
```


This example you can refer to DuplicateTests.m line: 41, test Spec: "commitId passed, remoteHash passed, example in README.md"
```objective-c
 describe(@"commitId passed, remoteHash passed, example in README.md", ^{
  
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
  // diff
  // add    : [@{@"name": @"D", @"url": @"D"}]
  // delete : [@{@"name": @"B", @"url": @"B"}, @{@"name": @"A", @"url": @"A"}]
  // replace: [@{@"name": @A", @"url": @"A1"}]
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  /*
   // shadow @[@{@"name": @"A", @"url": @"A"},
               @{@"name": @"B", @"url": @"B"},
               @{@"name": @"C", @"url": @"C"}]
   
   // diff
   // add    : [@{@"name": @"D", @"url": @"D"}],
   // delete : [@{@"name": @"B", @"url": @"B"}, @{@"name": @"A", @"url": @"A"}]
   // replace: [@{@"name": @A", @"url": @"A1"}]
   */
  
  NSArray *newClient = remote;
  
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                
    return YES;
  }];
  
  // diff newClient and remote
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote primaryKey: @"name"];
  
  // push diff_newClient_Remote to remote
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D"}
                                            ]);
  });
});

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
