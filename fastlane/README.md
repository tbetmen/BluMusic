fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios upload_beta_testflight

```sh
[bundle exec] fastlane ios upload_beta_testflight
```

Push a new beta build to TestFlight

### ios get_profile

```sh
[bundle exec] fastlane ios get_profile
```

Download provisioning profile for development

### ios unit_test

```sh
[bundle exec] fastlane ios unit_test
```

Run unit testing

### ios code_coverage

```sh
[bundle exec] fastlane ios code_coverage
```

Gather code coverage from unit test

### ios test_report

```sh
[bundle exec] fastlane ios test_report
```

Run Unit Test and Code Coverage

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
