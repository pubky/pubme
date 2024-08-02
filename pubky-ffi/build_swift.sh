#!/bin/bash
 
# Build the dylib
cargo build --release


echo "\n\n\n***********GENERATING BINDINGS***********\n\n\n"
 
# Generate bindings
cargo run --bin uniffi-bindgen -- generate --language swift ./src/pubky_client.udl --out-dir ./ffi/bindings || exit 1


echo "\n\n\n***********ADDING TARGETS***********\n\n\n"

for TARGET in \
        aarch64-apple-darwin \
        aarch64-apple-ios \
        aarch64-apple-ios-sim \
        x86_64-apple-darwin \
        x86_64-apple-ios
do
    rustup target add $TARGET  || exit 1
    cargo build --release --target=$TARGET  || exit 1
    echo "\nBuilt for $TARGET"
done
 
mv ./ffi/bindings/pubkyclientFFI.modulemap ./ffi/bindings/module.modulemap
 
echo "\n\n\n***********CREATING XCFramework***********\n\n\n"

# Create XCFramework
rm -rf "./ffi/swift/Pubky.xcframework"
xcodebuild -create-xcframework \
        -library ./target/aarch64-apple-ios-sim/release/libpubkyclient.a -headers ./ffi/bindings \
        -library ./target/aarch64-apple-ios/release/libpubkyclient.a -headers ./ffi/bindings \
        -output "./ffi/swift/Pubky.xcframework"
 
