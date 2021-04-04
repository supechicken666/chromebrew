require 'package'

class Vim_runtime < Package
  description 'Vim is a highly configurable text editor built to make creating and changing any kind of text very efficient. (shared runtime)'
  homepage 'http://www.vim.org/'
  @_ver = '8.2.2580'
  version @_ver
  license 'GPL-2'
  compatibility 'all'
  source_url 'https://github.com/vim/vim/archive/v8.2.2580.tar.gz'
  source_sha256 'd0a508ca9726c8ff69bc5f5ab1ebe251c256e01e730f7b36afd03a66c89fcf79'

  binary_url({
    aarch64: 'https://dl.bintray.com/chromebrew/chromebrew/vim_runtime-8.2.2580-chromeos-armv7l.tar.xz',
     armv7l: 'https://dl.bintray.com/chromebrew/chromebrew/vim_runtime-8.2.2580-chromeos-armv7l.tar.xz',
       i686: 'https://dl.bintray.com/chromebrew/chromebrew/vim_runtime-8.2.2580-chromeos-i686.tar.xz',
     x86_64: 'https://dl.bintray.com/chromebrew/chromebrew/vim_runtime-8.2.2580-chromeos-x86_64.tar.xz'
  })
  binary_sha256({
    aarch64: '8cc4833ea1a19af223e899b5aa7edfa7a7258f33080008d39783acf92d22e2e3',
     armv7l: '8cc4833ea1a19af223e899b5aa7edfa7a7258f33080008d39783acf92d22e2e3',
       i686: '1cefc1026dfdac9d039bb82629ab9287c2bd9a6704f4929f120766d436e7c237',
     x86_64: '9b8e3d8e1e7455d049000342972c9dfb09ad1fb0b98ef665dde381aa646f9951'
  })

  depends_on 'gpm'

  def self.patch
    abort('Please remove libiconv before building.') if File.exist?("#{CREW_LIB_PREFIX}/libcharset.so")
    # set the system-wide vimrc path
    FileUtils.cd('src') do
      system 'sed', '-i', "s|^.*#define SYS_VIMRC_FILE.*$|#define SYS_VIMRC_FILE \"#{CREW_PREFIX}/etc/vimrc\"|",
             'feature.h'
      system 'sed', '-i', "s|^.*#define SYS_GVIMRC_FILE.*$|#define SYS_GVIMRC_FILE \"#{CREW_PREFIX}/etc/gvimrc\"|",
             'feature.h'
      system 'autoconf'
    end
  end

  def self.build
    system './configure --help'
    system "env CFLAGS='-pipe -fno-stack-protector -U_FORTIFY_SOURCE -flto=auto' \
      CXXFLAGS='-pipe -fno-stack-protector -U_FORTIFY_SOURCE -flto=auto' \
      LDFLAGS='-fno-stack-protector -U_FORTIFY_SOURCE -flto=auto' \
      ./configure \
      #{CREW_OPTIONS} \
      --localstatedir=#{CREW_PREFIX}/var/lib/vim \
      --with-features=huge \
      --with-compiledby='Chromebrew' \
      --enable-gpm \
      --enable-acl \
      --with-x=no \
      --disable-gui \
      --enable-multibyte \
      --enable-cscope \
      --enable-netbeans \
      --enable-perlinterp=dynamic \
      --enable-pythoninterp=dynamic \
      --enable-python3interp=dynamic \
      --enable-rubyinterp=dynamic \
      --enable-luainterp=dynamic \
      --enable-tclinterp=dynamic \
      --disable-canberra \
      --disable-selinux \
      --disable-nls"
    system 'make'
  end

  def self.install
    system 'make', "VIMRCLOC=#{CREW_PREFIX}/etc", "DESTDIR=#{CREW_DEST_DIR}", 'install'

    # bin and man will be provided by the 'vim' packages
    FileUtils.rm_r "#{CREW_DEST_PREFIX}/bin"
    FileUtils.rm_r "#{CREW_DEST_PREFIX}/share/man"

    # remove desktop and icon files for the terminal package
    FileUtils.rm_r "#{CREW_DEST_PREFIX}/share/applications"
    FileUtils.rm_r "#{CREW_DEST_PREFIX}/share/icons"

    # add sane defaults and simulate some XDG support
    FileUtils.mkdir_p("#{CREW_DEST_PREFIX}/share/vim/vimfiles")
    File.write("#{CREW_DEST_PREFIX}/share/vim/vimfiles/chromebrew.vim", <<~EOF)
      " Global vimrc - setting some sane defaults
      "
      " DO NOT EDIT THIS FILE. IT'S OVERWRITTEN UPON UPGRADES.
      "
      " Use #{CREW_PREFIX}/etc/vimrc for system-wide and ~/.vimrc for personal
      " configuration.

      " Use Vim defaults instead of 100% vi compatibility
      " Avoid side-effects when nocompatible has already been set.
      if &compatible
        set nocompatible
      endif

      set backspace=indent,eol,start
      set ruler
      set suffixes+=.aux,.bbl,.blg,.brf,.cb,.dvi,.idx,.ilg,.ind,.inx,.jpg,.log,.out,.png,.toc
      set suffixes-=.h
      set suffixes-=.obj

      " Move temporary files to a secure location to protect against CVE-2017-1000382
      if exists('$XDG_CACHE_HOME')
        let &g:directory=$XDG_CACHE_HOME
      else
        let &g:directory=$HOME . '/.cache'
      endif
      let &g:undodir=&g:directory . '/vim/undo//'
      let &g:backupdir=&g:directory . '/vim/backup//'
      let &g:directory.='/vim/swap//'
      " Create directories if they doesn't exist
      if ! isdirectory(expand(&g:directory))
        silent! call mkdir(expand(&g:directory), 'p', 0700)
      endif
      if ! isdirectory(expand(&g:backupdir))
        silent! call mkdir(expand(&g:backupdir), 'p', 0700)
      endif
      if ! isdirectory(expand(&g:undodir))
        silent! call mkdir(expand(&g:undodir), 'p', 0700)
      endif
    EOF
  end

  def self.postinstall
    vimrc = "#{CREW_PREFIX}/etc/vimrc"
    # keep user changes by writing to a new file
    vimrc += '.new' if File.exist?(vimrc)
    # by default we will load the global config
    File.write(vimrc, <<~EOF)
      " System-wide defaults are in #{CREW_PREFIX}/share/vim/vimfiles/chromebrew.vim
      " and sourced by this file. If you wish to change any of those settings, you
      " should do so at the end of this file or in your user-specific (~/.vimrc) file.

      " If you do not wish to use the bundled defaults, remove the next line.
      runtime! chromebrew.vim
    EOF
  end
end
