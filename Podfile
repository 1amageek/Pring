# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Pring' do
  use_frameworks!

  pod 'Firebase', '~> 5.6.0'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'

  target 'PringTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

target 'Sample' do
  use_frameworks!
  pod 'Pring', :path => './'

end
