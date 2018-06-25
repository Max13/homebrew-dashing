class Dashing < Formula
  desc "Generate Dash documentation from HTML files"
  homepage "https://github.com/Max13/dashing"
  url "https://github.com/Max13/dashing/archive/0.4.1.tar.gz"
  sha256 "16c1218d9ab6e1bfd1baea09ef1431e6729d79c05c26fd79fbc7c80d42baf21c"

  # bottle do
  #   cellar :any_skip_relocation
  #   sha256 "c2f8c6d1385e407c9f643b313cbd4dac33c98c7c8604cf983b73c53b447bc8ed" => :high_sierra
  # end

  depends_on "glide" => :build
  depends_on "go" => :build

  # Use ruby docs just as dummy documentation to test with
  resource "ruby_docs_tarball" do
    url "https://ruby-doc.org/downloads/ruby_2_5_0_core_rdocs.tgz"
    sha256 "7ce242e91ff8386715f12161057e5f8f3dc6c44c317dbbfae2ae9587dcf3a7f0"
  end

  def install
    ENV["GOPATH"] = buildpath
    ENV["GLIDE_HOME"] = HOMEBREW_CACHE/"glide_home/#{name}"

    (buildpath/"src/github.com/Max13/dashing").install buildpath.children
    cd "src/github.com/Max13/dashing" do
      system "glide", "install"
      system "go", "build", "-o", bin/"dashing", "-ldflags",
             "-X main.version=#{version}"
      prefix.install_metafiles
    end
  end

  test do
    # Make sure that dashing creates its settings file and then builds an actual
    # docset for Dash
    testpath.install resource("ruby_docs_tarball")
    system bin/"dashing", "create"
    assert_predicate testpath/"dashing.json", :exist?
    system bin/"dashing", "build", "."
    file = testpath/"dashing.docset/Contents/Resources/Documents/goruby_c.html"
    assert_predicate file, :exist?
  end
end
