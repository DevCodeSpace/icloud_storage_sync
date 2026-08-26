## Version 0.0.5

### 🐛 Critical Bug Fixes

**NSMetadataQuery Observer Leaks Fixed**
- Fixed memory leak where block-based notification observer tokens were never removed after `gather()` and `download()` operations
- Implemented proper observer token tracking using `queryObservers` dictionary
- All metadata queries now properly clean up observers via `removeObservers()` method

**Scoped Query Predicate Fixed**
- Fixed missing `%K` argument in NSPredicate format string
- Predicate now correctly formats: `"%K == %@ OR %K beginswith %@"` with proper key bindings
- Queries now execute with correct scope and filtering

### ✨ New Features

**Path Prefix Support for gather()**
- Added optional `relativePathPrefix` parameter to `gather()` method
- Allows callers to scan only a specific subdirectory instead of entire container
- Reduces metadata query overhead and improves performance for large containers

**Timeout Support for gather()**
- Added optional `timeout` parameter (as Duration in Dart, milliseconds in native code)
- Prevents indefinite hangs when metadata query doesn't complete
- Gracefully fails with `METADATA_QUERY_TIMEOUT` error on timeout
- Properly cleans up resources on timeout

### 🔧 Improvements

**Better Query Lifecycle Management**
- Live `onUpdate` streams now properly run until cancelled or timeout
- Proper stream cleanup on cancellation via `onCancelHandler`
- Download operations no longer leave live metadata queries running
- Eliminated progressive slowdown from repeated download operations

**Enhanced Error Handling**
- Added graceful timeout error handling for long-running queries
- Improved resource cleanup in all error scenarios
- Better state management for streaming vs non-streaming modes

## Version 0.0.4

📦 Updated dependencies: `intl` to `>=0.20.2`, `flutter_lints` to `^6.0.0`

📝 Updated README to use local asset references instead of remote URLs

🎨 Improved README formatting and table alignment

## Version 0.0.3

🗂️ Extended Delete method to support directory deletion 

🐛 Fixed index mismatch issue when deleting files

## Version 0.0.2

✨ Added replace file functionality

⚡️ Enhanced performance for large files

📝 Updated documentation

## Version 0.0.1 - Initial Release

Welcome to the first release of the icloud_storage_sync plugin for Flutter!

### Features:
🚀 Introduces iCloud storage sync functionality

☁️ Allows seamless data synchronization between devices using iCloud

🔑 Provides easy-to-use APIs for reading and writing data to iCloud

🔄 Supports automatic conflict resolution for simultaneous updates

### Documentation:
📚 Includes comprehensive documentation and example code for quick integration