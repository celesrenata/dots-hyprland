# Phase 7: Community & Maintenance

## Overview
This final phase establishes the long-term sustainability of the NixOS dots-hyprland project through community building, upstream integration, maintenance procedures, and documentation. Based on the active community around the original repo, we need to create pathways for contribution and ongoing development.

## Community Building Strategy

### 1. Project Structure for Collaboration

#### Repository Organization
```
nixos-dots-hyprland/
├── README.md                    # Project overview and quick start
├── CONTRIBUTING.md              # Contribution guidelines
├── CHANGELOG.md                 # Version history and changes
├── LICENSE                      # Project license (GPL-3.0)
├── flake.nix                   # Main flake entry point
├── flake.lock                  # Locked dependencies
├── docs/                       # Comprehensive documentation
│   ├── installation/           # Installation guides
│   ├── configuration/          # Configuration examples
│   ├── troubleshooting/        # Common issues and solutions
│   ├── development/            # Developer documentation
│   └── api/                    # Module API documentation
├── examples/                   # Example configurations
│   ├── basic/                  # Minimal setup
│   ├── gaming/                 # Gaming-optimized setup
│   ├── development/            # Developer workstation
│   └── server/                 # Headless server setup
├── modules/                    # NixOS/Home Manager modules
├── packages/                   # Custom package derivations
├── configs/                    # Configuration templates
├── assets/                     # Static assets (icons, themes)
├── testing/                    # Test suite and validation
├── scripts/                    # Utility scripts
└── .github/                    # GitHub workflows and templates
    ├── workflows/              # CI/CD pipelines
    ├── ISSUE_TEMPLATE/         # Issue templates
    └── PULL_REQUEST_TEMPLATE.md # PR template
```

#### Contribution Guidelines (`CONTRIBUTING.md`)
```markdown
# Contributing to nixos-dots-hyprland

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Getting Started

### Prerequisites
- NixOS or Nix package manager
- Basic understanding of Nix language
- Familiarity with Hyprland and desktop environments

### Development Environment
```bash
# Clone the repository
git clone https://github.com/your-org/nixos-dots-hyprland.git
cd nixos-dots-hyprland

# Enter development shell
nix develop

# Run tests
./testing/run-tests.sh
```

## Types of Contributions

### 1. Bug Reports
- Use the bug report template
- Include system information (NixOS version, hardware)
- Provide reproduction steps
- Include relevant logs

### 2. Feature Requests
- Use the feature request template
- Explain the use case and benefits
- Consider implementation complexity
- Check if it aligns with project goals

### 3. Code Contributions
- Fork the repository
- Create a feature branch
- Follow coding standards
- Add tests for new functionality
- Update documentation
- Submit a pull request

### 4. Documentation
- Fix typos and improve clarity
- Add examples and use cases
- Translate documentation
- Create video tutorials

## Coding Standards

### Nix Code Style
- Use 2-space indentation
- Follow nixpkgs conventions
- Use meaningful variable names
- Add comments for complex logic
- Format with `nixpkgs-fmt`

### Module Structure
- Follow NixOS module conventions
- Use proper option types
- Provide good descriptions
- Include examples
- Add assertions for validation

### Testing Requirements
- Add tests for new features
- Ensure existing tests pass
- Test on multiple configurations
- Document test procedures

## Review Process

### Pull Request Requirements
- [ ] Code follows style guidelines
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No breaking changes (or properly documented)
- [ ] Commit messages are clear

### Review Criteria
- Functionality correctness
- Code quality and maintainability
- Performance impact
- Security considerations
- Documentation completeness

## Community Guidelines

### Code of Conduct
We follow the [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct.

### Communication Channels
- GitHub Issues: Bug reports and feature requests
- GitHub Discussions: General questions and ideas
- Discord: Real-time chat and support
- Matrix: Alternative chat platform

### Recognition
Contributors are recognized in:
- CHANGELOG.md for significant contributions
- README.md contributors section
- Release notes for major features
```

### 2. Documentation Strategy

#### Comprehensive Documentation Site
```nix
# docs/flake.nix - Documentation site using mdBook
{
  description = "nixos-dots-hyprland documentation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        docs = pkgs.stdenv.mkDerivation {
          name = "nixos-dots-hyprland-docs";
          src = ./.;
          
          nativeBuildInputs = with pkgs; [ mdbook ];
          
          buildPhase = ''
            mdbook build
          '';
          
          installPhase = ''
            cp -r book $out
          '';
        };
      in
      {
        packages.default = docs;
        
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            mdbook
            mdbook-linkcheck
            mdbook-mermaid
          ];
        };
      });
}
```

#### Documentation Structure (`docs/book.toml`)
```toml
[book]
authors = ["nixos-dots-hyprland contributors"]
language = "en"
multilingual = false
src = "src"
title = "nixos-dots-hyprland Documentation"
description = "Complete guide to using and configuring nixos-dots-hyprland"

[preprocessor.mermaid]
command = "mdbook-mermaid"

[preprocessor.linkcheck]
command = "mdbook-linkcheck"

[output.html]
default-theme = "navy"
preferred-dark-theme = "navy"
git-repository-url = "https://github.com/your-org/nixos-dots-hyprland"
edit-url-template = "https://github.com/your-org/nixos-dots-hyprland/edit/main/docs/src/{path}"

[output.html.search]
enable = true
limit-results = 30
teaser-word-count = 30
use-boolean-and = true
boost-title = 2
boost-hierarchy = 1
boost-paragraph = 1
expand = true
heading-split-level = 3
copy-js = true

[output.html.fold]
enable = false
level = 0

[output.html.playground]
editable = false
copyable = true
copy-js = true
line-numbers = false
runnable = false
```

### 3. Upstream Integration Strategy

#### nixpkgs Integration Plan
```markdown
# nixpkgs Integration Roadmap

## Phase 1: Package Submissions
- [ ] Submit quickshell package to nixpkgs
- [ ] Submit material-color-utilities package
- [ ] Submit supporting packages and dependencies

## Phase 2: Module Integration
- [ ] Propose Home Manager module for inclusion
- [ ] Create NixOS module for system integration
- [ ] Ensure compatibility with nixpkgs standards

## Phase 3: Maintenance
- [ ] Establish maintainer team in nixpkgs
- [ ] Set up automated updates for packages
- [ ] Monitor for breaking changes in dependencies

## Package Submission Checklist

### quickshell Package
- [ ] Create proper derivation with all dependencies
- [ ] Add comprehensive meta information
- [ ] Test on multiple architectures
- [ ] Add to appropriate package sets
- [ ] Find nixpkgs maintainer sponsor

### Home Manager Module
- [ ] Follow Home Manager module conventions
- [ ] Provide comprehensive options
- [ ] Add proper documentation
- [ ] Include usage examples
- [ ] Test with different Home Manager versions
```

#### Collaboration with Upstream Projects
```markdown
# Upstream Collaboration Strategy

## Hyprland Project
- Contribute bug fixes and improvements
- Share configuration best practices
- Participate in community discussions
- Report NixOS-specific issues

## Quickshell Project
- Contribute to Quickshell development
- Maintain NixOS packaging
- Share widget implementations
- Report packaging issues

## end-4/dots-hyprland
- Maintain compatibility with original
- Share NixOS-specific improvements
- Contribute back useful features
- Coordinate on major changes

## NixOS Community
- Participate in NixOS discourse
- Share knowledge and best practices
- Help other users with similar setups
- Contribute to NixOS documentation
```

## Maintenance Procedures

### 1. Version Management and Releases

#### Semantic Versioning Strategy
```markdown
# Version Management

## Versioning Scheme
We follow [Semantic Versioning](https://semver.org/):
- MAJOR.MINOR.PATCH (e.g., 1.2.3)
- MAJOR: Breaking changes
- MINOR: New features, backward compatible
- PATCH: Bug fixes, backward compatible

## Release Types

### Major Releases (X.0.0)
- Significant architectural changes
- Breaking configuration changes
- New major features
- Quarterly schedule

### Minor Releases (X.Y.0)
- New features and enhancements
- Non-breaking configuration additions
- Performance improvements
- Monthly schedule

### Patch Releases (X.Y.Z)
- Bug fixes
- Security updates
- Documentation improvements
- As-needed basis

## Release Process

### Pre-release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped in flake.nix
- [ ] Breaking changes documented
- [ ] Migration guide created (if needed)

### Release Steps
1. Create release branch
2. Final testing and validation
3. Update version numbers
4. Generate release notes
5. Create GitHub release
6. Update documentation
7. Announce release

### Post-release
- Monitor for issues
- Prepare hotfixes if needed
- Plan next release cycle
- Gather community feedback
```

#### Automated Release Pipeline
```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v22
      - uses: cachix/cachix-action@v12
        with:
          name: nixos-dots-hyprland
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
      
      - name: Run tests
        run: |
          nix flake check
          ./testing/run-tests.sh

  build:
    needs: test
    runs-on: ubuntu-latest
    strategy:
      matrix:
        system: [x86_64-linux, aarch64-linux]
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v22
      - uses: cachix/cachix-action@v12
        with:
          name: nixos-dots-hyprland
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
      
      - name: Build packages
        run: |
          nix build .#packages.${{ matrix.system }}.quickshell
          nix build .#packages.${{ matrix.system }}.material-color-utilities

  release:
    needs: [test, build]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Generate changelog
        run: |
          # Generate changelog from commits
          git log --pretty=format:"- %s" $(git describe --tags --abbrev=0 HEAD^)..HEAD > RELEASE_NOTES.md
      
      - name: Create release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body_path: RELEASE_NOTES.md
          draft: false
          prerelease: false

  update-docs:
    needs: release
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v22
      
      - name: Build documentation
        run: |
          cd docs
          nix build
      
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs/result
```

### 2. Issue Management and Support

#### Issue Triage System
```markdown
# Issue Management

## Issue Labels

### Type Labels
- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements or additions to documentation
- `question`: Further information is requested
- `duplicate`: This issue or pull request already exists
- `wontfix`: This will not be worked on

### Priority Labels
- `priority/critical`: Critical issues blocking basic functionality
- `priority/high`: Important issues affecting many users
- `priority/medium`: Standard issues and enhancements
- `priority/low`: Nice-to-have improvements

### Component Labels
- `component/hyprland`: Hyprland configuration issues
- `component/quickshell`: Quickshell widget issues
- `component/theming`: Material You theming issues
- `component/ai`: AI integration issues
- `component/packaging`: Nix packaging issues

### Status Labels
- `status/needs-info`: Waiting for more information
- `status/in-progress`: Currently being worked on
- `status/needs-review`: Ready for review
- `status/blocked`: Blocked by external dependency

## Triage Process

### Initial Triage (within 24 hours)
1. Add appropriate labels
2. Ask for clarification if needed
3. Assign priority level
4. Link to related issues
5. Assign to milestone if applicable

### Weekly Triage Meeting
- Review all open issues
- Update priorities and assignments
- Close resolved issues
- Plan work for upcoming sprint

## Support Channels

### GitHub Issues
- Bug reports
- Feature requests
- Technical questions

### GitHub Discussions
- General questions
- Configuration help
- Community showcase
- Ideas and feedback

### Discord/Matrix
- Real-time support
- Community chat
- Development coordination
- Quick questions
```

#### Automated Issue Management
```yaml
# .github/workflows/issue-management.yml
name: Issue Management

on:
  issues:
    types: [opened, labeled]
  issue_comment:
    types: [created]

jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
      - name: Add needs-info label for incomplete bug reports
        if: github.event.action == 'opened' && contains(github.event.issue.labels.*.name, 'bug')
        uses: actions/github-script@v6
        with:
          script: |
            const issue = context.payload.issue;
            const body = issue.body || '';
            
            // Check if required information is present
            const hasSystemInfo = body.includes('System Information') || body.includes('NixOS version');
            const hasSteps = body.includes('Steps to Reproduce') || body.includes('reproduction');
            const hasLogs = body.includes('Logs') || body.includes('error');
            
            if (!hasSystemInfo || !hasSteps || !hasLogs) {
              await github.rest.issues.addLabels({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: issue.number,
                labels: ['status/needs-info']
              });
              
              await github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: issue.number,
                body: `Thank you for reporting this issue! To help us investigate, please provide:

- [ ] System information (NixOS version, hardware details)
- [ ] Steps to reproduce the issue
- [ ] Relevant logs or error messages
- [ ] Configuration details

You can edit your original issue to add this information.`
              });
            }

  stale:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/stale@v8
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}
          stale-issue-message: |
            This issue has been automatically marked as stale because it has not had
            recent activity. It will be closed if no further activity occurs within 7 days.
            If this is still an issue, please comment to keep it open.
          stale-pr-message: |
            This pull request has been automatically marked as stale because it has not had
            recent activity. It will be closed if no further activity occurs within 7 days.
            If you're still working on this, please comment to keep it open.
          days-before-stale: 30
          days-before-close: 7
          stale-issue-label: 'status/stale'
          stale-pr-label: 'status/stale'
          exempt-issue-labels: 'priority/critical,priority/high,status/in-progress'
          exempt-pr-labels: 'priority/critical,priority/high,status/in-progress'
```

### 3. Dependency Management

#### Automated Dependency Updates
```yaml
# .github/workflows/update-deps.yml
name: Update Dependencies

on:
  schedule:
    - cron: '0 0 * * 1' # Weekly on Monday
  workflow_dispatch:

jobs:
  update-flake:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v22
      
      - name: Update flake inputs
        run: |
          nix flake update
          
      - name: Test updated dependencies
        run: |
          nix flake check
          ./testing/run-tests.sh --quick
          
      - name: Create pull request
        uses: peter-evans/create-pull-request@v5
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          commit-message: 'chore: update flake inputs'
          title: 'chore: update flake inputs'
          body: |
            Automated update of flake inputs.
            
            Please review the changes and ensure all tests pass before merging.
          branch: update-deps
          delete-branch: true

  check-upstream:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v22
      
      - name: Check for upstream updates
        run: |
          # Check end-4/dots-hyprland for updates
          UPSTREAM_COMMIT=$(curl -s https://api.github.com/repos/end-4/dots-hyprland/commits/main | jq -r '.sha')
          CURRENT_COMMIT=$(cat .upstream-commit 2>/dev/null || echo "unknown")
          
          if [ "$UPSTREAM_COMMIT" != "$CURRENT_COMMIT" ]; then
            echo "Upstream has new commits: $UPSTREAM_COMMIT"
            echo "Current tracking: $CURRENT_COMMIT"
            
            # Create issue to track upstream changes
            gh issue create \
              --title "Upstream changes available" \
              --body "New commits available in end-4/dots-hyprland: $UPSTREAM_COMMIT" \
              --label "upstream,enhancement"
          fi
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Long-term Sustainability

### 1. Maintainer Team Structure

#### Roles and Responsibilities
```markdown
# Maintainer Team

## Core Maintainers
- Overall project direction
- Release management
- Breaking change decisions
- Conflict resolution

## Component Maintainers
- **Packaging**: Nix derivations and packaging
- **Modules**: NixOS and Home Manager modules
- **Documentation**: User and developer documentation
- **Testing**: Test suite and CI/CD
- **Community**: Issue triage and user support

## Contributor Recognition
- Regular contributors can become component maintainers
- Component maintainers can become core maintainers
- Recognition through GitHub teams and permissions
- Annual contributor appreciation

## Succession Planning
- Document all processes and procedures
- Cross-train maintainers on different components
- Maintain bus factor > 1 for critical components
- Regular maintainer meetings and knowledge sharing
```

### 2. Financial Sustainability

#### Funding Strategy
```markdown
# Funding and Sustainability

## Current Funding Sources
- GitHub Sponsors
- Open Collective
- Individual donations
- Corporate sponsorships

## Funding Uses
- Infrastructure costs (CI/CD, hosting)
- Maintainer compensation
- Development tools and services
- Community events and meetups

## Transparency
- Monthly financial reports
- Public budget and expenses
- Clear funding goals and usage
- Regular community updates

## Corporate Partnerships
- Sponsor recognition in documentation
- Priority support for sponsors
- Custom development services
- Training and consulting
```

### 3. Knowledge Management

#### Documentation and Knowledge Base
```markdown
# Knowledge Management

## Internal Documentation
- Architecture decisions and rationale
- Development processes and workflows
- Troubleshooting guides and runbooks
- Historical context and lessons learned

## Knowledge Transfer
- Regular maintainer meetings
- Code review processes
- Pair programming sessions
- Documentation requirements for changes

## Community Knowledge
- FAQ and common issues
- Configuration examples and patterns
- Video tutorials and guides
- Community-contributed content

## Preservation
- Regular backups of all repositories
- Mirror repositories on multiple platforms
- Archive important discussions and decisions
- Maintain historical documentation
```

## Action Items for Phase 7

### Month 1: Foundation
1. **Set up project infrastructure** - Repository, CI/CD, documentation site
2. **Create contribution guidelines** - Clear processes for community involvement
3. **Establish communication channels** - Discord, Matrix, GitHub Discussions
4. **Begin upstream integration** - Submit packages to nixpkgs

### Month 2: Community Building
1. **Launch documentation site** - Comprehensive user and developer docs
2. **Create example configurations** - Showcase different use cases
3. **Establish maintainer team** - Define roles and responsibilities
4. **Begin community outreach** - Social media, forums, conferences

### Month 3: Sustainability
1. **Implement automated processes** - Dependency updates, testing, releases
2. **Set up funding mechanisms** - Sponsors, donations, partnerships
3. **Create long-term roadmap** - Future features and improvements
4. **Establish governance model** - Decision-making processes

### Ongoing: Maintenance
1. **Regular releases** - Monthly minor releases, quarterly major releases
2. **Community support** - Issue triage, user assistance, documentation
3. **Upstream coordination** - Track changes, contribute improvements
4. **Performance monitoring** - Ensure quality and reliability

## Expected Outcomes

### Deliverables
1. **Thriving community** - Active contributors and users
2. **Sustainable maintenance** - Reliable processes and funding
3. **Upstream integration** - Packages and modules in nixpkgs
4. **Comprehensive documentation** - User guides, API docs, tutorials
5. **Quality assurance** - Automated testing and validation
6. **Long-term viability** - Clear governance and succession planning

### Success Criteria
- [ ] Active community with regular contributions
- [ ] Packages accepted into nixpkgs
- [ ] Sustainable funding model established
- [ ] Comprehensive documentation and support
- [ ] Reliable release and maintenance processes
- [ ] Clear governance and decision-making processes
- [ ] Strong relationship with upstream projects
- [ ] Growing user base and positive feedback

This comprehensive community and maintenance phase ensures the long-term success and sustainability of the NixOS dots-hyprland project, creating a vibrant ecosystem around this desktop environment adaptation.
