# Contributing

It's good to hear that you want to contribute to notcurses!

There are a number of ways you can contribute to the project. A couple of things that might help get you started.

## Code formatting

Follow the [Pony standard library Style Guide](https://github.com/ponylang/ponyc/blob/main/STYLE_GUIDE.md).

## Bug Reporting

First check to see if there is a current, open [issue](https://github.com/redvers/notcurses/issues) for the bug you have found. If there is, simply add more details or a "me too" to the issue. If there isn't, open a new issue with relevant details like:

* A code snippet that demonstrates the bug
* What you expected to see, and what you saw instead
* Your environment: operating system, Pony compiler version, etc.

## Pull Requests

The process for contributing via pull requests:

1. Fork the repository
2. Clone your fork locally
3. Create a feature branch from `main`
4. Make your changes
5. Push to your fork
6. Open a pull request

Some notes:

* Please limit pull requests to a single feature or bug fix
* Your initial PR comment will serve as the commit message when squash-merged
* Don't squash your commits during review -- that makes it harder for reviewers to see what changed
* Any change with a behavioral effect should include an appropriate changelog label on the PR

## Documentation Formatting

When contributing to documentation, use Markdown format for text content. Don't wrap text at 80 columns; let it flow naturally. For long shell commands, break at 80 columns using backslashes for readability. Prefer full command flags over abbreviated versions.
