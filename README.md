# ![](https://raw.githubusercontent.com/toggl/superday/master/teferi/Assets.xcassets/icSuperday.imageset/icSuperday.png) Superday
More time, more life.
Superday tracks your activities, you give the context.

# Contributors Guide

This is meant to help new contributors submiting changes to the project.

## Getting started

Requirements:

- [XCode](https://developer.apple.com/download/)
- [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#installation)

Downloading and starting development for superday is supersimple®:

1. Fork this repository
2. Clone it locally
3. `$ cd` to location
4. Run `$ pod install` to fetch dependencies
5. Open `teferi.xworkspace` to start working
6. There is no step six

## Pull Request Etiquette

Make pull requests for specific concerns and use clear titles and descriptions. Don't sneak other features into your branch to avoid creating needless dependencies. It is your responsibility to make sure the branch is up to date with master or merges trivially. Feel free to make pull requests for work in progress features to ask for feedback.

### Swift style guide

Please refer to [this document](https://github.com/toggl/superday/blob/develop/SwiftStyleGuide.md).

### Commits

- Keep commits small, clear and specific
- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move file to..." not "Moves file to...")
- Limit the first line to 72 characters or less
- Do not reference issues/pull requests in commit messages

### Emoji Styleguide

Consider selecting the appropriate emoji for each of your commits (based on [Atom's emoji styleguide](https://github.com/atom/atom/blob/master/CONTRIBUTING.md#git-commit-messages)).

- :bug: `:bug:` - Bug fixes
- :memo: `:memo:` - Adding docs
- :fire: `:fire:` - Removing code
- :package: `:package:` - Adding new pods
- :green_heart: `:green_heart:` - Fixes CI Build
- :art: `:art:` - Adding UI components
- :white_check_mark: `:white_check_mark:` Adding tests
- :sparkles: `:sparkles:` - Adding a new feature
- :construction: `:construction:` - Work in Progress
- :racehorse: `:racehorse:` Improving performance
- :non-potable_water: `:non-potable_water:` Fixing memory leaks
- :lipstick: `:lipstick:` - Cosmetic changes to codestyle
- :triangular_ruler: `:triangular_ruler:` - Pixel perfect changes to UI
- :earth_americas: `:earth_americas:` - Changes to the location tracker
- :chart_with_upwards_trend: `:chart_with_upwards_trend:` - General improvements