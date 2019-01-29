
Pod::Spec.new do |s|

  s.name         = "Pring"
  s.version      = "0.14.1"
  s.summary      = "Firestore model framework"
  s.description  = <<-DESC
Pring is a framework for defining Firestore's Model. You can seamlessly manage Firestorage data and operate all values type-safely.
                   DESC
  s.homepage     = "https://github.com/1amageek/Pring"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "1amageek" => "tmy0x3@icloud.com" }
  s.social_media_url   = "http://twitter.com/1amageek"
  s.platform     = :ios, "10.0"
  # s.ios.deployment_target = "11.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/1amageek/Pring.git", :tag => "#{s.version}" }
  s.source_files  = "Pring/**/*.swift"
  s.requires_arc = true
  s.static_framework = true
  s.dependency "Firebase"
  s.dependency "Firebase/Firestore"
  s.dependency "Firebase/Storage"
end
