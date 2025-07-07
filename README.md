
![Context Banner](logo-banner.png)

# Context <a href="https://github.com/tartavull/context/releases/latest"><img src="https://img.shields.io/github/v/release/tartavull/context?label=Download%20for%20macOS&style=for-the-badge&logo=apple&logoColor=white&color=blue" alt="Download for macOS" align="right"></a>

**Never lose context.**

Have you noticed how LLMs are so smart on the first answer and so stupid after a few back and forth? We keep them smart by intelligently managing what stays in **context**.

## Download

Get the latest universal macOS installer from our [GitHub releases page](https://github.com/tartavull/context/releases/latest). Compatible with both Intel and Apple Silicon Macs.

## Documentation

For setup instructions, architecture details, and development guides, see the [documentation](https://tartavull.github.io/context/).

## Development

### Prerequisites

- macOS 12.0 or later
- Xcode 14.0 or later
- [SwiftLint](https://github.com/realm/SwiftLint) for code formatting

### Setup

1. Clone the repository
2. Install SwiftLint: `brew install swiftlint`
3. Set up Git hooks: `./scripts/setup-git-hooks.sh`

### Git Hooks

This project uses Git hooks to ensure code quality:

- **pre-commit**: Runs SwiftLint before each commit
- **pre-push**: Runs SwiftLint before each push

To install the hooks for your local repository:

```bash
./scripts/setup-git-hooks.sh
```

To bypass hooks (not recommended):

```bash
git commit --no-verify
git push --no-verify
```

To auto-fix SwiftLint issues:

```bash
swiftlint --fix
```

## License

This project is licensed under the MIT License. 