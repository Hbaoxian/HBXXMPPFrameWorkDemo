# Uncomment this line to define a global platform for your project
workspace 'XMPPStreamDemo.xcworkspace'
platform :ios, '8.0'

use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

def shared_pods
    # all the pods go here
    # pod 'Parse' etc.
    pod 'XMPPFramework', :git => "https://github.com/robbiehanson/XMPPFramework.git", :branch => 'master'
    pod 'Masonry', '~> 0.6.2'
    pod 'AFNetworking', '~> 3.1.0'
    pod 'SDWebImage', '~> 3.7.2'
  
end



target 'XMPPStreamDemo' do
    project 'XMPPStreamDemo'
    shared_pods
end

