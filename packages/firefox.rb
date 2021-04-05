require 'package'

class Firefox < Package
  description 'Mozilla Firefox (or simply Firefox) is a free and open-source web browser'
  homepage 'https://www.mozilla.org/en-US/firefox/'
  
  # follow ubuntu patch
  @_ver = '87.0+build3-0ubuntu0.16.04.2'
  version @_ver.split('+', 2).first
  license 'MPL-2.0, GPL-2 and LGPL-2.1'
  compatibility 'all'

  # get update on http://ppa.launchpad.net/ubuntu-mozilla-security/ppa/ubuntu/pool/main/f/firefox/
  
  case ARCH
  when 'i686'
    @_arch = 'i386'
    source_sha256 'b338a2c287e7e40bfcc13f93c42d26f1bd78615cec9022e7bcc00a870e1603cf'
  when 'x86_64'
    @_arch = 'amd64'
    source_sha256 '74b13e650ff9f68fb8fc1fd1acf870a5c28f1b22c6900436bdc6019d8207c901'
  when 'armv7l', 'aarch64'
    @_arch = 'armhf'
    source_sha256 '6b9e10346af4df382e01a7ae86f6f66b1e8f6838f263da31c7cfaf445e991677'
  end
  
  source_url "http://ppa.launchpad.net/ubuntu-mozilla-security/ppa/ubuntu/pool/main/f/firefox/firefox_#{@_ver}_#{@_arch}.deb"

  depends_on 'atk'
  depends_on 'cairo'
  depends_on 'dbus'
  depends_on 'dbus_glib'
  depends_on 'fontconfig'
  depends_on 'freetype'
  depends_on 'gdk_pixbuf'
  depends_on 'glib'
  depends_on 'gtk2'
  depends_on 'gtk3'
  depends_on 'libx11'
  depends_on 'libxcb'
  depends_on 'libxcomposite'
  depends_on 'libxcursor'
  depends_on 'libxdamage'
  depends_on 'libxext'
  depends_on 'libxfixes'
  depends_on 'libxi'
  depends_on 'libxrender'
  depends_on 'libxt'
  depends_on 'pango'
  depends_on 'pulseaudio'
  depends_on 'sommelier'

  def self.patch   
    @_wrapper = <<~EOF
      #!/bin/sh
      # To get sound working, used : https://codelab.wordpress.com/2017/12/11/firefox-drops-alsa-apulse-to-the-rescue/
      
      exec apulse #{CREW_PREFIX}/lib/firefox/firefox "$@"
    EOF
    
    FileUtils.rm('./usr/bin/firefox')
    File.write('./usr/bin/firefox', @_wrapper)
    File.chmod(0755, './usr/bin/firefox')
  end

  def self.install
    FileUtils.mkdir_p(CREW_DEST_PREFIX)
    FileUtils.mv('./etc/', CREW_DEST_PREFIX)
    FileUtils.mv(Dir['./usr/*'], CREW_DEST_PREFIX)
  end
end
