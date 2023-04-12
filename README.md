# Marathon test runner: разбираемся и настраиваем Android & iOS
## Relevant links
### Sample apps
Android: https://github.com/MarathonLabs/marathon/tree/0.8.1/sample/android-app
iOS: https://github.com/MarathonLabs/marathon/tree/0.8.1/sample/ios-app

### Marathon distribution
Version 0.8.1
https://github.com/MarathonLabs/marathon/releases/tag/0.8.1


# Common
## Installation
0. Homebrew
1. Custom
2. Container

## Quickstart
### Testing workflow
Input:
- Test and application binaries
- Marathonfile

Steps:
- Parse tests
- Map-reduce to available hardware
- Collect results

Output:
- Raw
  - JUnit XML
  - Allure results
  - Runtime bill
  - Files from devices
  - Logs
  - Screenshots/videos
- Visual
  - html
  - timeline
  - allure html report (generated)
- Stdout
- Exit code

## Analytics
Why analytics TSDB is required?
* smart retries
* test balancing
* statistics for development teams

1. InfluxDB v1 + v2
2. Graphite
3. Disabled
   a. Test probability of passing 0.0
   b. Test expected duration 300s

## Reliability
Classification of retries
* Preventive (flakiness strategy)
* Post-factum (retry strategy)
* Uncompleted (uncompleted retry quota)

## Performance
* Parallelisation (flakiness strategy)
* Launch overhead (batching strategy)
* Prediction error (sorting strategy)

## Filtering
0. Testing logic

1. Fully qualified test name
2. Fully qualified class name
3. Simple class name
4. Package name
5. Method name
6. Annotation/metaproperty name

Filtering by:
1. Values
2. Regex
3. one more choice below

## Beyond a single test run
1. Gitops via Marathonfile
2. Dynamic configuration
   a. Envvar interpolation
   b. Filtering values file
   c. Custom templating (i.e. [liquid](https://shopify.github.io/liquid/))
--- 
# Android
## Connecting devices
Android debug bridge
1. USB
2. TCP/IP
   a. `adb connect`
   b. `adb pair`

### Support for multiple adb servers
Usually only one is used, but some features such as gRPC access to emulator requires connecting to multiple adb servers instead of connecting devices via `adb connect`

## Test parsing
1. Local via [dex-test-parser](https://github.com/linkedin/dex-test-parser)

Pros: Fast
Cons: Unable to parse dynamically-generated tests

2. Remote via `am instrument -e log true`

Pros: Supports most dynamically-generated tests
Cons: Slower, requires android device, custom testing frameworks might not properly implement the contract of am instrument i.e. [flutter](https://github.com/flutter/flutter/issues/93392)

## Screen recording
Defaults to video recording up to 180sec

Screenshots via custom gif encoder

Priority: video -> screenshots -> none

## Test side effects
Reduce the side-effects for each batch via `pm clear`

Note: resets the permissions

## Timeouts
Internal implementation of marathon supports highly granular timeouts for each adb command

## Test access
Use this feature to gain access to the device's external managements APIs:
1. ADB
2. Telnet (locally connected emulator only)
3. gRPC (locally connected emulator only)

Samples:
1. https://github.com/MarathonLabs/marathon/blob/0.8.1/sample/android-app/app/src/androidTest/java/com/example/AdbActivityTest.kt
2. https://github.com/MarathonLabs/marathon/blob/0.8.1/sample/android-app/app/src/androidTest/java/com/example/ConsoleActivityTest.kt
3. https://github.com/MarathonLabs/marathon/blob/0.8.1/sample/android-app/app/src/androidTest/java/com/example/GrpcActivityTest.kt

gRPC reference:
https://github.com/Malinskiy/adam/blob/0.5.0/adam/src/main/proto/emulator_controller.proto

## AndroidX ScreenCapture API
Allows tests to attach screenshots during execution to the Allure report

Sample: https://github.com/MarathonLabs/marathon/blob/0.8.1/sample/android-app/app/src/androidTest/java/com/example/ScreenshotTest.kt#L32

## File sync (push/pull)
Marathon can push files before each batch and pull files after each batch of tests.

Supported locations:
* EXTERNAL_STORAGE
* APP_DATA (pull only)
* LOCAL_TMP

Aggregation modes:
* DEVICE
* POOL
* DEVICE_AND_POOL
* TEST_RUN

# iOS
## Connecting devices
Apple doesn't support any notion of remote hardware.
Marathon supports once-before test run provisioning via Marathondevices file with support for using:

1. Local simulators
2. Remote simulators via Secure Shell (ssh)

### Supported devices
1. Pre-created simulator by UDID (Unique Device Identifier)
2. Simulator profile for creation/reuse (device profile + runtime)

## Xcresult
Pull of xcresult files is supported

Note: no merging

## Screen recorder
Defaults to video recording

Screenshots via custom gif encoder

Priority: video -> screenshots -> none

Video:
- Codec: h264/hevc
- Mask: black/ignored
- Display: internal/external

Screenshots:
- Mask: black/ignored
- Display: internal/external
- Downscaling resolution
- Screenshot interval delay

## Simulator lifecycle
Limits the side-effects via restart/clean

Reduces resource consumption via shutting down unused simulators

## Permissions
Caveat: need to specify bundle id for target app

* all -	Apply the action to all services
* calendar -	Allow access to calendar
* contacts-limited - Allow access to basic contact info
* contacts -	Allow access to full contact details
* location -	Allow access to location services when app is in use
* location-always -	Allow access to location services at all times
* photos-add -	Allow adding photos to the photo library
* photos -	Allow full access to the photo library
* media-library -	Allow access to the media library
* microphone -	Allow access to audio input
* motion -	Allow access to motion and fitness data
* reminders -	Allow access to reminders
* siri -	Allow use of the app with Siri

## Timeouts
Granular operation timeouts are supported

## Envvars
Passing external parameters to tests, i.e. location of a mock server, or api environment to use for e2e testing

# Optimal configuration
## Fast
Batching + sorting by execution time + limited retries
Android: no pm clear (very expensive)

## Reliable
Batching size 1 + sorting by execution time + lots of post-factum and uncompleted retries

## Fast and reliable
Flakiness + Batching + sorting by execution time + reasonable retries

# Suboptimal configuration
Map reduce without a single point of coordination: fragmentation filter
