# Code generated by Harp build tool
class Harp < Formula
  desc "Secret management toolchain"
  homepage "https://github.com/elastic/harp"
  license "Apache-2.0"
  stable do
    if OS.mac? && Hardware::CPU.arm?
      url "https://github.com/elastic/harp/releases/download/cmd%2Fharp%2Fv0.1.23/harp-darwin-arm64-v0.1.23.tar.xz"
      sha256 "7f0a899b7403024ce0de171ee7246b57d729a0a92bf3379d0a4d186761f463ca"
    elsif OS.mac?
      url "https://github.com/elastic/harp/releases/download/cmd%2Fharp%2Fv0.1.23/harp-darwin-amd64-v0.1.23.tar.xz"
      sha256 "715ab951095df0b2c1a31e3701fa8673d9618bb513bd7f36221e6824fb9dbf15"
    elsif OS.linux?
      url "https://github.com/elastic/harp/releases/download/cmd%2Fharp%2Fv0.1.23/harp-linux-amd64-v0.1.23.tar.xz"
      sha256 "5d9fecd0b747ed36fe2de4f6dc352c42294363bbfcb3809b1b5cbef43c2aa831"
    end
  end

  head do
    url "https://github.com/elastic/harp.git", branch: "main"

    # build dependencies
    depends_on "go" => :build
    depends_on "mage" => :build
  end

  bottle :unneeded

  # Stable build

  # Source definition

  def install
    ENV.deparallelize

    if build.head?
      # Prepare build environment
      ENV["GOPATH"] = buildpath
      (buildpath/"src/github.com/elastic/harp").install Dir["{*,.git,.gitignore}"]

      # Mage tools
      ENV.prepend_path "PATH", buildpath/"tools/bin"

      # In github.com/elastic/harp command
      cd "src/github.com/elastic/harp/cmd/harp" do
        system "go", "mod", "vendor"
        system "mage", "compile"
      end

      # Install builded command
      cd "src/github.com/elastic/harp/cmd/harp/bin" do
        # Install binaries
        if OS.mac? && Hardware::CPU.arm?
          bin.install "harp-darwin-arm64" => "harp"
        elsif OS.mac?
          bin.install "harp-darwin-amd64" => "harp"
        elsif OS.linux?
          bin.install "harp-linux-amd64" => "harp"
        end
      end
    elsif OS.mac? && Hardware::CPU.arm?
      # Install binaries
      bin.install "harp-darwin-arm64" => "harp"
    elsif OS.mac?
      bin.install "harp-darwin-amd64" => "harp"
    elsif OS.linux?
      bin.install "harp-linux-amd64" => "harp"
    end

    # Final message
    ohai "Install success!"
  end

  def caveats
    <<~EOS
      If you have previously built harp from source, make sure you're not using
      $GOPATH/bin/harp instead of this one. If that's the case you can simply run
      rm -f $GOPATH/bin/harp
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/harp version")
  end
end
