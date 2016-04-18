class Snx < Formula
  desc "SNX installer"
  homepage "https://github.com/felin-arch/snx"
  url "https://github.com/felin-arch/snx/archive/0.0.7.tar.gz"
  sha256 "f207d18995e9fbd4898ce779abf287e9dffe946744c4a60d9d7fd9a4aa25d163"

  depends_on "terminal-notifier"
  skip_clean "bin/snx"

  def install
    bin.install "snx"
    ohai "Setting snx executable privileges"
    system "sudo", "chown", "root", "#{bin}/snx"
    system "sudo", "chmod", "4755", "#{bin}/snx"
    ohai "Installing CAverify app"
    system "sudo", "install", "-d", "-o", "0", "-g", "0", "-m", "0700", "/etc/snx"
    system "sudo", "install", "-d", "-o", "0", "-g", "0", "-m=u=rwx", "/etc/snx/tmp"
    system "sudo", "install", "-d", "-o", "0", "-g", "0", "-m=u=rwx", "/etc/snx/CAverify.app/Contents/MacOS"
    system "sudo", "install", "-d", "-o", "0", "-g", "0", "-m=u=rwx", "/etc/snx/CAverify.app/Contents/Resources"
    system "sudo", "install", "-o", "0", "-g", "0", "-m=u=rx,g=x", "CAverify", "/etc/snx/CAverify.app/Contents/MacOS"
    system "sudo", "install", "-o", "0", "-g", "0", "-m=u=rw,g=rw", "Info.plist.CAverify", "/etc/snx/CAverify.app/Contents/Info.plist"
    system "sudo", "install", "-o", "0", "-g", "0", "-m=u=rw,g=rw", "snx1.icns", "/etc/snx/CAverify.app/Contents/Resources/snx1.icns"
    ohai "Allright! I need some info to set up the scripts."
    server = prompt "Server: "
    username = prompt "Username: "
    keychain = prompt "Keychain item holding VPN password: "

    ohai "Customizing apps"
    inreplace "apps/cpup.app/Contents/document.wflow", "#SERVER#", server
    inreplace "apps/cpup.app/Contents/document.wflow", "#USER#", username
    inreplace "apps/cpup.app/Contents/document.wflow", "#KEYCHAIN#", keychain
    inreplace "apps/cpup.app/Contents/document.wflow", "#SNX#", "#{HOMEBREW_PREFIX}/bin/snx"
    inreplace "apps/cpup.app/Contents/document.wflow", "#NOTIFY#", "#{HOMEBREW_PREFIX}/bin/terminal-notifier"

    inreplace "apps/cpstat.app/Contents/document.wflow", "#NOTIFY#", "#{HOMEBREW_PREFIX}/bin/terminal-notifier"

    inreplace "apps/cpdown.app/Contents/document.wflow", "#NOTIFY#", "#{HOMEBREW_PREFIX}/bin/terminal-notifier"
    inreplace "apps/cpdown.app/Contents/document.wflow", "#SNX#", "#{HOMEBREW_PREFIX}/bin/snx"

    ohai "Copying apps to your Applications folder"
    mkdir_p user_app_dir
    system "cp", "-r", "apps/cpup.app", user_app_dir
    system "cp", "-r", "apps/cpstat.app", user_app_dir
    system "cp", "-r", "apps/cpdown.app", user_app_dir
    File.write "/tmp/brew-snx-first-connect", "#{HOMEBREW_PREFIX}/bin/snx -s #{server} -u #{username}"
  end

  def caveats; <<-EOS.undent
    WARNING! This installer placed files outside of the Cellar.
    Upon uninstalling, you can remove these manually by running:
        sudo rm -rf /etc/snx
        rm -rf #{user_app_dir}cpup.app
        rm -rf #{user_app_dir}cpstat.app
        rm -rf #{user_app_dir}cpdown.app

    IMPORTANT! Upon your first VPN connection you will be prompted to
    verify the server's certificate. The installed apps will only
    work after this. Please connect now using:
        #{first_connect_command}
 
    IMPORTANT! The application needs to access the keychain to retrieve
    the password for the VPN connection. Upon the first launch of cpup.app
    you will be prompted to allow this.

    For more information visit: https://github.com/felin-arch/snx

    Enjoy!
    EOS
  end

  test do
    system "true"
  end

  private
  def prompt(str)
    `read -p "#{str}" b; echo $b`.strip
  end

  def user_app_dir
    `echo $(eval echo ~$(whoami))/Applications/`.strip
  end

  def first_connect_command
    File.read "/tmp/brew-snx-first-connect"
  end
end
