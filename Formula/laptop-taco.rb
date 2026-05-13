# Homebrew formula for Laptop Taco.
#
# This file is intended to live in a separate tap repo, conventionally:
#   github.com/tokenwaster76/homebrew-tap
# at path:
#   Formula/laptop-taco.rb
#
# To create the tap once:
#
#   1. Create a public repo named `homebrew-tap` under your account.
#   2. Copy this file into Formula/laptop-taco.rb in that repo.
#   3. Update the `url`, `sha256`, and `version` lines below to point at
#      a real release tarball (created by publishing a GitHub release
#      with a tag — `marketing/scripts/create-github-release.sh` does this).
#   4. Users install with:
#
#        brew install tokenwaster76/tap/laptop-taco
#
#   On every new release, bump `version`, update `url` to the new tag
#   tarball, and recompute `sha256` with:
#
#        curl -L https://github.com/tokenwaster76/laptop_taco/archive/refs/tags/v0.1.1.tar.gz \
#          | shasum -a 256
#
class LaptopTaco < Formula
  desc "Tiny macOS CLI that keeps your Mac awake while AI coding agents cook"
  homepage "https://github.com/tokenwaster76/laptop_taco"
  url "https://github.com/tokenwaster76/laptop_taco/archive/refs/tags/v0.1.0.tar.gz"
  # Replace with the real SHA-256 after publishing v0.1.0:
  #   shasum -a 256 <downloaded-tarball>
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"
  version "0.1.0"

  # macOS only on purpose — the script's whole dependency is /usr/bin/caffeinate.
  depends_on :macos

  def install
    bin.install "taco"
    man1.install "man/taco.1"
  end

  test do
    # `taco --version` must print exactly the formula's version line.
    assert_equal "taco #{version}", shell_output("#{bin}/taco --version").strip

    # `taco doctor` should exit 0 on a healthy macOS install.
    system "#{bin}/taco", "doctor"

    # `taco --help` should mention all three subcommand entry points.
    help = shell_output("#{bin}/taco --help")
    assert_match "taco doctor", help
    assert_match "taco <command...>", help
  end
end
