# Contributing to Osceola ARES Website

Thank you for your interest in contributing! This guide will help you get started.

## Development Environment

This project is designed to work seamlessly in [GitHub Codespaces](https://github.com/features/codespaces), which provides a pre-configured development container with:

- Up-to-date Git
- Go and common Go utilities
- Node.js, npm, and eslint
- Hugo static site generator
- Terraform CLI (plus TFLint and Terragrunt)
- Recommended VS Code extensions

You can also set up your own environment with these tools if you prefer.

## How to Contribute

### 1. Fork the Repository

Click the **Fork** button at the top right of the repository page to create your own copy.

### 2. Create a Codespace

In your fork, click the green **Code** button, select the **Codespaces** tab, and click **Create codespace on main**.

### 3. Make Your Changes

- Edit or add files as needed.
- Follow existing code style and conventions.
- For Hugo content, edit files in the `content/` directory.
- For configuration, see `config.toml` or related files.

### 4. Test Your Changes

- The Hugo server should start automatically in Codespaces.
- Preview your changes at the forwarded port (usually `http://localhost:1313/`).
- For code changes, run any relevant tests or linters.

### 5. Commit and Push

- Commit your changes with a clear message.
- Push to a branch in your fork.

### 6. Open a Pull Request

- Go to your fork on GitHub.
- Click **Compare & pull request**.
- Describe your changes and submit the PR.

## Code Style

- Use consistent formatting.
- Run `eslint` for JavaScript/Node code.
- Use `hugo` to build and preview site changes.
- For Terraform, run `terraform fmt` and `tflint` if available.

## Need Help?

Open an issue or start a discussion if you have questions or need guidance.

Thank you