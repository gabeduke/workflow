workflow "Release" {
  resolves = ["goreleaser"]
  on = "release"
}

workflow "Tag" {
  resolves = ["auto-commit", "push-changelog"]
  on = "push"
}

# workflow "Test" {
#   resolves = ["fmt", "lint", "test"]
#   on = "pull_request"
# }

action "generate-release-changelog" {
  uses = "docker://ferrarimarco/github-changelog-generator:1.15.0.pre.beta"
  secrets = ["CHANGELOG_GITHUB_TOKEN"]
  env = {
    SRC_PATH = "/github/workspace"
  }
  args = "-u gabeduke -p workflow --release-branch develop"
}

action "goreleaser" {
  uses = "docker://goreleaser/goreleaser"
  needs = "generate-release-changelog"
  secrets = [
    "GITHUB_TOKEN",
  ]
  args = "release --release-notes=/github/workspace/CHANGELOG.md"
}

action "not-auto" {
  uses = "actions/bin/filter@master"
  args = "not actor autobot"
}

action "is-master" {
  uses = "actions/bin/filter@master"
  needs = "not-auto"
  args = "branch master"
  secrets = ["GITHUB_TOKEN"]
}

action "tag" {
  uses = "./.github/actions/git-tags"
  needs = "is-master"
  secrets = ["GITHUB_TOKEN"]
}

action "generate-tagged-changelog" {
  uses = "docker://ferrarimarco/github-changelog-generator:1.15.0.pre.beta"
  needs = "tag"
  secrets = ["CHANGELOG_GITHUB_TOKEN"]
  env = {
    SRC_PATH = "/github/workspace"
  }
  args = "-u gabeduke -p workflow --release-branch develop"
}

action "push-changelog" {
  uses = "docker://whizark/chandler"
  needs = "generate-tagged-changelog"
  secrets = ["CHANDLER_GITHUB_API_TOKEN"]
  env = {
    CHANDLER_WORKDIR = "/github/workspace"
  }
  args = "push"
}

action "bumpver" {
  uses = "./.github/actions/bumpver"
  needs = "tag"
}

action "auto-commit" {
  uses = "./.github/actions/auto-commit"
  needs = ["bumpver"]
  args = "This is an auto-commit"
  secrets = ["GITHUB_TOKEN"]
}

action "fmt" {
  uses = "./.github/actions/golang"
  args = "fmt"
  secrets = ["GITHUB_TOKEN"]
}

action "lint" {
  uses = "./.github/actions/golang"
  args = "lint"
  secrets = ["GITHUB_TOKEN"]
}

action "test" {
  uses = "./.github/actions/golang"
  args = "test"
  secrets = ["GITHUB_TOKEN"]
}

# action "codecov" {
#   uses = "pleo-io/actions/codecov@master"
#   needs = ["test"]
#   secrets = ["CODECOV_TOKEN"]
# }
