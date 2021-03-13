=begin
Copyright (c) 2021 The Chromebrew Authors. All rights reserved.

cpkg: auto fetch checksum from repo and get version according to source_url

example
----------
require 'cpkg' # replace `package` to `cpkg`

class Example < Cpkg # replace `package` to `cpkg`
   description 'test'
   compatibility 'x86_64, armv7l' # if `all` architecture available, use `all`
   package_url '<link to deb file>' # if package have mutil-arch support, replace 'x86_64' to $ARCH (ONLY if an apt repo)
   version '1.0' # only need when source is NOT an apt repository

   depends_on 'dependency' # dependencies of this package
   depends_on 'dependency2'
end
----------
=end
require 'package'

class Cpkg < Package  
  def self.package_url (pkgUrl = nil)
    if compatibility == 'all'
      @arch = 'all'
    else
      case ARCH
      when 'armv7l', 'aarch64'
        @arch = 'armhf'
      when 'x86_64'
        @arch = 'amd64'
      when 'i686'
        @arch = 'i386'
      end
    end
    # replace $ARCH to arch if the architecture supported and do not have binary for `all`
    # source_url must be from an apt repo
    source_url(pkgUrl.sub('$ARCH', @arch))
    @pkgRepo = pkgUrl.split(/(pool\/.*)/, 2)
    version(pkgUrl.scan(/_(.*?)_/)[0][0])
    # fetch sha256 checksum from repo
    printf '==> Fetching checksum...  '.lightblue
    source_sha256(`#{CURL} -Ls --ssl --compressed \
        '#{@pkgRepo[0]}/dists/stable/main/binary-#{@arch}/Packages.gz' | gzip -d`.split("\n\n", -1) \
        .grep(/^Filename.*#{@pkgRepo[1]}/)[0] \
        .scan(/^SHA256: (.*)/)[0][0])
    puts 'Done'.lightgreen
  end
    
  def self.install
    # move all folders to CREW_DEST_PREFIX
    @_extract_dirs = [
     ['usr/local/bin', 'bin'],
     ['usr/local/sbin', 'sbin'],
     ['usr/local/lib', ARCH_LIB],
     ['usr/local/lib64', ARCH_LIB],
     ['usr/local/share', 'share'],
     ['usr/bin', 'bin'],
     ['usr/sbin', 'sbin'],
     ['usr/lib/x86_64-linux-gnu', ARCH_LIB],
     ['usr/lib/i386-linux-gnu', ARCH_LIB],
     ['usr/lib', ARCH_LIB],
     ['usr/lib64', ARCH_LIB],
     ['usr/share', 'share'],
     ['share', 'share'],
     ['opt', 'opt'],
     ['lib', ARCH_LIB],
     ['lib64', ARCH_LIB]]
    
    FileUtils.mkdir_p CREW_DEST_PREFIX
    for i in @_extract_dirs do
      FileUtils.mv(i[0], "#{CREW_DEST_PREFIX}/#{i[1]}") if File.exist?(i[0])
    end
  end
end