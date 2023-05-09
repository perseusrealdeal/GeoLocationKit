Pod::Spec.new do |p|

p.name           = "PerseusGeoLocationKit"
p.version        = "0.1.0"
p.summary        = "Geo location services client component for macOS/iOS."
p.description    = "Collection of macOS/iOS tools for dealing with native geo location services."
p.homepage       = "https://github.com/perseusrealdeal/PerseusGeoLocationKit"

p.license        = { :type => "MIT", :file => "LICENSE" }
p.author         = { "perseusrealdeal" => "mzhigulin@gmail.com" }

p.source         = { :git => "https://github.com/perseusrealdeal/PerseusGeoLocationKit.git", :tag => p.version.to_s }

p.ios.deployment_target  = '9.3'
p.osx.deployment_target  = '10.9'

p.swift_version  = "4.2"
p.requires_arc   = true

p.source_files   = 'Sources/**/*.swift'

end
